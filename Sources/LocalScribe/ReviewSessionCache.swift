import AppKit
import ApplicationServices
import WritingCore

struct SuggestionSignature: Hashable {
    let kind: SuggestionKind
    let range: NSRange
    let original: String
    let replacement: String
    init(_ suggestion: WritingSuggestion) {
        kind = suggestion.kind; range = suggestion.range
        original = suggestion.original; replacement = suggestion.replacement
    }
}

struct FieldRevisionKey: Hashable {
    let fieldID: UUID
    let text: String
    let fragmentRange: NSRange
    let analysisWindow: NSRange
    let languageMode: String
}

struct CachedFieldRevision {
    let suggestions: [WritingSuggestion]
    let ignored: Set<SuggestionSignature>
    let history: [String: [String]]
    let language: String
    let message: String
    let complete: Bool
}

/// Keeps text results only. AX elements identify the field; screen coordinates are never cached.
@MainActor
final class ReviewSessionCache {
    private struct Field {
        let id: UUID
        let pid: pid_t
        let bundleID: String
        let element: AXUIElement
        var lastSeen: Date
    }
    private struct SentenceKey: Hashable {
        let bundleID: String
        let language: String
        let text: String
        let style: Bool
    }
    private var fields: [Field] = []
    private var revisions = ReviewMemoryCache<FieldRevisionKey, CachedFieldRevision>(capacity: 12, maximumCost: 400_000, lifetime: 600)
    private var sentences = ReviewMemoryCache<SentenceKey, ReviewAssessment>(capacity: 64, maximumCost: 64_000, lifetime: 600)
    private var lastPrune = Date.distantPast
    private(set) var revisionHits = 0
    private(set) var sentenceHits = 0
    private(set) var modelCalls = 0

    var diagnostic: String { L10n.format("Memory cache: resumed %ld; sentences reused %ld; automatic review calls %ld", revisionHits, sentenceHits, modelCalls) }

    func key(for input: EditorSnapshot, languageMode: String) -> FieldRevisionKey {
        pruneIfNeeded()
        let id: UUID
        if let index = fields.firstIndex(where: { $0.pid == input.pid && $0.bundleID == input.bundleID && CFEqual($0.element, input.element) }) {
            fields[index].lastSeen = Date()
            id = fields[index].id
        } else {
            id = UUID()
            fields.append(Field(id: id, pid: input.pid, bundleID: input.bundleID, element: input.element, lastSeen: Date()))
            if fields.count > 12, let oldest = fields.min(by: { $0.lastSeen < $1.lastSeen }) {
                fields.removeAll { $0.id == oldest.id }
                revisions.removeAll { $0.fieldID == oldest.id }
            }
        }
        return FieldRevisionKey(fieldID: id, text: input.fieldText, fragmentRange: input.fragment.range,
            analysisWindow: input.analysisWindow, languageMode: languageMode)
    }

    func revision(for key: FieldRevisionKey) -> CachedFieldRevision? {
        guard let result = revisions.value(for: key) else { return nil }
        revisionHits += 1
        return result
    }

    func save(_ revision: CachedFieldRevision, for key: FieldRevisionKey) {
        let cost = key.text.utf16.count + revision.suggestions.reduce(0) { $0 + $1.original.utf16.count + $1.replacement.utf16.count + $1.context.utf16.count }
            + revision.history.reduce(0) { $0 + $1.key.utf16.count + $1.value.reduce(0) { $0 + $1.utf16.count } }
            + revision.ignored.reduce(0) { $0 + $1.original.utf16.count + $1.replacement.utf16.count }
        revisions.insert(revision, for: key, cost: cost)
    }

    func assessment(_ text: String, language: String, bundleID: String, style: Bool = false) -> ReviewAssessment? {
        let result = sentences.value(for: SentenceKey(bundleID: bundleID, language: language, text: text, style: style))
        if result != nil { sentenceHits += 1 }
        return result
    }

    func sentence(_ text: String, language: String, bundleID: String, style: Bool = false) -> String? {
        assessment(text, language: language, bundleID: bundleID, style: style)?.revised
    }

    func saveSentence(_ original: String, revised: String, language: String, bundleID: String, style: Bool = false, sentenceIssue: Bool = false, spellingOnly: Bool = false) {
        sentences.insert(ReviewAssessment(revised: revised, sentenceIssue: sentenceIssue, spellingOnly: spellingOnly),
                         for: SentenceKey(bundleID: bundleID, language: language, text: original, style: style),
                         cost: original.utf16.count + revised.utf16.count)
    }

    /// Only cache the exact, grammar-reviewed replacement after a verified write.
    /// A replacement inside a larger sentence does not certify its new context.
    func rememberReviewedReplacement(_ suggestion: WritingSuggestion, in fragment: String,
                                     range: NSRange, bundleID: String) -> Bool {
        guard suggestion.hasReviewedReplacement, !suggestion.replacement.isEmpty,
              let slice = Range(range, in: fragment), String(fragment[slice]) == suggestion.replacement else { return false }
        let touched = ReviewChunker.chunks(in: fragment).filter { NSIntersectionRange($0.range, range).length > 0 }
        let covered = touched.filter {
            $0.isReviewable && $0.range.location >= range.location && NSMaxRange($0.range) <= NSMaxRange(range)
        }
        for unit in covered {
            saveSentence(unit.text, revised: unit.text, language: suggestion.language, bundleID: bundleID)
        }
        return !touched.isEmpty && covered.count == touched.count
    }

    func willCallModel() { modelCalls += 1 }

    func pruneIfNeeded() {
        let now = Date()
        guard now.timeIntervalSince(lastPrune) >= 15 else { return }
        lastPrune = now
        revisions.prune(now: now); sentences.prune(now: now)
        let expired = Set(fields.filter { now.timeIntervalSince($0.lastSeen) >= 600 }.map(\.id))
        fields.removeAll { expired.contains($0.id) }
        revisions.removeAll { expired.contains($0.fieldID) }
    }

    func removeAll() {
        revisions.removeAll(); sentences.removeAll(); fields.removeAll()
    }
}
