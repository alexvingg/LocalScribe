import Foundation

/// UI language follows macOS (including an app-specific language override).
/// Text detection and the translation destination are separate preferences.
public enum L10n {
    private static let resources = WritingResources.bundle
    public static var language: String { resources.preferredLocalizations.first ?? "en" }
    public static var locale: Locale { Locale(identifier: language) }

    public static func text(_ key: String) -> String {
        resources.localizedString(forKey: key, value: nil, table: "Localizable")
    }

    public static func format(_ key: String, _ arguments: CVarArg...) -> String {
        String(format: text(key), locale: locale, arguments: arguments)
    }

    public static func languageName(_ code: String) -> String {
        (locale.localizedString(forLanguageCode: code) ?? code).capitalized(with: locale)
    }

}
