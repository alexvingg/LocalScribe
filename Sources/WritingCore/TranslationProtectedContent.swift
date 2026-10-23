import Foundation

public enum TranslationProtectedContent {
    /// Separate known URLs/emails from adjacent CJK prose before checking their exact values.
    /// This also prevents the displayed URL from swallowing the following Japanese text.
    public static func preservingBoundaries(of original: String, in translated: String) -> String? {
        let expression = try! NSRegularExpression(pattern: #"https?://[^\s<>]+|[\p{L}\p{N}._%+-]+@[\p{L}\p{N}.-]+\.[\p{L}]{2,}"#)
        let source = original as NSString
        let entities = Set(expression.matches(in: original, range: NSRange(location: 0, length: source.length))
            .map { source.substring(with: $0.range) })
        let result = translated as NSString
        var boundaries = Set<Int>()
        func isCJK(at offset: Int) -> Bool {
            let range = result.rangeOfComposedCharacterSequence(at: offset)
            return result.substring(with: range).range(of: #"[\p{Han}\p{Hiragana}\p{Katakana}\p{Hangul}]"#,
                options: .regularExpression) != nil
        }
        for entity in entities {
            var search = NSRange(location: 0, length: result.length)
            while search.length > 0 {
                let found = result.range(of: entity, options: [], range: search)
                guard found.location != NSNotFound else { break }
                if found.location > 0, isCJK(at: found.location - 1) { boundaries.insert(found.location) }
                let end = NSMaxRange(found)
                if end < result.length, isCJK(at: end) { boundaries.insert(end) }
                search = NSRange(location: end, length: result.length - end)
            }
        }
        let normalized = NSMutableString(string: translated)
        for boundary in boundaries.sorted(by: >) { normalized.insert(" ", at: boundary) }
        let value = normalized as String
        return TextEdits.preservesProtectedContent(original, value) ? value : nil
    }
}
