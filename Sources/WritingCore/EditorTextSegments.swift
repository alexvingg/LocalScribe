import Foundation

/// Relates rendered text leaves to the editor value without guessing repeated-word offsets.
public enum EditorTextSegments {
    public static func ranges(for leaves: [String], in text: String) -> [NSRange]? {
        let source = text as NSString
        var cursor = 0, result: [NSRange] = []
        for leaf in leaves {
            guard !leaf.isEmpty else { return nil }
            let match = source.range(of: leaf, options: .literal, range: NSRange(location: cursor, length: source.length - cursor))
            guard match.location != NSNotFound else { return nil }
            let gap = source.substring(with: NSRange(location: cursor, length: match.location - cursor))
            guard gap.allSatisfy({ $0.isWhitespace }), Range(match, in: text) != nil else { return nil }
            result.append(match); cursor = NSMaxRange(match)
        }
        guard source.substring(from: cursor).allSatisfy({ $0.isWhitespace }) else { return nil }
        return result
    }
}
