import AppKit
import SwiftUI
import Combine
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
    private var panel: TranslationPanel?
    private var task: Task<Void, Never>?
    private var deadline: Task<Void, Never>?
    private let engine = LocalTranslationEngine()
    private let translator: ((String, String, String) async throws -> String)?
    private let timeoutNanoseconds: UInt64
    var modelCallCount: Int { engine.modelCallCount }
    private var requestID = UUID()
    private var inlineID: UUID?
    var onInlineUpdate: ((UUID, SuggestionTranslationState) -> Void)?
    private struct Key: Hashable { let text: String; let source: String; let target: String; let bundleID: String }
    private var cache = ReviewMemoryCache<Key, String>(capacity: 32, maximumCost: 32_000, lifetime: 600)

    init(timeoutNanoseconds: UInt64 = 45_000_000_000,
         translator: ((String, String, String) async throws -> String)? = nil) {
        self.timeoutNanoseconds = timeoutNanoseconds
        self.translator = translator
    }

    func close() {
        if let inlineID { onInlineUpdate?(inlineID, .hidden) }
        inlineID = nil
        requestID = UUID(); task?.cancel(); task = nil
        deadline?.cancel(); deadline = nil
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

    func translate(_ text: String, source: String, target: String, bundleID: String, label: String, anchor: CGRect?, suggestionID: UUID? = nil) {
        close()
        inlineID = suggestionID
        sourceLabel = label
        targetName = L10n.languageName(target)
        if suggestionID == nil { showPanel(near: anchor) }
        guard source != target else { result = text; message = L10n.text("The text is already in the selected language."); updateInline(); return }
        let key = Key(text: text, source: source, target: target, bundleID: bundleID)
        if let saved = cache.value(for: key) { result = saved; updateInline(); return }
        isLoading = true
        updateInline()
        let id = requestID
        deadline = Task { [weak self] in
            do { try await Task.sleep(nanoseconds: self?.timeoutNanoseconds ?? 45_000_000_000) } catch { return }
            guard let self, self.requestID == id else { return }
            self.requestID = UUID(); self.task?.cancel()
            self.isLoading = false; self.message = L10n.text("Translation took too long. You can close it and try again.")
            self.updateInline()
        }
        task = Task { [weak self] in
            guard let self else { return }
            do {
                let value = try await self.translateOnDevice(text, source: source, target: target)
                guard self.requestID == id, !Task.isCancelled else { return }
                self.result = value
                self.cache.insert(value, for: key, cost: text.utf16.count + value.utf16.count)
            } catch {
                guard self.requestID == id else { return }
                if let failure = error as? TranslationFailure { self.message = failure.localizedDescription }
                else { self.message = L10n.text("Could not translate this passage. Close it and try again.") }
                let detail = error as NSError
                print("translation-error domain=\(detail.domain) code=\(detail.code) type=\(type(of: error))")
            }
            if self.requestID == id {
                self.isLoading = false; self.deadline?.cancel(); self.deadline = nil
                self.updateInline()
            }
        }
    }

    func translateOnDevice(_ text: String, source: String, target: String) async throws -> String {
        if let translator { return try await translator(text, source, target) }
        return try await engine.translate(text, source: source, target: target)
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
                Label(L10n.format("Translation · %@", service.targetName), systemImage: "character.bubble").font(.headline)
                Spacer()
                Button { service.close() } label: { Image(systemName: "xmark") }.buttonStyle(.plain).help(L10n.text("Close translation"))
            }
            Text(service.sourceLabel).font(.caption).foregroundStyle(.secondary)
            if service.isLoading {
                HStack { ProgressView().controlSize(.small); Text(L10n.text("Translating on your Mac…")).font(.callout) }
            }
            ScrollView {
                Text(service.result.isEmpty ? service.message : service.result)
                    .font(.system(size: 14)).textSelection(.enabled).frame(maxWidth: .infinity, alignment: .leading)
            }
            HStack {
                Text(L10n.text("Read-only · on device")).font(.caption2).foregroundStyle(.secondary)
                Spacer()
                Button(L10n.text("Copy"), systemImage: "doc.on.doc") {
                    NSPasteboard.general.clearContents(); NSPasteboard.general.setString(service.result, forType: .string)
                }.buttonStyle(.borderless).disabled(service.result.isEmpty)
            }
        }.padding(18).frame(width: 354, height: 249)
            .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 13))
            .overlay(RoundedRectangle(cornerRadius: 13).stroke(Color.primary.opacity(0.1)))
    }
}
