import Foundation

public struct ReviewChunk: Equatable, Sendable {
    public let range: NSRange
    public let text: String
    public let isCompleteSentence: Bool
    public let isReviewable: Bool
}

public enum ReviewChunker {
    public static let maximumInputUTF16 = 800
    public static let maximumFieldUTF16 = 200_000

    /// Preserve sentence boundaries where possible. Long sentences split at whitespace, never in a word/URL.
    public static func chunks(in text: String, maximumUTF16: Int = maximumInputUTF16) -> [ReviewChunk] {
        guard maximumUTF16 > 0 else { return [] }
        let source = text as NSString
        var result: [ReviewChunk] = []
        for (sentence, _) in LanguageResolver.sentences(in: text) {
            var start = sentence.location
            let end = NSMaxRange(sentence)
            while start < end {
                var finish = min(start + maximumUTF16, end)
                if finish < end {
                    let cluster = source.rangeOfComposedCharacterSequence(at: finish)
                    finish = cluster.location
                    var boundary: Int?
                    if finish > start {
                        for index in stride(from: finish - 1, through: start, by: -1) {
                            if CharacterSet.whitespacesAndNewlines.contains(UnicodeScalar(source.character(at: index)) ?? "\u{0}") {
                                boundary = index + 1; break
                            }
                        }
                    }
                    if let boundary, boundary > start { finish = boundary }
                    else {
                        // A token larger than the budget is skipped intact, rather than changed in pieces.
                        finish = max(start + 1, finish)
                        while finish < end {
                            let cluster = source.rangeOfComposedCharacterSequence(at: finish)
                            let value = source.substring(with: cluster)
                            if value.allSatisfy({ $0.isWhitespace }) { break }
                            finish = NSMaxRange(cluster)
                        }
                    }
                }
                let range = NSRange(location: start, length: finish - start)
                if let swiftRange = Range(range, in: text) {
                    let value = String(text[swiftRange])
                    if !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        result.append(ReviewChunk(range: range, text: value, isCompleteSentence: range == sentence,
                            isReviewable: range.length <= maximumUTF16))
                    }
                }
                start = finish
            }
        }
        return result
    }

    public static func window(in text: String, caret: Int, limit: Int = 4) -> [ReviewChunk] {
        let units = chunks(in: text)
        guard !units.isEmpty, limit > 0 else { return [] }
        let focus = units.firstIndex { NSMaxRange($0.range) > caret } ?? units.count - 1
        let start = max(0, min(focus - limit / 2, units.count - limit))
        return Array(units[start..<min(start + limit, units.count)])
    }
}
