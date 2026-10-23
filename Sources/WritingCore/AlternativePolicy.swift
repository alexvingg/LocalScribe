import Foundation

public enum AlternativePolicy {
    /// Limits how far an optional wording can move; this is not a semantic equivalence proof.
    public static func isCloseRewrite(_ candidate: String, to source: String, language: String) -> Bool {
        func words(_ text: String) -> [String] {
            let value = text.lowercased().replacingOccurrences(of: "’", with: "'") as NSString
            let regex = try! NSRegularExpression(pattern: #"[\p{L}\p{N}]+(?:'[\p{L}\p{N}]+)*"#)
            return regex.matches(in: value as String, range: NSRange(location: 0, length: value.length)).map { value.substring(with: $0.range) }
        }
        let before = words(source), after = words(candidate)
        guard !before.isEmpty, !after.isEmpty, TextEdits.preservesProtectedContent(source, candidate) else { return false }
        var counts = Dictionary(before.map { ($0, 1) }, uniquingKeysWith: +), shared = 0
        for word in after where counts[word, default: 0] > 0 { shared += 1; counts[word, default: 0] -= 1 }
        guard Double(shared) / Double(max(before.count, after.count)) >= 0.5 else { return false }
        let groups: [Set<String>]
        let negations: Set<String>
        if language == "en" {
            groups = [["i", "me", "my", "mine"], ["we", "us", "our", "ours"], ["you", "your", "yours"], ["he", "him", "his"], ["she", "her", "hers"], ["they", "them", "their", "theirs"]]
            negations = ["no", "not", "never", "nothing", "without", "can't", "cannot", "don't", "doesn't", "isn't", "aren't", "won't", "wouldn't", "couldn't", "shouldn't"]
        } else if language == "pt" {
            groups = [["eu", "me", "meu", "minha", "meus", "minhas"], ["nós", "nos", "nosso", "nossa", "nossos", "nossas"], ["você", "tu", "te", "seu", "sua"], ["ele", "dele"], ["ela", "dela"], ["eles", "elas"]]
            negations = ["não", "nunca", "jamais", "sem"]
        } else { return true }
        let a = Set(before), b = Set(after)
        func references(_ values: [String]) -> Set<String> { Set(values.map { String($0.split(separator: "'").first ?? Substring($0)) }) }
        let from = references(before), to = references(after)
        return a.isDisjoint(with: negations) == b.isDisjoint(with: negations)
            && groups.allSatisfy { from.isDisjoint(with: $0) == to.isDisjoint(with: $0) }
    }

    /// Narrow register guard for observed failures; not a general semantic verifier.
    public static func introducesSlang(_ candidate: String, original: String, language: String) -> Bool {
        func tokens(_ text: String) -> [String] {
            let value = text.lowercased().replacingOccurrences(of: "’", with: "'") as NSString
            let regex = try! NSRegularExpression(pattern: #"[\p{L}\p{N}]+(?:'[\p{L}\p{N}]+)*"#)
            return regex.matches(in: value as String, range: NSRange(location: 0, length: value.length)).map { value.substring(with: $0.range) }
        }
        let markers: Set<String>
        switch language {
        case "en": markers = ["g'day", "howdy", "mate", "buddy", "pal", "ya", "y'all", "innit", "gonna", "wanna", "dude", "bro"]
        case "pt": markers = ["mano", "véi", "véio", "parça", "brother"]
        default: return false
        }
        let existing = Set(tokens(original)), proposed = Set(tokens(candidate))
        return !proposed.intersection(markers).subtracting(existing).isEmpty
    }

    /// Changes to spacing, case or punctuation alone do not count as a new phrasing.
    public static func isDistinct(_ candidate: String, original: String, previous: [String]) -> Bool {
        func normalized(_ text: String) -> String {
            String(text.lowercased().unicodeScalars.filter { CharacterSet.alphanumerics.contains($0) })
        }
        let value = normalized(candidate)
        return !value.isEmpty && !([original] + previous).contains { normalized($0) == value }
    }
}
