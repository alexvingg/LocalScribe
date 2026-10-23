import AppKit
import Combine
import UniformTypeIdentifiers
import WritingCore

@MainActor
final class Preferences: ObservableObject {
    private let defaults: UserDefaults
    @Published var languageMode: String { didSet { defaults.set(languageMode, forKey: "languageMode") } }
    @Published var paused: Bool { didSet { defaults.set(paused, forKey: "paused") } }
    @Published var translationLanguage: String { didSet { defaults.set(translationLanguage, forKey: "translationLanguage") } }
    @Published private(set) var blockedApplications: [BlockedApplication]

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        languageMode = defaults.string(forKey: "languageMode") ?? "automatic"
        paused = defaults.bool(forKey: "paused")
        translationLanguage = defaults.string(forKey: "translationLanguage") ?? "pt"
        blockedApplications = defaults.data(forKey: "blockedApplications")
            .flatMap { try? JSONDecoder().decode([BlockedApplication].self, from: $0) } ?? []
    }

    var manualLanguage: String? { languageMode == "automatic" ? nil : languageMode }
    var reviewPolicyIdentity: [String] { [languageMode, String(paused)] + blockedApplications.map(\.bundleID).sorted() }
    func isBlocked(_ bundleID: String?) -> Bool {
        ApplicationPolicy.isBlocked(bundleID, entries: blockedApplications)
    }

    func block(bundleID: String, name: String) {
        guard !isBlocked(bundleID) else { return }
        blockedApplications = ApplicationPolicy.adding(BlockedApplication(bundleID: bundleID, name: name), to: blockedApplications)
        saveBlocked()
    }

    func unblock(_ app: BlockedApplication) {
        blockedApplications.removeAll { $0.id == app.id }
        saveBlocked()
    }

    private func saveBlocked() {
        defaults.set(try? JSONEncoder().encode(blockedApplications), forKey: "blockedApplications")
    }

    func chooseApplication() {
        let picker = NSOpenPanel()
        picker.title = L10n.text("Desativar revisão em um aplicativo")
        picker.prompt = L10n.text("Bloquear")
        picker.allowedContentTypes = [.applicationBundle]
        picker.canChooseDirectories = false
        picker.allowsMultipleSelection = false
        picker.directoryURL = URL(fileURLWithPath: "/Applications")
        guard picker.runModal() == .OK, let url = picker.url,
              let bundle = Bundle(url: url), let identifier = bundle.bundleIdentifier else { return }
        let name = (bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String)
            ?? (bundle.object(forInfoDictionaryKey: "CFBundleName") as? String)
            ?? url.deletingPathExtension().lastPathComponent
        block(bundleID: identifier, name: name)
    }
}
