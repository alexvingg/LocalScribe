import AppKit
import WritingCore

/// Dictionary corrections remain available when sentence inference is slow or refused.
/// Uses an already identified source language; never assumes the system language.
@MainActor
enum SystemSpellingService {
    static func edits(in text: String, language: String) -> [TextEdit] {
        let checker = NSSpellChecker.shared
        guard let dictionary = checker.availableLanguages.first(where: { $0 == language })
            ?? checker.availableLanguages.first(where: {
                Locale(identifier: $0).language.languageCode?.identifier == language
            }) else { return [] }
        let tag = NSSpellChecker.uniqueSpellDocumentTag()
        defer { checker.closeSpellDocument(withTag: tag) }
        let source = text as NSString
        var start = 0, inspected = 0, edits: [TextEdit] = []
        while start < source.length, inspected < 32 {
            let range = checker.checkSpelling(of: text, startingAt: start, language: dictionary,
                wrap: false, inSpellDocumentWithTag: tag, wordCount: nil)
            guard range.location != NSNotFound, range.location >= start, range.length > 0,
                  NSMaxRange(range) <= source.length, Range(range, in: text) != nil else { break }
            start = NSMaxRange(range); inspected += 1
            let original = source.substring(with: range)
            // Do not turn capitalized names into dictionary words.
            guard original.first?.isLowercase == true,
                  let replacement = checker.correction(forWordRange: range, in: text,
                    language: dictionary, inSpellDocumentWithTag: tag), replacement != original,
                  replacement.allSatisfy({ $0.isLetter || $0 == "'" || $0 == "’" || $0 == "-" }) else { continue }
            let edit = TextEdit(range: range, original: original, replacement: replacement)
            guard let revised = TextEdits.applying([edit], to: text),
                  TextEdits.preservesProtectedContent(text, revised) else { continue }
            edits.append(edit)
        }
        return edits
    }
}
