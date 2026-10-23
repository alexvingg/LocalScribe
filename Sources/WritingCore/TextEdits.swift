import Foundation

public struct TextEdit: Equatable, Sendable, Identifiable {
    public let range: NSRange
    public let original: String
    public let replacement: String
    public var id: String { "\(range.location):\(range.length):\(replacement)" }

    public init(range: NSRange, original: String, replacement: String) {
        self.range = range
        self.original = original
        self.replacement = replacement
    }
}

public enum TextEdits {
    /// A model proposal takes precedence at overlapping ranges. Independent spelling survives.
    public static func supplementing(_ primary: [TextEdit], with supplemental: [TextEdit], in text: String) -> [TextEdit] {
        guard applying(primary, to: text) != nil else { return [] }
        var result = primary
        for edit in supplemental {
            let conflicts = result.contains { other in
                NSIntersectionRange(edit.range, other.range).length > 0
                    || (other.range.length == 0 && other.range.location >= edit.range.location && other.range.location <= NSMaxRange(edit.range))
                    || (edit.range.length == 0 && edit.range.location >= other.range.location && edit.range.location <= NSMaxRange(other.range))
            }
            guard !conflicts, applying(result + [edit], to: text) != nil else { continue }
            result.append(edit)
        }
        return result.sorted { $0.range.location < $1.range.location }
    }

    /// Sentence/token ranges can include separators owned by the source editor.
    public static func preservingBoundaryWhitespace(of original: String, in revised: String) -> String {
        guard !original.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return original }
        let leading = String(original.prefix(while: { $0.isWhitespace }))
        let trailing = String(original.reversed().prefix(while: { $0.isWhitespace }).reversed())
        return leading + revised.trimmingCharacters(in: .whitespacesAndNewlines) + trailing
    }
    /// Mark/replace the whole affected word, rather than an arbitrary changed suffix.
    public static func wordEdits(_ original: String, _ revised: String) -> [TextEdit] {
        let edits = between(original, revised)
        let source = original as NSString
        var words: [NSRange] = []
        source.enumerateSubstrings(in: NSRange(location: 0, length: source.length), options: [.byWords, .substringNotRequired]) {
            _, range, _, _ in words.append(range)
        }
        guard !edits.isEmpty else { return [] }
        struct Group {
            var range: NSRange
            var editIndices: Set<Int>
        }
        var groups: [Group] = []
        for (index, edit) in edits.enumerated() {
            var range = edit.range
            if (edit.original + edit.replacement).contains(where: { $0.isLetter }) {
                for word in words {
                    let intersects = NSIntersectionRange(word, range).length > 0
                    let insideInsertion = range.length == 0 && range.location > word.location && range.location <= NSMaxRange(word)
                    if intersects || insideInsertion { range = NSUnionRange(range, word) }
                }
            }
            groups.append(Group(range: range, editIndices: [index]))
        }
        groups.sort {
            $0.range.location == $1.range.location ? $0.range.length > $1.range.length : $0.range.location < $1.range.location
        }
        var merged: [Group] = []
        for group in groups {
            if let last = merged.last {
                let overlaps = NSIntersectionRange(last.range, group.range).length > 0 || last.range == group.range
                // Boundary insertions belong to one group, never to two adjacent replacement cards.
                let insertionTouches = (group.range.length == 0 && group.range.location >= last.range.location && group.range.location <= NSMaxRange(last.range))
                    || (last.range.length == 0 && last.range.location >= group.range.location && last.range.location <= NSMaxRange(group.range))
                if overlaps || insertionTouches {
                    merged[merged.count - 1] = Group(range: NSUnionRange(last.range, group.range),
                        editIndices: last.editIndices.union(group.editIndices))
                    continue
                }
            }
            merged.append(group)
        }
        var expanded = merged.compactMap { group -> TextEdit? in
            // Track ownership explicitly: testing containment alone duplicates insertions at a range's end.
            let contained = group.editIndices.sorted().map { index in
                let edit = edits[index]
                return TextEdit(range: NSRange(location: edit.range.location - group.range.location, length: edit.range.length),
                                original: edit.original, replacement: edit.replacement)
            }
            let before = source.substring(with: group.range)
            guard let after = applying(contained, to: before) else { return nil }
            return TextEdit(range: group.range, original: before, replacement: after)
        }
        if applying(expanded, to: original) == revised {
            // Character alignment may reuse letters from a later source word. A card must
            // not end halfway through a target word when a correction expands an abbreviation.
            let target = revised as NSString
            var targetWords: [NSRange] = []
            target.enumerateSubstrings(in: NSRange(location: 0, length: target.length), options: [.byWords, .substringNotRequired]) {
                _, range, _, _ in targetWords.append(range)
            }
            func splitsWord(_ offset: Int) -> Bool {
                targetWords.contains { offset > $0.location && offset < NSMaxRange($0) }
            }
            while !expanded.isEmpty {
                var delta = 0
                var pair: Int?
                var unsafe = false
                for (index, edit) in expanded.enumerated() {
                    let start = edit.range.location + delta
                    let end = start + edit.replacement.utf16.count
                    if splitsWord(end), index + 1 < expanded.count { pair = index; break }
                    if splitsWord(start), index > 0 { pair = index - 1; break }
                    if splitsWord(start) || splitsWord(end) { unsafe = true; break }
                    delta += edit.replacement.utf16.count - edit.range.length
                }
                if let index = pair {
                    let left = expanded[index], right = expanded[index + 1]
                    let range = NSUnionRange(left.range, right.range)
                    let before = source.substring(with: range)
                    let relative = [left, right].map { TextEdit(range: NSRange(location: $0.range.location - range.location, length: $0.range.length), original: $0.original, replacement: $0.replacement) }
                    guard let after = applying(relative, to: before) else { break }
                    expanded.replaceSubrange(index...index + 1, with: [TextEdit(range: range, original: before, replacement: after)])
                } else if !unsafe { return expanded }
                else { break }
            }
        }
        // Retain an exact, reviewable proposal if grouping cannot be represented safely.
        // Never silently downgrade a word correction into disconnected letter edits.
        return [TextEdit(range: NSRange(location: 0, length: source.length), original: original, replacement: revised)]
    }

    /// Align graphemes, then convert to the UTF-16 ranges used by macOS text APIs.
    public static func between(_ original: String, _ revised: String) -> [TextEdit] {
        guard original != revised else { return [] }
        let before = Array(original), after = Array(revised)
        let difference = after.difference(from: before)
        var removed = Set<Int>(), inserted = Set<Int>()
        for change in difference {
            switch change {
            case .remove(let index, _, _): removed.insert(index)
            case .insert(let index, _, _): inserted.insert(index)
            }
        }
        var offsets = [0]
        for character in before { offsets.append(offsets.last! + String(character).utf16.count) }
        var i = 0, j = 0, edits: [TextEdit] = []
        while i < before.count || j < after.count {
            if i < before.count, j < after.count,
               !removed.contains(i), !inserted.contains(j), before[i] == after[j] {
                i += 1; j += 1; continue
            }
            let start = i
            var addition = ""
            while i < before.count && removed.contains(i) { i += 1 }
            while j < after.count && inserted.contains(j) { addition.append(after[j]); j += 1 }
            // Fail closed if an alignment is not representable by this traversal.
            guard i != start || !addition.isEmpty else { return [] }
            edits.append(TextEdit(range: NSRange(location: offsets[start], length: offsets[i] - offsets[start]),
                                  original: String(before[start..<i]), replacement: addition))
        }
        return applying(edits, to: original) == revised ? edits : []
    }

    public static func applying(_ edits: [TextEdit], to text: String) -> String? {
        let source = text as NSString
        let ordered = edits.sorted { $0.range.location < $1.range.location }
        var end = 0
        for edit in ordered {
            guard edit.range.location >= end, edit.range.location >= 0,
                  edit.range.length >= 0, NSMaxRange(edit.range) <= source.length,
                  Range(edit.range, in: text) != nil,
                  source.substring(with: edit.range) == edit.original else { return nil }
            end = NSMaxRange(edit.range)
        }
        let result = NSMutableString(string: text)
        for edit in ordered.reversed() { result.replaceCharacters(in: edit.range, with: edit.replacement) }
        return result as String
    }

    /// A conservative integrity check, not a claim of semantic correctness.
    public static func preservesProtectedContent(_ original: String, _ revised: String) -> Bool {
        func tokens(_ text: String) -> [String] {
            let expression = try! NSRegularExpression(pattern: #"https?://[^\s<>]+|[\p{L}\p{N}._%+-]+@[\p{L}\p{N}.-]+\.[\p{L}]{2,}|\p{N}+(?:[.,:/-]\p{N}+)*"#)
            let string = text as NSString
            return expression.matches(in: text, range: NSRange(location: 0, length: string.length))
                .map { string.substring(with: $0.range) }
        }
        return tokens(original) == tokens(revised)
    }
}

public struct WritingFragment: Equatable, Sendable {
    public let range: NSRange
    public let text: String
    public let isTruncated: Bool
    public init?(fieldText: String, caret: Int, maximumUTF16: Int = 6000) {
        let source = fieldText as NSString
        guard source.length > 0 else { return nil }
        let position = min(max(0, caret), source.length)
        let probe = position == source.length ? max(0, position - 1) : position
        var range = source.paragraphRange(for: NSRange(location: probe, length: 0))
        while range.length > 0 {
            let last = source.substring(with: NSRange(location: NSMaxRange(range) - 1, length: 1))
            guard last == "\n" || last == "\r" else { break }
            range.length -= 1
        }
        let paragraphRange = range
        if range.length > maximumUTF16 {
            let paragraph = source.substring(with: range)
            let window = ReviewChunker.window(in: paragraph, caret: position - range.location, limit: 6)
            guard let first = window.first, let last = window.last else { return nil }
            let local = NSUnionRange(first.range, last.range)
            range = NSRange(location: paragraphRange.location + local.location, length: local.length)
        }
        guard range.length > 0, range.length <= maximumUTF16,
              let swiftRange = Range(range, in: fieldText) else { return nil }
        let value = String(fieldText[swiftRange])
        guard !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
        self.range = range
        self.text = value
        self.isTruncated = range != paragraphRange
    }
}
