import AppKit
import SwiftUI
import Carbon
import ApplicationServices
import WritingCore

@main
struct LocalScribeMain {
    @MainActor static func main() {
        if CommandLine.arguments.contains("--localization-smoke") {
            let record: [String: String] = ["language": L10n.language, "settings": L10n.text("Configurações…"),
                "languageName": L10n.languageName("pt"), "format": L10n.format("Traduzir para %@", "Español"),
                "model": LocalModelService().availabilityDescription]
            print(String(decoding: try! JSONSerialization.data(withJSONObject: record, options: [.sortedKeys]), as: UTF8.self))
            return
        }
        if CommandLine.arguments.contains("--watch-editor") { EditorCapabilityCheck.watch(); return }
        if CommandLine.arguments.contains("--proposal-stability-smoke") {
            Task { @MainActor in
                do { try await ProposalStabilitySmokeCheck.run(); exit(0) }
                catch { print("proposal-stability-smoke=failed reason=\(error)"); exit(1) }
            }
            NSApplication.shared.run(); return
        }
        if CommandLine.arguments.contains("--rewrite-message-smoke") {
            Task { @MainActor in
                do { try await RewriteMessageSmokeCheck.run(); exit(0) }
                catch { print("rewrite-message-smoke=failed reason=\(error.localizedDescription)"); exit(1) }
            }
            NSApplication.shared.run(); return
        }
        if CommandLine.arguments.contains("--spelling-smoke") {
            let text = "This is a misstake, my friyend."
            let edits = SystemSpellingService.edits(in: text, language: "en")
            guard TextEdits.applying(edits, to: text) == "This is a mistake, my friend." else {
                print("spelling-smoke=failed edits=\(edits.count)"); exit(1)
            }
            let protected = "Visit https://friyend.example or email friyend@example.com."
            let checked = TextEdits.applying(SystemSpellingService.edits(in: protected, language: "en"), to: protected) ?? protected
            guard TextEdits.preservesProtectedContent(protected, checked) else { exit(1) }
            print("spelling-smoke=passed edits=\(edits.count) protectedContent=preserved modelCalls=0"); exit(0)
        }
        if CommandLine.arguments.contains("--review-probe") {
            let text = String(decoding: FileHandle.standardInput.readDataToEndOfFile(), as: UTF8.self)
            Task { @MainActor in
                let service = LocalModelService()
                do {
                    var language = LanguageResolver.detect(text)?.code
                    if language == nil { language = try await service.identifyLanguage(text) }
                    guard let language else { print("review-probe language=unknown"); exit(2) }
                    print("review-probe localSpellingEdits=\(SystemSpellingService.edits(in: text, language: language).count)")
                    let assessment = try await service.assess(text, language: language)
                    let edits = TextEdits.wordEdits(text, assessment.revised)
                    print("review-probe language=\(language) inputUTF16=\(text.utf16.count) changed=\(text != assessment.revised) edits=\(edits.count) sentenceIssue=\(assessment.sentenceIssue)")
                    exit(0)
                } catch {
                    print("review-probe failureType=\(type(of: error)) reason=\(error.localizedDescription)"); exit(1)
                }
            }
            NSApplication.shared.run(); return
        }
        if CommandLine.arguments.contains("--language-fallback-smoke") {
            Task { @MainActor in
                do {
                    let service = LocalModelService()
                    for (text, expected) in [("helo wrld", "en"), ("ola tudo beem", "pt"), ("bonjour mon amii", "fr"), ("guten morgn", "de")] {
                        let before = service.generationCount
                        let result = try await service.identifyLanguage(text)
                        let record: [String: Any] = ["input": text, "fastDetection": LanguageResolver.detect(text)?.code ?? "unknown",
                            "localModelLanguage": result ?? "unknown", "expected": expected,
                            "modelCalls": service.generationCount - before, "hostEditorTested": false]
                        print(String(decoding: try JSONSerialization.data(withJSONObject: record, options: [.sortedKeys]), as: UTF8.self))
                        guard result == expected else { throw ReviewFailure.invalidResponse }
                    }
                    let before = service.generationCount
                    let short = try await service.identifyLanguage("ok")
                    guard short == nil, service.generationCount == before else { throw ReviewFailure.invalidResponse }
                    print("language-fallback-smoke=passed shortAmbiguousCalls=0")
                    exit(0)
                } catch { print("language-fallback-error=\(error)"); exit(1) }
            }
            NSApplication.shared.run(); return
        }
        if CommandLine.arguments.contains("--alternative-safety-smoke") {
            Task { @MainActor in
                do { try await AlternativeSafetySmokeCheck.run(); exit(0) }
                catch { print("alternative-safety-error=\(error)"); exit(1) }
            }
            NSApplication.shared.run()
            return
        }
        if CommandLine.arguments.contains("--editor-capabilities") {
            let args = CommandLine.arguments
            let bundleID = args.firstIndex(of: "--bundle").flatMap { $0 + 1 < args.count ? args[$0 + 1] : nil }
            do { try EditorCapabilityCheck.run(bundleID: bundleID) } catch { print("editor-capabilities-error=\(error)") }
            return
        }
        if CommandLine.arguments.contains("--experience-smoke") {
            Task { @MainActor in
                do { try await ExperienceSmokeCheck.run(); exit(0) }
                catch { print("experience-smoke-error=\(error)"); exit(1) }
            }
            NSApplication.shared.run()
            return
        }
        if CommandLine.arguments.contains("--translation-smoke") {
            Task { @MainActor in
                do { try await TranslationSmokeCheck.run(); exit(0) }
                catch { print("translation-smoke=failed reason=\(error)"); exit(1) }
            }
            NSApplication.shared.run()
            return
        }
        if CommandLine.arguments.contains("--word-smoke") {
            Task { @MainActor in
                do {
                    let text = "ola tudo bem com vc mizere"
                    let revised = try await LocalModelService().revise(text, language: "pt")
                    let edits = TextEdits.wordEdits(text, revised)
                    let greeting = edits.first { NSIntersectionRange($0.range, NSRange(location: 0, length: 3)).length > 0 }
                    let record: [String: Any] = ["input": text, "output": revised,
                        "edits": edits.map { ["original": $0.original, "replacement": $0.replacement, "offset": $0.range.location, "length": $0.range.length] },
                        "wholeGreeting": greeting?.original == "ola", "roundTrip": TextEdits.applying(edits, to: text) == revised,
                        "hostEditorTested": false]
                    print(String(decoding: try JSONSerialization.data(withJSONObject: record, options: [.sortedKeys]), as: UTF8.self))
                    exit(greeting?.original == "ola" && TextEdits.applying(edits, to: text) == revised ? 0 : 2)
                } catch { print("word-smoke-error=\(error)"); exit(1) }
            }
            NSApplication.shared.run()
            return
        }
        if CommandLine.arguments.contains("--chunk-smoke") {
            Task { @MainActor in
                do { try await ChunkSmokeCheck.run(); exit(0) }
                catch { print("chunk-smoke-error=\(error)"); exit(1) }
            }
            NSApplication.shared.run()
            return
        }
        if CommandLine.arguments.contains("--cache-smoke") {
            Task { @MainActor in
                do { try await CacheSmokeCheck.run(); exit(0) }
                catch { print("cache-smoke-error=\(error)"); exit(1) }
            }
            NSApplication.shared.run()
            return
        }
        if CommandLine.arguments.contains("--diagnose") {
            let model = LocalModelService()
            print("model=\(model.availabilityDescription)")
            print("contextSize=\(model.contextSize)")
            print("accessibility=\(AXIsProcessTrusted())")
            for code in ["en", "pt", "es", "fr", "de"] { print("supports[\(code)]=\(model.supports(code))") }
            return
        }
        if CommandLine.arguments.contains("--model-smoke") || CommandLine.arguments.contains("--model-matrix") {
            Task { @MainActor in
                do {
                    var cases: [(String, String, Bool, Bool, String?)] = [
                        ("english-errors", "She go to school every days.", false, false, "She goes to school every day.")
                    ]
                    if CommandLine.arguments.contains("--model-matrix") {
                        cases += [
                            ("portuguese-errors", "ola, eu sou Ana.", false, false, "Olá, eu sou Ana."),
                            ("correct-english", "The meeting starts at nine tomorrow. Please bring the report.", false, false, "The meeting starts at nine tomorrow. Please bring the report."),
                            ("optional-portuguese", "Eu gostaria de informar que, neste momento, o relatório já se encontra concluído e pronto para ser enviado.", true, false, nil),
                            ("explicit-alternative", "O atalho para revisar uma seleção e o botão Copiar continuam úteis como recursos complementares.", true, true, nil)
                        ]
                    }
                    var failures = 0
                    for (label, text, style, explicit, expected) in cases {
                        guard let language = LanguageResolver.detect(text) else { failures += 1; continue }
                        let start = Date()
                        let service = LocalModelService()
                        let result: String
                        if explicit { result = try await service.alternative(text, language: language.code, excluding: []) ?? text }
                        else { result = try await service.revise(text, language: language.code, style: style) }
                        let record: [String: Any] = ["case": label, "language": language.code, "input": text,
                            "output": result, "style": style, "explicit": explicit, "changed": result != text, "seconds": Date().timeIntervalSince(start),
                            "expectedMatch": expected.map { $0 == result } ?? true,
                            "editCount": TextEdits.wordEdits(text, result).count,
                            "inputTokens": service.lastInputTokens, "contextSize": service.contextSize]
                        let bytes = try JSONSerialization.data(withJSONObject: record, options: [.sortedKeys])
                        print(String(decoding: bytes, as: UTF8.self))
                        if let expected, expected != result { failures += 1 }
                        if explicit && result == text { failures += 1 }
                        if explicit {
                            let next = try await service.alternative(text, language: language.code, excluding: [result])
                            let distinct = next.map { AlternativePolicy.isDistinct($0, original: text, previous: [result]) } ?? false
                            let bytes = try JSONSerialization.data(withJSONObject: ["case": "second-alternative", "output": next ?? "", "distinct": distinct], options: [.sortedKeys])
                            print(String(decoding: bytes, as: UTF8.self))
                            if !distinct { failures += 1 }
                        }
                    }
                    exit(failures == 0 ? 0 : 2)
                } catch { print("smoke-error=\(error)"); exit(1) }
            }
            NSApplication.shared.run()
            return
        }
        let application = NSApplication.shared
        let delegate = AppDelegate()
        application.delegate = delegate
        withExtendedLifetime(delegate) { application.run() }
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    private let preferences = Preferences()
    private lazy var coordinator = WritingCoordinator(preferences: preferences)
    private var statusItem: NSStatusItem!
    private var settingsWindow: NSWindow?
    private var previewWindow: NSWindow?
    private var hotKey: EventHotKeyRef?
    private var eventHandler: EventHandlerRef?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        let mainMenu = NSMenu()
        let applicationItem = NSMenuItem()
        mainMenu.addItem(applicationItem)
        let applicationMenu = NSMenu(title: "LocalScribe")
        applicationItem.submenu = applicationMenu
        add(L10n.text("Configurações…"), to: applicationMenu, action: #selector(showSettings), key: ",")
        add(L10n.text("Encerrar LocalScribe"), to: applicationMenu, action: #selector(quit), key: "q")
        NSApp.mainMenu = mainMenu
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem.button?.image = LocalScribeBrand.menuBarIcon
        let menu = NSMenu()
        menu.delegate = self
        statusItem.menu = menu
        registerShortcut()
        if CommandLine.arguments.contains("--preview-conservative-rewrite") {
            Task { @MainActor in
                let original = "hellou miey fryend ! what's up.?"
                do {
                    let result = try await coordinator.model.alternative(original, language: "en", excluding: [])
                    showInlineTranslationPreview(original: original, replacement: result ?? original,
                        notice: result == nil ? L10n.text("Não encontrei uma alternativa fiel que melhore este trecho. A sugestão atual foi mantida.") : nil,
                        title: L10n.text("LocalScribe · Ensaio de reformulação"))
                } catch {
                    showInlineTranslationPreview(original: original, replacement: original,
                        notice: error.localizedDescription, title: L10n.text("LocalScribe · Ensaio de reformulação"))
                }
            }
            return
        }
        if CommandLine.arguments.contains("--preview-inline-translation") { showInlineTranslationPreview(); return }
        if CommandLine.arguments.contains("--preview-cards") { showCardPreview(); return }
        if CommandLine.arguments.contains("--preview-translation") {
            coordinator.translation.translate("I could go there.", source: "en", target: "pt", bundleID: "dev.localscribe.demo",
                label: L10n.text("Exemplo artificial · sem capturar outros apps"), anchor: nil)
            return
        }
        coordinator.start()
        if CommandLine.arguments.contains("--show-settings") || !UserDefaults.standard.bool(forKey: "hasOpenedSettings") || !AXIsProcessTrusted() { showSettings() }
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        showSettings()
        return true
    }

    func applicationWillTerminate(_ notification: Notification) {
        coordinator.stop()
        if let hotKey { UnregisterEventHotKey(hotKey) }
        if let eventHandler { RemoveEventHandler(eventHandler) }
    }

    func menuNeedsUpdate(_ menu: NSMenu) {
        menu.removeAllItems()
        add(L10n.text("LocalScribe · modelo local"), to: menu, action: nil)
        add(String(coordinator.status.prefix(100)), to: menu, action: nil)
        add(L10n.format("Idioma: %@", coordinator.detectedLanguage), to: menu, action: nil)
        menu.addItem(.separator())
        add(preferences.paused ? L10n.text("Retomar revisão") : L10n.text("Pausar revisão"), to: menu, action: #selector(togglePause))
        if let app = coordinator.editor.lastExternalApplication, let id = app.bundleIdentifier {
            let item = add(L10n.format("Desativar em %@", app.localizedName ?? id), to: menu, action: #selector(blockCurrent))
            item.isEnabled = !preferences.isBlocked(id)
        }
        add(L10n.text("Revisar agora"), to: menu, action: #selector(reviewNow))
        add(L10n.text("Traduzir trecho atual"), to: menu, action: #selector(translateCurrent))
        add(coordinator.keyboardShortcutAvailable ? L10n.text("Mostrar sugestão (⌃⌥R)") : L10n.text("Mostrar sugestão"), to: menu, action: #selector(showSuggestion))
        menu.addItem(.separator())
        add(L10n.text("Configurações…"), to: menu, action: #selector(showSettings), key: ",")
        add(L10n.text("Encerrar LocalScribe"), to: menu, action: #selector(quit), key: "q")
    }

    @discardableResult private func add(_ title: String, to menu: NSMenu, action: Selector?, key: String = "") -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: key)
        item.target = self
        if action == nil { item.isEnabled = false }
        menu.addItem(item)
        return item
    }

    @objc private func togglePause() { preferences.paused.toggle() }
    @objc private func blockCurrent() { coordinator.blockCurrentApplication() }
    @objc private func reviewNow() { coordinator.reviewNow() }
    @objc private func translateCurrent() { coordinator.translateCurrentFragment() }
    @objc private func showSuggestion() { coordinator.showFirstSuggestion() }
    @objc private func quit() { NSApp.terminate(nil) }

    @objc private func showSettings() {
        if settingsWindow == nil {
            let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 610, height: 660),
                                  styleMask: [.titled, .closable, .miniaturizable], backing: .buffered, defer: false)
            window.title = "LocalScribe"
            window.isReleasedWhenClosed = false
            window.contentView = NSHostingView(rootView: SettingsView(preferences: preferences, coordinator: coordinator, showPreview: { [weak self] in self?.showCardPreview() }))
            window.center()
            settingsWindow = window
        }
        UserDefaults.standard.set(true, forKey: "hasOpenedSettings")
        NSApp.activate(ignoringOtherApps: true)
        settingsWindow?.makeKeyAndOrderFront(nil)
    }

    private func showCardPreview() {
        if previewWindow == nil {
            let view = NSHostingView(rootView: CardGalleryView())
            let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 734, height: 740),
                                  styleMask: [.titled, .closable, .miniaturizable], backing: .buffered, defer: false)
            window.title = L10n.text("LocalScribe · Prévia dos cartões")
            window.isReleasedWhenClosed = false
            window.contentView = view
            window.center()
            previewWindow = window
        }
        NSApp.activate(ignoringOtherApps: true)
        previewWindow?.makeKeyAndOrderFront(nil)
    }

    /// Production card and real local translation; synthetic text, no external editor access.
    private func showInlineTranslationPreview(original: String = "i could can go to there.?", replacement: String = "I could go there.",
                                              notice: String? = nil, title: String = L10n.text("LocalScribe · Exemplo de tradução no cartão")) {
        let suggestion = WritingSuggestion(kind: .style, range: NSRange(location: 0, length: original.utf16.count),
            original: original, replacement: replacement, language: "en", context: "")
        let feedback = CardFeedback()
        feedback.translationTargetName = L10n.languageName("pt")
        if let notice { feedback.states[suggestion.id] = .unavailable(notice) }
        let service = coordinator.translation
        let window = NSWindow(contentRect: NSRect(origin: .zero, size: SuggestionCardView.size(for: suggestion, state: feedback.state(for: suggestion.id))),
                              styleMask: [.titled, .closable], backing: .buffered, defer: false)
        window.title = title
        window.isReleasedWhenClosed = false
        service.onInlineUpdate = { id, state in
            feedback.translations[id] = state
            window.setContentSize(SuggestionCardView.size(for: suggestion, state: feedback.state(for: suggestion.id), translation: state))
        }
        window.contentView = NSHostingView(rootView: SuggestionCardView(suggestion: suggestion, feedback: feedback,
            accept: {}, dismiss: {}, alternatives: {}, close: { window.orderOut(nil) },
            translate: {
                service.translate(suggestion.translationText!, source: "en", target: "pt", bundleID: "dev.localscribe.demo",
                    label: L10n.text("Tradução da sugestão"), anchor: nil, suggestionID: suggestion.id)
            }, hideTranslation: { service.closeInline(for: suggestion.id) }))
        previewWindow = window
        window.center(); NSApp.activate(ignoringOtherApps: true); window.makeKeyAndOrderFront(nil)
    }

    private func registerShortcut() {
        var specification = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        InstallEventHandler(GetApplicationEventTarget(), { _, _, context in
            guard let context else { return OSStatus(eventNotHandledErr) }
            let owner = Unmanaged<AppDelegate>.fromOpaque(context).takeUnretainedValue()
            Task { @MainActor in owner.coordinator.showFirstSuggestion() }
            return noErr
        }, 1, &specification, Unmanaged.passUnretained(self).toOpaque(), &eventHandler)
        let identifier = EventHotKeyID(signature: 0x4C534352, id: 1)
        coordinator.keyboardShortcutAvailable = RegisterEventHotKey(UInt32(kVK_ANSI_R), UInt32(controlKey | optionKey), identifier,
                           GetApplicationEventTarget(), 0, &hotKey) == noErr
    }
}


private struct SettingsView: View {
    @ObservedObject var preferences: Preferences
    @ObservedObject var coordinator: WritingCoordinator
    let showPreview: () -> Void
    private let accent = Color(red: 0.22, green: 0.34, blue: 0.78)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 23) {
                HStack(spacing: 13) {
                    Image(nsImage: LocalScribeBrand.icon)
                        .resizable().interpolation(.high).scaledToFit()
                        .frame(width: 60, height: 60)
                        .accessibilityLabel("LocalScribe")
                    VStack(alignment: .leading, spacing: 4) {
                        Text("LocalScribe").font(.system(size: 25, weight: .semibold))
                        Text(L10n.text("Suas palavras, com mais clareza.")).font(.system(size: 13)).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(L10n.text("NO SEU MAC")).font(.system(size: 9, weight: .semibold)).tracking(1)
                        .foregroundStyle(accent).padding(.horizontal, 9).padding(.vertical, 6)
                        .background(accent.opacity(0.07), in: Capsule())
                }

                VStack(alignment: .leading, spacing: 13) {
                    HStack(spacing: 8) {
                        Circle().fill(coordinator.model.isAvailable ? Color.green : Color.orange).frame(width: 6, height: 6)
                        Text(coordinator.model.availabilityDescription).font(.system(size: 12, weight: .medium))
                        Spacer()
                        Image(systemName: "lock.shield").foregroundStyle(.secondary)
                    }
                    if !AXIsProcessTrusted() {
                        Text(L10n.text("Autorize Acessibilidade para revisar o texto nos seus aplicativos."))
                            .font(.callout).foregroundStyle(.secondary)
                        Button(L10n.text("Permitir Acessibilidade…")) { coordinator.editor.requestPermission() }.buttonStyle(CardPrimaryStyle())
                    }
                    HStack(alignment: .top, spacing: 8) {
                        Label(coordinator.status, systemImage: "text.bubble")
                            .font(.system(size: 11)).foregroundStyle(.secondary).lineLimit(3)
                        Spacer(minLength: 4)
                        Button(L10n.text("Revisar agora")) { coordinator.reviewNow() }
                            .buttonStyle(.borderless).font(.system(size: 11)).disabled(coordinator.snapshot == nil)
                    }
                    Rectangle().fill(Color.primary.opacity(0.06)).frame(height: 1)
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(L10n.text("Revisão durante a escrita")).font(.system(size: 13, weight: .medium))
                            Text(preferences.paused ? L10n.text("Pausada até você retomar.") : L10n.text("Sugestões discretas nos campos compatíveis."))
                                .font(.system(size: 11)).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Toggle(L10n.text("Revisão durante a escrita"), isOn: Binding(
                            get: { !preferences.paused }, set: { preferences.paused = !$0 }
                        )).labelsHidden().toggleStyle(.switch)
                    }
                    HStack {
                        Text(L10n.text("Idioma do texto")).font(.system(size: 12))
                        Spacer()
                        Picker(L10n.text("Idioma do texto"), selection: $preferences.languageMode) {
                            Text(L10n.text("Detectar automaticamente")).tag("automatic")
                            ForEach(coordinator.model.supportedLanguageCodes, id: \.self) { code in
                                Text(L10n.languageName(code)).tag(code)
                            }
                        }.labelsHidden().fixedSize()
                    }
                    HStack {
                        Text(L10n.text("Traduzir para")).font(.system(size: 12))
                        Spacer()
                        Picker(L10n.text("Idioma da tradução"), selection: $preferences.translationLanguage) {
                            ForEach(coordinator.model.supportedLanguageCodes, id: \.self) { code in
                                Text(L10n.languageName(code)).tag(code)
                            }
                        }.labelsHidden().fixedSize()
                    }
                    Text(L10n.text("Tradução pela Apple Intelligence · sem pacotes de idiomas adicionais."))
                        .font(.system(size: 11)).foregroundStyle(.secondary)
                }.padding(17).background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 14))

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(L10n.text("Onde não revisar")).font(.system(size: 14, weight: .semibold))
                            Text(L10n.text("O texto desses apps não será lido.")).font(.system(size: 11)).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button { preferences.chooseApplication() } label: {
                            Label(L10n.text("Adicionar app"), systemImage: "plus").font(.system(size: 11, weight: .medium))
                        }.buttonStyle(.plain).foregroundStyle(accent)
                    }
                    if preferences.blockedApplications.isEmpty {
                        HStack(spacing: 10) {
                            Image(systemName: "app.dashed").font(.system(size: 21)).foregroundStyle(.tertiary)
                            Text(L10n.text("Nenhum aplicativo bloqueado")).font(.system(size: 12)).foregroundStyle(.secondary)
                            Spacer()
                        }.padding(16).frame(maxWidth: .infinity)
                            .background(Color.primary.opacity(0.025), in: RoundedRectangle(cornerRadius: 11))
                    } else {
                        VStack(spacing: 0) {
                            ForEach(preferences.blockedApplications) { app in
                                HStack(spacing: 10) {
                                    Image(systemName: "app.fill").foregroundStyle(.secondary)
                                    Text(app.name).font(.system(size: 12))
                                    Spacer()
                                    Button { preferences.unblock(app) } label: { Image(systemName: "xmark.circle.fill").foregroundStyle(.tertiary) }
                                        .buttonStyle(.plain).help(L10n.text("Remover do bloqueio"))
                                        .accessibilityLabel(L10n.format("Remover %@ do bloqueio", app.name))
                                }.padding(12).accessibilityElement(children: .contain)
                            }
                        }.background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 11))
                    }
                }

                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "cursorarrow.rays").foregroundStyle(accent).padding(.top, 2)
                    VStack(alignment: .leading, spacing: 5) {
                        Text(L10n.text("Passe o ponteiro para revisar")).font(.system(size: 12, weight: .medium))
                        Text(L10n.text("Vermelho para correções. Azul para reformulações. Clique na sugestão para aplicar."))
                            .font(.system(size: 11)).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                    if coordinator.keyboardShortcutAvailable {
                        Text("⌃ ⌥ R").font(.system(size: 11, design: .monospaced)).foregroundStyle(.secondary)
                            .padding(7).background(Color.primary.opacity(0.045), in: RoundedRectangle(cornerRadius: 6))
                    }
                }

                DisclosureGroup(L10n.text("Exemplos e diagnóstico")) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Button("TextEdit") { openExample(in: "com.apple.TextEdit") }
                            Button("Sublime Text") { openExample(in: "com.sublimetext.4") }
                            Button("Chrome") { openExample(in: "com.google.Chrome") }
                            Button(L10n.text("Ver cartões"), action: showPreview)
                        }.buttonStyle(.borderless)
                        Button(L10n.text("Abrir primeira sugestão")) { coordinator.showFirstSuggestion() }
                            .disabled(coordinator.suggestionCount == 0).buttonStyle(.borderless)
                        Text(coordinator.status).font(.caption).foregroundStyle(.secondary)
                        Button(L10n.text("Diagnóstico do editor")) {
                            let alert = NSAlert()
                            alert.messageText = coordinator.status
                            alert.informativeText = coordinator.geometryDiagnostic
                            alert.runModal()
                        }.buttonStyle(.borderless)
                    }.padding(.top, 10)
                }.font(.system(size: 11)).foregroundStyle(.secondary)

                HStack(spacing: 5) {
                    Image(systemName: "lock.fill")
                    Text(L10n.text("Apple Intelligence local · Sem conta ou assinatura"))
                }.font(.system(size: 10)).foregroundStyle(.tertiary)
            }.padding(28)
        }.frame(width: 610, height: 660).background(Color(nsColor: .windowBackgroundColor)).tint(accent)
    }

    private func openExample(in bundleID: String) {
        guard let application = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) else { return }
        let browser = bundleID == "com.google.Chrome"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("LocalScribe-Exemplo-\(UUID().uuidString.prefix(8))." + (browser ? "html" : "txt"))
        let content = browser ? """
        <!doctype html><html lang="\(L10n.language)"><meta charset="utf-8"><title>\(L10n.text("Exemplo LocalScribe"))</title>
        <body style="font:20px system-ui;max-width:800px;margin:60px auto"><h1>\(L10n.text("Exemplo LocalScribe"))</h1>
        <p>\(L10n.text("Frase artificial para testar a revisão local. Nenhum recurso externo é carregado por este arquivo."))</p>
        <textarea autofocus spellcheck="false" aria-label="\(L10n.text("Texto artificial do LocalScribe"))" style="font:26px/1.6 system-ui;width:90%;height:220px;padding:20px">She go to school every days.</textarea></body></html>
        """ : "She go to school every days."
        do {
            try content.write(to: url, atomically: true, encoding: .utf8)
            let options = NSWorkspace.OpenConfiguration()
            options.activates = true
            NSWorkspace.shared.open([url], withApplicationAt: application, configuration: options) { app, _ in
                app?.activate(options: [.activateAllWindows])
            }
        } catch {
            let alert = NSAlert()
            alert.messageText = L10n.text("Não foi possível abrir o exemplo")
            alert.informativeText = error.localizedDescription
            alert.runModal()
        }
    }
}
