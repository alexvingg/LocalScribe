import Foundation

public enum AlternativeContext {
    /// A short greeting or punctuation correction must not hide the rest of the message.
    public static func range(in text: String, anchor: Int, maximumUTF16: Int = ReviewChunker.maximumInputUTF16) -> NSRange? {
        let length = text.utf16.count
        guard length > 0, maximumUTF16 > 0 else { return nil }
        if length <= maximumUTF16 { return NSRange(location: 0, length: length) }
        let units = ReviewChunker.chunks(in: text, maximumUTF16: maximumUTF16)
        guard !units.isEmpty else { return nil }
        let index = units.firstIndex { NSLocationInRange(anchor, $0.range) }
            ?? units.firstIndex { $0.range.location >= anchor } ?? units.count - 1
        guard units[index].isReviewable else { return nil }
        var lower = index, upper = index
        while true {
            if lower > 0, units[lower - 1].isReviewable,
               NSMaxRange(units[upper].range) - units[lower - 1].range.location <= maximumUTF16 { lower -= 1; continue }
            if upper + 1 < units.count, units[upper + 1].isReviewable,
               NSMaxRange(units[upper + 1].range) - units[lower].range.location <= maximumUTF16 { upper += 1; continue }
            break
        }
        return NSUnionRange(units[lower].range, units[upper].range)
    }

    /// Build a complete baseline from independently verified, non-overlapping pending corrections.
    public static func correctedText(in text: String, range: NSRange, corrections: [TextEdit]) -> String? {
        guard let slice = Range(range, in: text) else { return nil }
        let original = String(text[slice])
        var local: [TextEdit] = []
        for edit in corrections.sorted(by: { $0.range.location < $1.range.location }) {
            guard edit.range.location >= range.location, NSMaxRange(edit.range) <= NSMaxRange(range) else { continue }
            let mapped = TextEdit(range: NSRange(location: edit.range.location - range.location, length: edit.range.length),
                original: edit.original, replacement: edit.replacement)
            if TextEdits.applying(local + [mapped], to: original) != nil { local.append(mapped) }
        }
        guard let revised = TextEdits.applying(local, to: original), TextEdits.preservesProtectedContent(original, revised) else { return nil }
        return revised
    }
}
