import AppKit
import SwiftUI
import Combine
import WritingCore

private final class MarkCanvas: NSView {
    var marks: [LocatedSuggestion] = []
    override var isOpaque: Bool { false }
    override func draw(_ dirtyRect: NSRect) {
        // Draw pending errors last so an optional wording marker cannot conceal them.
        for mark in marks.filter({ !$0.isFieldAnchor }).sorted(by: { $0.suggestion.kind == .style && $1.suggestion.kind != .style }) {
            let color = mark.suggestion.kind == .style ? NSColor.systemBlue : NSColor.systemRed
            color.setStroke()
            for global in mark.rects {
                guard let window else { continue }
                let rect = global.offsetBy(dx: -window.frame.minX, dy: -window.frame.minY)
                let path = NSBezierPath()
                path.lineWidth = 1.5
                let y = rect.minY + 1
                path.move(to: CGPoint(x: rect.minX, y: y))
                var x = rect.minX
                while x < rect.maxX {
                    path.line(to: CGPoint(x: min(x + 2, rect.maxX), y: y + 1.3))
                    path.line(to: CGPoint(x: min(x + 4, rect.maxX), y: y))
                    x += 4
                }
                path.stroke()
            }
        }
        let anchored = marks.filter(\.isFieldAnchor)
        if let global = anchored.first?.rects.first, let window {
            let rect = global.offsetBy(dx: -window.frame.minX, dy: -window.frame.minY)
            NSColor.systemBlue.setFill()
            NSBezierPath(roundedRect: rect, xRadius: 8, yRadius: 8).fill()
            let label = NSAttributedString(string: String(anchored.count), attributes: [
                .font: NSFont.systemFont(ofSize: 11, weight: .semibold), .foregroundColor: NSColor.white])
            let size = label.size()
            label.draw(at: CGPoint(x: rect.midX - size.width / 2, y: rect.midY - size.height / 2))
        }
    }
}

private final class SuggestionPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
    var onEscape: (() -> Void)?
    override func cancelOperation(_ sender: Any?) { onEscape?() }
}

@MainActor
final class CardFeedback: ObservableObject {
    @Published var interaction = SuggestionInteractionState()
    @Published var applications: [UUID: ApplicationFeedback] = [:]
    @Published var translations: [UUID: SuggestionTranslationState] = [:]
    @Published var translationTargetName = "Português"
    func translation(for id: UUID) -> SuggestionTranslationState { translations[id] ?? .hidden }
    func application(for id: UUID) -> ApplicationFeedback { applications[id] ?? .idle }
    var states: [UUID: AlternativeState] {
        get { interaction.states }
        set { interaction.states = newValue }
    }
    func state(for id: UUID) -> AlternativeState { interaction.state(for: id) }
}

@MainActor
final class OverlayPresenter {
    var onAccept: ((WritingSuggestion) -> Void)?
    var onDismiss: ((WritingSuggestion) -> Void)?
    var onAlternatives: ((WritingSuggestion) -> Void)?
    var onTranslate: ((WritingSuggestion) -> Void)?
    var onHideTranslation: ((WritingSuggestion) -> Void)?
    var translationLanguageName: () -> String = { "Português" }
    private var located: [LocatedSuggestion] = []
    private let feedback = CardFeedback()
    private let canvas = MarkCanvas()
    private let marksWindow: NSWindow
    private let card: SuggestionPanel
    private var openID: UUID? { feedback.interaction.openID }
    private var keyboardPinned: Bool { feedback.interaction.isPinned }
    private var lastInteraction = Date.distantPast
    private var hoverTimer: Timer?

    init() {
        marksWindow = NSWindow(contentRect: .zero, styleMask: [.borderless], backing: .buffered, defer: false)
        marksWindow.isOpaque = false
        marksWindow.backgroundColor = .clear
        marksWindow.hasShadow = false
        marksWindow.ignoresMouseEvents = true
        marksWindow.level = .floating
        marksWindow.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .ignoresCycle]
        marksWindow.contentView = canvas
        marksWindow.isReleasedWhenClosed = false
        card = SuggestionPanel(contentRect: .zero, styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
        card.isOpaque = false
        card.backgroundColor = .clear
        card.hasShadow = true
        card.level = .floating
        card.isFloatingPanel = true
        card.hidesOnDeactivate = false
        card.becomesKeyOnlyIfNeeded = true
        card.isReleasedWhenClosed = false
        card.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .ignoresCycle]
        card.onEscape = { [weak self] in self?.hideCard() }
        hoverTimer = Timer.scheduledTimer(withTimeInterval: 0.12, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.trackPointer() }
        }
    }

    func update(_ values: [LocatedSuggestion]) {
        located = values
        guard !values.isEmpty else { clear(); return }
        let rectangles = values.flatMap(\.rects)
        let bounds = rectangles.reduce(CGRect.null) { $0.union($1) }.insetBy(dx: -4, dy: -4)
        guard !bounds.isNull else { clear(); return }
        marksWindow.setFrame(bounds, display: false)
        canvas.frame = CGRect(origin: .zero, size: bounds.size)
        canvas.marks = values
        canvas.needsDisplay = true
        marksWindow.orderFrontRegardless()
        if let openID {
            if let item = values.first(where: { $0.suggestion.id == openID }) { positionCard(near: item) }
            else { hideCard() }
        }
    }

    func clear() {
        located = []; canvas.marks = []
        feedback.interaction.clear()
        feedback.applications.removeAll()
        feedback.translations.removeAll()
        marksWindow.orderOut(nil)
        hideCard()
    }

    func hideCard() {
        card.orderOut(nil)
        card.contentView = nil
        feedback.interaction.hide()
    }

    func setAlternativeState(_ state: AlternativeState, for id: UUID) {
        feedback.interaction.set(state, for: id)
        if openID == id, let item = located.first(where: { $0.suggestion.id == id }) {
            feedback.interaction.pin()
            card.setContentSize(cardSize(for: item.suggestion))
            positionCard(near: item)
        }
    }

    @discardableResult
    func finishAlternativeRequest(for id: UUID, presenting resultID: UUID? = nil) -> Bool {
        let visible = card.isVisible
        let next = feedback.interaction.finish(for: id, presenting: resultID)
        if openID == id, let item = located.first(where: { $0.suggestion.id == id }) {
            card.setContentSize(cardSize(for: item.suggestion))
            positionCard(near: item)
        }
        return visible && next != nil
    }

    func showSuggestion(id: UUID) {
        if let item = located.first(where: { $0.suggestion.id == id }) {
            showCard(for: item, pinned: true)
        }
    }

    func isShowing(_ id: UUID) -> Bool { openID == id && card.isVisible }

    func showCard(for item: LocatedSuggestion, keyboard: Bool = false, pinned: Bool = false) {
        if openID == item.suggestion.id {
            if keyboard { feedback.interaction.pin(); card.makeKeyAndOrderFront(nil) }
            return
        }
        feedback.interaction.open(item.suggestion.id, pinned: keyboard || pinned)
        refreshTranslationLanguage()
        let suggestion = item.suggestion
        let view = SuggestionCardView(suggestion: suggestion, feedback: feedback,
            accept: { [weak self] in self?.onAccept?(suggestion) },
            dismiss: { [weak self] in self?.onDismiss?(suggestion) },
            alternatives: { [weak self] in self?.onAlternatives?(suggestion) },
            close: { [weak self] in self?.hideCard() },
            translate: { [weak self] in self?.onTranslate?(suggestion) },
            hideTranslation: { [weak self] in self?.onHideTranslation?(suggestion) })
        card.contentView = NSHostingView(rootView: view)
        card.setContentSize(cardSize(for: suggestion))
        positionCard(near: item)
        if keyboard { card.makeKeyAndOrderFront(nil) } else { card.orderFrontRegardless() }
        lastInteraction = Date()
    }

    func setApplicationState(_ state: ApplicationFeedback, for id: UUID) {
        feedback.applications[id] = state
        guard openID == id, let item = located.first(where: { $0.suggestion.id == id }) else { return }
        feedback.interaction.pin()
        card.setContentSize(cardSize(for: item.suggestion))
        positionCard(near: item)
    }

    func refreshTranslationLanguage() { feedback.translationTargetName = translationLanguageName() }

    func setTranslationState(_ state: SuggestionTranslationState, for id: UUID) {
        if state == .hidden { feedback.translations.removeValue(forKey: id) }
        else { feedback.translations[id] = state }
        // A late result can update a closed card's state, but cannot reopen it.
        guard card.isVisible, openID == id, let item = located.first(where: { $0.suggestion.id == id }) else { return }
        feedback.interaction.pin()
        card.setContentSize(cardSize(for: item.suggestion))
        positionCard(near: item)
    }

    private func cardSize(for suggestion: WritingSuggestion) -> CGSize {
        SuggestionCardView.size(for: suggestion, state: feedback.state(for: suggestion.id),
            applicationFailure: feedback.application(for: suggestion.id).message != nil,
            translation: feedback.translation(for: suggestion.id))
    }

    private func positionCard(near item: LocatedSuggestion) {
        guard let anchor = item.rects.first else { return }
        let screen = NSScreen.screens.first(where: { $0.frame.intersects(anchor) }) ?? NSScreen.main
        guard let visible = screen?.visibleFrame else { return }
        let size = card.frame.size
        let below = anchor.minY - size.height - 7
        let y = below >= visible.minY ? below : min(anchor.maxY + 7, visible.maxY - size.height)
        let x = min(max(anchor.minX - 10, visible.minX + 6), visible.maxX - size.width - 6)
        card.setFrameOrigin(CGPoint(x: x, y: max(visible.minY + 4, y)))
    }

    private func trackPointer() {
        guard !located.isEmpty else { return }
        let point = NSEvent.mouseLocation
        if card.isVisible, card.frame.insetBy(dx: -6, dy: -6).contains(point) {
            lastInteraction = Date(); return
        }
        if let item = located.first(where: { $0.rects.contains { $0.insetBy(dx: -3, dy: -6).contains(point) } }) {
            guard feedback.interaction.allowsHover(on: item.suggestion.id) else { return }
            showCard(for: item); lastInteraction = Date(); return
        }
        if let openID, feedback.state(for: openID).isBusy { return }
        if !keyboardPinned && Date().timeIntervalSince(lastInteraction) > 0.7 { hideCard() }
    }
}

struct CardPrimaryStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .semibold))
            .padding(.horizontal, 13).padding(.vertical, 8)
            .foregroundStyle(.white)
            .background(Color.accentColor.opacity(configuration.isPressed ? 0.75 : 1), in: Capsule())
    }
}

@MainActor
struct SuggestionCardView: View {
    let suggestion: WritingSuggestion
    @ObservedObject var feedback: CardFeedback
    let accept: () -> Void
    let dismiss: () -> Void
    let alternatives: () -> Void
    let close: () -> Void
    var translate: () -> Void = {}
    var hideTranslation: () -> Void = {}

    private var state: AlternativeState { feedback.state(for: suggestion.id) }
    private var application: ApplicationFeedback { feedback.application(for: suggestion.id) }
    private var translation: SuggestionTranslationState { feedback.translation(for: suggestion.id) }
    private var translationTargetName: String { feedback.translationTargetName }
    private var isPhrase: Bool {
        suggestion.kind != .correction || suggestion.original.split(whereSeparator: { $0.isWhitespace }).count > 2
            || suggestion.replacement.count > 50
    }
    private var tint: Color { suggestion.kind == .style ? .accentColor : Color(red: 0.10, green: 0.48, blue: 0.39) }

    private static func translationHeight(_ state: SuggestionTranslationState) -> Int {
        switch state {
        case .hidden: return 0
        case .loading: return 64
        case .ready(let text, _): return 54 + min(126, max(36, (text.count / 37 + 1) * 19))
        case .failed: return 112
        }
    }

    static func size(for suggestion: WritingSuggestion, state: AlternativeState = .idle, applicationFailure: Bool = false,
                     translation: SuggestionTranslationState = .hidden) -> CGSize {
        let phrase = suggestion.kind != .correction || suggestion.original.split(whereSeparator: { $0.isWhitespace }).count > 2
            || suggestion.replacement.count > 50
        let lines = min(8, max(2, (suggestion.original.count + suggestion.replacement.count) / 44 + 1))
        let extra: Int
        switch state { case .failed, .unavailable: extra = 50 + (suggestion.canApply ? 0 : 40); default: extra = suggestion.canApply ? 0 : 40 }
        let translated = translation.isVisible ? translationHeight(translation) + 12 : 0
        return CGSize(width: phrase ? 360 : 292, height: (phrase ? 156 + lines * 20 : 190) + max(extra, applicationFailure ? 65 : 0) + translated)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 6) {
                Image(systemName: suggestion.kind == .style ? "sparkles" : "checkmark.circle.fill").foregroundStyle(tint)
                Text(suggestion.kind == .coherence ? "Revisar sentido e estrutura" : (suggestion.kind == .style ? "Sugestão de texto" : "Correção"))
                    .font(.system(size: 11, weight: .semibold)).foregroundStyle(.secondary)
                Spacer()
                Button(action: dismiss) { Image(systemName: "minus.circle") }
                    .help("Ignorar esta sugestão").accessibilityLabel("Ignorar sugestão").disabled(application.isBusy)
                Button(action: close) { Image(systemName: "xmark") }
                    .help("Fechar").accessibilityLabel("Fechar cartão")
            }.buttonStyle(.plain).font(.system(size: 11)).padding(.bottom, 12)

            if isPhrase {
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Original: \(suggestion.original)").font(.system(size: 11)).foregroundStyle(.secondary)
                            .lineLimit(2).frame(maxWidth: .infinity, alignment: .leading)
                        Text(suggestion.replacement).font(.system(size: 14, weight: .medium)).lineSpacing(4)
                            .textSelection(.enabled).frame(maxWidth: .infinity, alignment: .leading)
                    }.padding(.trailing, 3)
                }.frame(maxHeight: .infinity)
                if !suggestion.canApply {
                    Text(suggestion.kind == .coherence
                         ? "O sentido parece pouco claro. Reformule para esclarecer o que você quer dizer."
                         : "O texto foi mantido; não há uma nova alteração para aplicar.")
                        .font(.caption).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
                }
                HStack {
                    Text(language).font(.system(size: 10)).foregroundStyle(.tertiary)
                    Spacer()
                    Button("Aplicar sugestão", action: accept).buttonStyle(CardPrimaryStyle())
                        .keyboardShortcut(.defaultAction).disabled(state.isBusy || !suggestion.canApply || !application.canApply)
                }.padding(.top, 10)
            } else {
                Button(action: accept) {
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 5) {
                            if !suggestion.original.isEmpty {
                                Text(suggestion.correctionSourceLabel).strikethrough().font(.system(size: 12)).foregroundStyle(.secondary)
                            }
                            Text(suggestion.correctionActionLabel)
                                .font(.system(size: 21, weight: .semibold)).foregroundStyle(tint).lineLimit(2)
                        }
                        Spacer()
                        Image(systemName: "return").font(.system(size: 12)).foregroundStyle(.tertiary)
                    }.padding(11).background(tint.opacity(0.07), in: RoundedRectangle(cornerRadius: 9))
                }.buttonStyle(.plain).keyboardShortcut(.defaultAction)
                    .help("Aplicar correção").accessibilityLabel("Aplicar correção: \(suggestion.correctionActionLabel)")
                    .disabled(state.isBusy || !suggestion.canApply || !application.canApply)
                Spacer(minLength: 8)
            }

            feedbackView.padding(.top, 10)
            if translation.isVisible { translationView.padding(.top, 12) }
            Rectangle().fill(Color.primary.opacity(0.07)).frame(height: 1).padding(.top, 11).padding(.bottom, 9)
            HStack(spacing: 5) {
                Image(systemName: "sparkle").foregroundStyle(tint)
                Text("LocalScribe").fontWeight(.medium)
                Text("· \(language)").foregroundStyle(.tertiary)
                Spacer()
                Menu {
                    Button(translation.isVisible ? "Ocultar tradução" : "Traduzir para \(translationTargetName)", systemImage: "character.bubble",
                        action: translation.isVisible ? hideTranslation : translate)
                        .disabled(application.isBusy || suggestion.translationText == nil)
                    Button("Copiar sugestão", systemImage: "doc.on.doc") {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(suggestion.replacement, forType: .string)
                    }
                    Button("Ignorar sugestão", systemImage: "minus.circle", action: dismiss).disabled(application.isBusy)
                } label: { Image(systemName: "ellipsis") }
                    .menuStyle(.borderlessButton).menuIndicator(.hidden).fixedSize().help("Mais opções")
                    .accessibilityLabel("Mais opções da sugestão")
            }.font(.system(size: 10)).foregroundStyle(.secondary)
        }
        .padding(15)
        .frame(width: Self.size(for: suggestion, state: state, applicationFailure: application.message != nil, translation: translation).width - 2,
               height: Self.size(for: suggestion, state: state, applicationFailure: application.message != nil, translation: translation).height - 2)
        .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 13))
        .overlay(RoundedRectangle(cornerRadius: 13).stroke(Color.primary.opacity(0.10), lineWidth: 0.7))
        .padding(1).tint(Color(red: 0.22, green: 0.34, blue: 0.78))
    }

    private var language: String {
        Locale(identifier: "pt_BR").localizedString(forLanguageCode: suggestion.language)?.capitalized ?? suggestion.language
    }

    private var translationView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 5) {
                Label("Tradução · \(translation.target)", systemImage: "character.bubble")
                    .font(.system(size: 10, weight: .semibold)).foregroundStyle(.secondary)
                Spacer(minLength: 4)
                if case .ready(let text, _) = translation {
                    Button {
                        NSPasteboard.general.clearContents(); NSPasteboard.general.setString(text, forType: .string)
                    } label: { Image(systemName: "doc.on.doc") }
                        .help("Copiar tradução").accessibilityLabel("Copiar tradução")
                }
                Button(action: hideTranslation) { Image(systemName: "xmark") }
                    .help("Ocultar tradução").accessibilityLabel("Ocultar tradução")
            }.buttonStyle(.plain).font(.system(size: 10))
            switch translation {
            case .hidden: EmptyView()
            case .loading:
                HStack(spacing: 7) {
                    ProgressView().controlSize(.small)
                    Text("Traduzindo no seu Mac…").font(.system(size: 11))
                }.frame(maxWidth: .infinity, alignment: .leading)
            case .ready(let text, _):
                ScrollView {
                    Text(text).font(.system(size: 13)).lineSpacing(3).textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }.frame(maxHeight: .infinity)
            case .failed(let message, _):
                ScrollView {
                    Text(message).font(.system(size: 11)).foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Button("Tentar novamente", action: translate).font(.system(size: 11)).buttonStyle(.plain)
                    .foregroundStyle(Color.accentColor).disabled(application.isBusy)
            }
        }.padding(10)
            .frame(height: CGFloat(Self.translationHeight(translation)))
            .background(Color.accentColor.opacity(0.045), in: RoundedRectangle(cornerRadius: 9))
    }

    @ViewBuilder private var feedbackView: some View {
        if application.isBusy {
            HStack(spacing: 8) {
                ProgressView().controlSize(.small).frame(width: 14, height: 14)
                Text("Aplicando no editor…").font(.system(size: 11, weight: .medium))
                Spacer()
            }.foregroundStyle(Color.accentColor)
        } else if let message = application.message {
            VStack(alignment: .leading, spacing: 7) {
                Label(message, systemImage: "exclamationmark.circle").font(.system(size: 11)).foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                Button("Copiar sugestão", systemImage: "doc.on.doc") {
                    NSPasteboard.general.clearContents(); NSPasteboard.general.setString(suggestion.replacement, forType: .string)
                }.buttonStyle(.borderless).font(.system(size: 11))
            }
        } else {
        switch state {
        case .queued, .generating:
            HStack(spacing: 8) {
                ProgressView().controlSize(.small).scaleEffect(0.8).frame(width: 14, height: 14)
                Text(state == .queued ? "Aguardando revisão atual…" : "Reformulando no seu Mac…")
                    .font(.system(size: 11, weight: .medium))
                Spacer(minLength: 0)
            }.foregroundStyle(Color.accentColor).accessibilityElement(children: .combine)
        case .unavailable(let message), .failed(let message):
            VStack(alignment: .leading, spacing: 6) {
                Text(message).font(.system(size: 11)).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
                alternativeButton
            }
        case .idle: alternativeButton
        }
        }
    }

    private var alternativeButton: some View {
        HStack {
            Button(action: alternatives) {
                Label(suggestion.kind == .style ? "Outra versão" : "Reformular \(suggestion.scopeLabel)", systemImage: suggestion.kind == .style ? "arrow.trianglehead.2.clockwise.rotate.90" : "sparkles")
            }
            Spacer()
            Button(translation.isVisible ? "Ocultar tradução" : "Traduzir", systemImage: "character.bubble",
                   action: translation.isVisible ? hideTranslation : translate)
                .help("Traduzir a sugestão para \(translationTargetName)").disabled(suggestion.translationText == nil)
        }.font(.system(size: 11, weight: .medium)).foregroundStyle(Color.accentColor).buttonStyle(.plain).disabled(application.isBusy)
    }
}

/// Uses the production card view; synthetic examples only, no editor capture or writes.
@MainActor
struct CardGalleryView: View {
    private let feedback: CardFeedback
    private let word: WritingSuggestion
    private let phrase: WritingSuggestion
    private let loading: WritingSuggestion
    private let empty: WritingSuggestion

    init() {
        let word = WritingSuggestion(kind: .correction, range: NSRange(location: 0, length: 3), original: "ola", replacement: "Olá", language: "pt", context: "ola, eu sou Ana.")
        let phrase = WritingSuggestion(kind: .coherence, range: NSRange(location: 0, length: 23), original: "i could can go to there.?", replacement: "I could go there?", language: "en", context: "")
        let loading = WritingSuggestion(kind: .correction, range: NSRange(location: 0, length: 2), original: "go", replacement: "goes", language: "en", context: "She go to school every day.")
        let empty = WritingSuggestion(kind: .style, range: NSRange(location: 0, length: 0), original: "O relatório está pronto.", replacement: "O relatório já foi concluído.", language: "pt", context: "")
        self.word = word; self.phrase = phrase; self.loading = loading; self.empty = empty
        feedback = CardFeedback()
        feedback.applications[loading.id] = .applying
        feedback.applications[empty.id] = .failed("Não foi possível confirmar a alteração. Confira o texto antes de tentar novamente.", retryAllowed: false)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Uma ajuda discreta, na hora de escrever.").font(.system(size: 23, weight: .semibold))
            Text("Prévia visual · exemplos artificiais, sem alterar outros aplicativos.").foregroundStyle(.secondary)
            HStack(alignment: .top, spacing: 22) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("PALAVRA").font(.system(size: 10, weight: .semibold)).foregroundStyle(.secondary)
                    sample(word)
                    Text("PROCESSANDO").font(.system(size: 10, weight: .semibold)).foregroundStyle(.secondary)
                    sample(loading)
                }
                VStack(alignment: .leading, spacing: 16) {
                    Text("FRASE").font(.system(size: 10, weight: .semibold)).foregroundStyle(.secondary)
                    sample(phrase)
                    Text("FALHA DE APLICAÇÃO").font(.system(size: 10, weight: .semibold)).foregroundStyle(.secondary)
                    sample(empty)
                }
            }
        }.padding(30).background(Color(nsColor: .windowBackgroundColor))
    }

    private func sample(_ suggestion: WritingSuggestion) -> some View {
        SuggestionCardView(suggestion: suggestion, feedback: feedback, accept: {}, dismiss: {}, alternatives: {}, close: {})
            .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
    }
}
