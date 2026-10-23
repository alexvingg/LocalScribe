import Foundation

enum WritingResources {
    static let bundle: Bundle = {
        if let url = Bundle.main.resourceURL?.appendingPathComponent("LocalScribe_WritingCore.bundle"),
           let bundle = Bundle(url: url) { return bundle }
        return .module
    }()

    static func load<Value: Decodable>(_ name: String, as type: Value.Type) -> Value {
        guard let url = bundle.url(forResource: name, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let value = try? JSONDecoder().decode(type, from: data) else {
            preconditionFailure("Missing or invalid bundled resource: \(name).json")
        }
        return value
    }
}

/// Multilingual synthetic data for demonstrations and regression checks, separate from source code.
public enum LanguageSamples {
    private static let values = WritingResources.load("LanguageSamples", as: [String: String].self)

    public static func text(_ key: String) -> String {
        guard let value = values[key] else { preconditionFailure("Missing language sample: \(key)") }
        return value
    }
}

struct LanguageReviewRules: Decodable {
    let references: [Set<String>]
    let negations: Set<String>
    let slang: Set<String>

    private static let languages = WritingResources.load("LanguageReviewRules", as: [String: LanguageReviewRules].self)
    static func rules(for language: String) -> LanguageReviewRules? { languages[language] }
}
