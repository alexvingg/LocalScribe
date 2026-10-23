import AppKit
import SwiftUI
import Combine
import Translation
import WritingCore

private final class TranslationPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
    var onEscape: (() -> Void)?
    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 { onEscape?() } else { super.keyDown(with: event) }
    }
}

@MainActor
final class LocalTranslationService: ObservableObject {
    @Published private(set) var result = ""
    @Published private(set) var message = ""
    @Published private(set) var isLoading = false
    @Published private(set) var targetName = ""
    @Published private(set) var sourceLabel = ""
    @Published var configuration: TranslationSession.Configuration?
    @Published var preparing = false
    @Published var preparationMessage = ""
    private var lastSource = "en"
    private var preparation: Task<Void, Never>?
    fileprivate var preparationID = UUID()
    private var panel: TranslationPanel?
    private var task: Task<Void, Never>?
    private var deadline: Task<Void, Never>?
    private var session: TranslationSession?
    private var requestID = UUID()
    private var inlineID: UUID?
    var onInlineUpdate: ((UUID, SuggestionTranslationState) -> Void)?
    private struct Key: Hashable { let text: String; let source: String; let target: String; let bundleID: String }
    private var cache = ReviewMemoryCache<Key, String>(capacity: 32, maximumCost: 32_000, lifetime: 600)

    func close() {
        if let inlineID { onInlineUpdate?(inlineID, .hidden) }
        inlineID = nil
        requestID = UUID(); task?.cancel(); task = nil
        deadline?.cancel(); deadline = nil
        session?.cancel(); session = nil
        isLoading = false; result = ""; message = ""
        panel?.orderOut(nil)
    }
    func reset() { close(); cache.removeAll() }

    func closeInline(for id: UUID) {
        guard inlineID == id else { return }
        close()
    }

    private func updateInline() {
        guard let inlineID else { return }
        let state: SuggestionTranslationState
        if isLoading { state = .loading(target: targetName) }
        else if !result.isEmpty { state = .ready(text: result, target: targetName) }
        else { state = .failed(message: message, target: targetName) }
        onInlineUpdate?(inlineID, state)
    }

    func prepare(target: String) {
        preparation?.cancel()
        let id = UUID(); preparationID = id
        let source = lastSource
        preparing = true
        preparationMessage = "Preparando \(source) → \(target)…"
        preparation = Task { [weak self] in
            guard let self else { return }
            let availability = LanguageAvailability(preferredStrategy: .lowLatency)
            let from = Locale.Language(identifier: source), to = Locale.Language(identifier: target)
            for attempt in 0..<60 {
                let status = await availability.status(from: from, to: to)
                guard self.preparationID == id, !Task.isCancelled else { return }
                if status == .installed || source == target {
                    self.preparing = false; self.configuration = nil
                    self.preparationMessage = "Idiomas locais prontos para tradução."
                    return
                }
                if status == .unsupported {
                    self.preparing = false; self.configuration = nil
                    self.preparationMessage = TranslationFailure.unsupported.localizedDescription
                    return
                }
                if attempt == 0 {
                    self.configuration = TranslationSession.Configuration(source: from, target: to, preferredStrategy: .lowLatency)
                    self.configuration?.invalidate()
                }
                do { try await Task.sleep(nanoseconds: 2_000_000_000) } catch { return }
            }
            guard self.preparationID == id else { return }
            self.preparing = false; self.configuration = nil
            self.preparationMessage = "O download pode continuar em segundo plano. Clique em Preparar idiomas para conferir novamente."
        }
    }

    func translate(_ text: String, source: String, target: String, bundleID: String, label: String, anchor: CGRect?, suggestionID: UUID? = nil) {
        close()
        inlineID = suggestionID
        lastSource = source
        sourceLabel = label
        targetName = Locale(identifier: "pt_BR").localizedString(forLanguageCode: target)?.capitalized ?? target
        if suggestionID == nil { showPanel(near: anchor) }
        guard source != target else { result = text; message = "O texto já está no idioma escolhido."; updateInline(); return }
        let key = Key(text: text, source: source, target: target, bundleID: bundleID)
        if let saved = cache.value(for: key) { result = saved; updateInline(); return }
        isLoading = true
        updateInline()
        let id = requestID
        deadline = Task { [weak self] in
            do { try await Task.sleep(nanoseconds: 25_000_000_000) } catch { return }
            guard let self, self.requestID == id else { return }
            self.requestID = UUID(); self.task?.cancel(); self.session?.cancel()
            self.isLoading = false; self.message = "A tradução demorou para responder. Você pode fechar e tentar novamente."
            self.updateInline()
        }
        task = Task { [weak self] in
            guard let self else { return }
            do {
                let value = try await self.translateInstalled(text, source: source, target: target)
                guard self.requestID == id, !Task.isCancelled else { return }
                self.result = value
                self.cache.insert(value, for: key, cost: text.utf16.count + value.utf16.count)
            } catch {
                guard self.requestID == id else { return }
                if let failure = error as? TranslationFailure { self.message = failure.localizedDescription }
                else if TranslationError.notInstalled ~= error { self.message = TranslationFailure.needsModels.localizedDescription }
                else if TranslationError.unsupportedSourceLanguage ~= error || TranslationError.unsupportedTargetLanguage ~= error || TranslationError.unsupportedLanguagePairing ~= error { self.message = TranslationFailure.unsupported.localizedDescription }
                else { self.message = "Não foi possível traduzir este trecho. Feche e tente novamente." }
                let detail = error as NSError
                print("translation-error domain=\(detail.domain) code=\(detail.code) reason=\(detail.localizedFailureReason ?? "none")")
            }
            if self.requestID == id {
                self.isLoading = false; self.deadline?.cancel(); self.deadline = nil
                self.updateInline()
            }
        }
    }

    func translateInstalled(_ text: String, source: String, target: String) async throws -> String {
        guard source != target else { return text }
        let availability = LanguageAvailability(preferredStrategy: .lowLatency)
        let requestedSource = Locale.Language(identifier: source), requestedTarget = Locale.Language(identifier: target)
        // Resolve availability first; the first regional inventory can be transient at launch.
        _ = await availability.status(from: requestedSource, to: requestedTarget)
        var installed: (Locale.Language, Locale.Language)?
        for attempt in 0..<2 where installed == nil {
            try Task.checkCancellation()
            let languages = await availability.supportedLanguages
            let sources = languages.filter { $0.languageCode == requestedSource.languageCode }
            let targets = languages.filter { $0.languageCode == requestedTarget.languageCode }
            for from in sources {
                for to in targets where installed == nil {
                    if await availability.status(from: from, to: to) == .installed {
                        // Preserve the installed regional variant rather than resolve generic en to en-GB.
                        installed = (Locale.Language(identifier: from.maximalIdentifier), Locale.Language(identifier: to.maximalIdentifier))
                    }
                }
            }
            if installed == nil, attempt == 0 { try await Task.sleep(nanoseconds: 150_000_000) }
        }
        guard let (from, to) = installed else {
            let status = await availability.status(from: Locale.Language(identifier: source), to: Locale.Language(identifier: target))
            if status == .unsupported { throw TranslationFailure.unsupported }
            throw TranslationFailure.needsModels
        }
        try Task.checkCancellation()
        let translator = TranslationSession(installedSource: from, target: to, preferredStrategy: .lowLatency)
        session = translator
        let response = try await translator.translate(text)
        try Task.checkCancellation()
        guard !response.targetText.isEmpty else { throw TranslationFailure.empty }
        return response.targetText
    }

    enum TranslationFailure: LocalizedError {
        case needsModels, unsupported, empty
        var errorDescription: String? {
            switch self {
            case .needsModels: return "Prepare os idiomas em LocalScribe → Configurações → Preparar idiomas. O macOS poderá pedir para baixar os modelos locais."
            case .unsupported: return "Este par de idiomas não é compatível com a tradução local da Apple."
            case .empty: return "A tradução não retornou texto. Tente novamente."
            }
        }
    }

    private func showPanel(near anchor: CGRect?) {
        if panel == nil {
            let window = TranslationPanel(contentRect: NSRect(x: 0, y: 0, width: 390, height: 285),
                styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
            window.isOpaque = false; window.backgroundColor = .clear; window.hasShadow = true
            window.level = .floating; window.isReleasedWhenClosed = false; window.hidesOnDeactivate = false
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            window.onEscape = { [weak self] in self?.close() }
            panel = window
        }
        panel?.contentView = NSHostingView(rootView: TranslationResultView(service: self))
        let point = anchor?.origin ?? NSEvent.mouseLocation
        let screen = NSScreen.screens.first(where: { $0.frame.contains(point) }) ?? NSScreen.main
        if let frame = screen?.visibleFrame {
            panel?.setFrameOrigin(CGPoint(x: min(max(point.x, frame.minX + 6), frame.maxX - 396),
                y: min(max(point.y - 295, frame.minY + 6), frame.maxY - 291)))
        }
        panel?.makeKeyAndOrderFront(nil)
    }
}

private struct TranslationResultView: View {
    @ObservedObject var service: LocalTranslationService
    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack {
                Label("Tradução · \(service.targetName)", systemImage: "character.bubble").font(.headline)
                Spacer()
                Button { service.close() } label: { Image(systemName: "xmark") }.buttonStyle(.plain).help("Fechar tradução")
            }
            Text(service.sourceLabel).font(.caption).foregroundStyle(.secondary)
            if service.isLoading {
                HStack { ProgressView().controlSize(.small); Text("Traduzindo no seu Mac…").font(.callout) }
            }
            ScrollView {
                Text(service.result.isEmpty ? service.message : service.result)
                    .font(.system(size: 14)).textSelection(.enabled).frame(maxWidth: .infinity, alignment: .leading)
            }
            HStack {
                Text("Só para leitura · no dispositivo").font(.caption2).foregroundStyle(.secondary)
                Spacer()
                Button("Copiar", systemImage: "doc.on.doc") {
                    NSPasteboard.general.clearContents(); NSPasteboard.general.setString(service.result, forType: .string)
                }.buttonStyle(.borderless).disabled(service.result.isEmpty)
            }
        }.padding(18).frame(width: 354, height: 249)
            .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 13))
            .overlay(RoundedRectangle(cornerRadius: 13).stroke(Color.primary.opacity(0.1)))
    }
}

struct TranslationSetupView: View {
    @ObservedObject var service: LocalTranslationService
    let target: String
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Button(service.preparing ? "Preparando idiomas…" : "Preparar idiomas…") { service.prepare(target: target) }
                .buttonStyle(.borderless).disabled(service.preparing)
            if !service.preparationMessage.isEmpty { Text(service.preparationMessage).font(.caption).foregroundStyle(.secondary) }
        }.translationTask(service.configuration) { session in
            guard service.preparing else { return }
            let id = service.preparationID
            do {
                try await session.prepareTranslation()
                if service.preparationID == id, service.preparing { service.preparationMessage = "Idiomas locais prontos para tradução." }
            } catch {
                if service.preparationID == id, service.preparing { service.preparationMessage = error.localizedDescription }
            }
            if service.preparationID == id { service.preparing = false }
        }
    }
}
