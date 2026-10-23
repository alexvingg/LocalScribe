import Foundation
import NaturalLanguage

public struct DetectedLanguage: Equatable, Sendable {
    public let code: String
    public let probability: Double
    public var displayName: String { Locale(identifier: "pt_BR").localizedString(forLanguageCode: code) ?? code }
}

public enum LanguageResolver {
    public static func hasEnoughContextForModel(_ text: String) -> Bool {
        text.filter({ $0.isLetter }).count >= 8 && text.split(whereSeparator: { $0.isWhitespace }).count >= 2
    }
    public static func detect(_ text: String, manual: String? = nil) -> DetectedLanguage? {
        if let manual, !manual.isEmpty { return DetectedLanguage(code: manual, probability: 1) }
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(text)
        let candidates = recognizer.languageHypotheses(withMaximum: 3).sorted { $0.value > $1.value }
        guard let best = candidates.first else { return nil }
        let margin = best.value - (candidates.dropFirst().first?.value ?? 0)
        // Short/ambiguous content waits for context instead of being forced into English.
        guard text.filter({ $0.isLetter }).count >= 4, best.value >= 0.65, margin >= 0.15 else { return nil }
        return DetectedLanguage(code: best.key.rawValue, probability: best.value)
    }

    public static func sentences(in text: String) -> [(NSRange, String)] {
        let tokenizer = NLTokenizer(unit: .sentence)
        tokenizer.string = text
        var results: [(NSRange, String)] = []
        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { range, _ in
            results.append((NSRange(range, in: text), String(text[range])))
            return true
        }
        return results
    }

    public static func sentenceWindow(in text: String, caret: Int, limit: Int = 4) -> [(NSRange, String)] {
        let units = sentences(in: text)
        guard !units.isEmpty, limit > 0 else { return [] }
        let focus = units.firstIndex { NSLocationInRange(caret, $0.0) } ?? units.count - 1
        let start = max(0, min(focus - limit / 2, units.count - limit))
        return Array(units[start..<min(start + limit, units.count)])
    }
}
