import Foundation

public enum SuggestionKind: Hashable, Sendable { case correction, coherence, style }

public struct ReviewAssessment: Sendable {
    public let revised: String
    public let sentenceIssue: Bool
    public let spellingOnly: Bool
    public init(revised: String, sentenceIssue: Bool, spellingOnly: Bool = false) {
        self.revised = revised; self.sentenceIssue = sentenceIssue; self.spellingOnly = spellingOnly
    }
}

public struct WritingSuggestion: Identifiable, Sendable {
    public let id: UUID
    public let kind: SuggestionKind
    public let range: NSRange
    public let original: String
    public let replacement: String
    public let language: String
    public let context: String
    public let isFragment: Bool
    /// The complete replacement passed grammar review before being offered.
    /// Partial/timeout fallbacks must not claim this coverage.
    public let hasReviewedReplacement: Bool
    public var scopeLabel: String { isFragment ? "trecho" : "frase" }
    public init(id: UUID = UUID(), kind: SuggestionKind, range: NSRange, original: String,
                replacement: String, language: String, context: String, isFragment: Bool = false,
                hasReviewedReplacement: Bool = false) {
        self.id = id; self.kind = kind; self.range = range; self.original = original
        self.replacement = replacement; self.language = language; self.context = context; self.isFragment = isFragment
        self.hasReviewedReplacement = hasReviewedReplacement
    }
}

public enum SuggestionLedger {
    /// Ranges here are absolute in the supplied text. Only unaffected, exact source matches survive.
    public static func rebasing(_ suggestions: [WritingSuggestion], after accepted: TextEdit,
                                from original: String, to updated: String,
                                replacingWholePassage: Bool = false) -> [WritingSuggestion]? {
        guard TextEdits.applying([accepted], to: original) == updated else { return nil }
        let source = updated as NSString
        let delta = accepted.replacement.utf16.count - accepted.range.length
        return suggestions.compactMap { item in
            let overlaps = NSIntersectionRange(item.range, accepted.range).length > 0
                || (item.range.length == 0 && NSLocationInRange(item.range.location, accepted.range))
                || (accepted.range.length == 0 && accepted.range.location >= item.range.location && accepted.range.location <= NSMaxRange(item.range))
                || (replacingWholePassage && item.range.length == 0
                    && item.range.location >= accepted.range.location && item.range.location <= NSMaxRange(accepted.range))
            guard !overlaps else { return nil }
            let location = item.range.location >= NSMaxRange(accepted.range) ? item.range.location + delta : item.range.location
            let range = NSRange(location: location, length: item.range.length)
            guard location >= 0, NSMaxRange(range) <= source.length, Range(range, in: updated) != nil,
                  source.substring(with: range) == item.original else { return nil }
            return item.positioned(at: range)
        }
    }

    /// Generating wording is not accepting an edit: pending corrections retain their IDs and ranges.
    public static func proposing(_ alternative: WritingSuggestion, alongside existing: [WritingSuggestion]) -> [WritingSuggestion] {
        let remaining = existing.filter { old in
            guard old.kind == .style else { return true }
            if old.range.length == 0 { return !NSLocationInRange(old.range.location, alternative.range) }
            return NSIntersectionRange(old.range, alternative.range).length == 0
        }
        return remaining + [alternative]
    }
}

public extension WritingSuggestion {
    var canApply: Bool { original != replacement }
    var correctionSourceLabel: String {
        if !original.isEmpty, original.allSatisfy({ $0.isWhitespace }) {
            return original.contains("\n") || original.contains("\r") ? "Quebra de linha" : "Espaço"
        }
        return original
    }
    var correctionActionLabel: String {
        guard replacement.isEmpty else { return replacement }
        if !original.isEmpty, original.allSatisfy({ $0.isWhitespace }) {
            return original.contains("\n") || original.contains("\r") ? "Remover quebra de linha" : "Remover espaço extra"
        }
        return original.isEmpty ? "Remover" : "Remover “\(original)”"
    }
    func positioned(at range: NSRange) -> WritingSuggestion {
        WritingSuggestion(id: id, kind: kind, range: range, original: original, replacement: replacement,
                          language: language, context: context, isFragment: isFragment,
                          hasReviewedReplacement: hasReviewedReplacement)
    }
}
