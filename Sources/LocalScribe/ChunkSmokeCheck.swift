import Foundation
import WritingCore

@MainActor
enum ChunkSmokeCheck {
    struct Failure: Error { let reason: String }
    static func run() async throws {
        let text = String(repeating: "The report is ready. ", count: 1000) + "She go to school every days."
        guard let fragment = WritingFragment(fieldText: text, caret: text.utf16.count) else { throw Failure(reason: "No bounded fragment") }
        let units = ReviewChunker.window(in: fragment.text, caret: fragment.text.utf16.count)
        let cache = ReviewSessionCache()
        let service = LocalModelService()
        var pending: [WritingSuggestion] = []
        var maximumTokens = 0
        for unit in units where unit.isReviewable {
            let revised: String
            if let saved = cache.sentence(unit.text, language: "en", bundleID: "synthetic.chunks") { revised = saved }
            else {
                revised = try await service.revise(unit.text, language: "en")
                maximumTokens = max(maximumTokens, service.lastInputTokens)
                cache.saveSentence(unit.text, revised: revised, language: "en", bundleID: "synthetic.chunks")
            }
            pending += TextEdits.wordEdits(unit.text, revised).map {
                WritingSuggestion(kind: .correction, range: NSRange(location: unit.range.location + $0.range.location, length: $0.range.length),
                    original: $0.original, replacement: $0.replacement, language: "en", context: unit.text)
            }
        }
        guard pending.count == 2 else {
            print("synthetic-chunks=\(units.map { $0.text.debugDescription })")
            print("synthetic-edits=\(pending.map { "\($0.original.debugDescription) → \($0.replacement.debugDescription)" })")
            throw Failure(reason: "Expected two pending word corrections")
        }
        let firstPassCalls = service.generationCount
        for unit in units {
            guard cache.sentence(unit.text, language: "en", bundleID: "synthetic.chunks") != nil else { throw Failure(reason: "Unchanged chunk missed cache") }
        }
        guard service.generationCount == firstPassCalls else { throw Failure(reason: "Repeated unchanged generation") }
        let originalCard = pending.last!
        var interaction = SuggestionInteractionState()
        interaction.open(originalCard.id, pinned: false)
        interaction.set(.generating, for: originalCard.id)
        guard let target = units.last, let alternative = try await service.alternative(target.text, language: "en", excluding: []) else {
            throw Failure(reason: "No distinct optional wording")
        }
        maximumTokens = max(maximumTokens, service.lastInputTokens)
        let phrase = WritingSuggestion(kind: .style, range: target.range, original: target.text, replacement: alternative, language: "en", context: target.text)
        let combined = SuggestionLedger.proposing(phrase, alongside: pending)
        guard combined.filter({ $0.kind == .correction }).map(\.id) == pending.map(\.id) else { throw Failure(reason: "Phrase proposal removed pending corrections") }
        guard interaction.finish(for: originalCard.id, presenting: phrase.id) == phrase.id else { throw Failure(reason: "Result card not selected") }
        interaction.open(phrase.id, pinned: true)
        // Reproduce a pointer left over the original word after the asynchronous answer arrives.
        if interaction.allowsHover(on: originalCard.id) { interaction.open(originalCard.id, pinned: false) }
        guard interaction.openID == phrase.id, !interaction.state(for: originalCard.id).isBusy else {
            throw Failure(reason: "Original loading card stole the phrase result")
        }
        interaction.hide(); interaction.open(originalCard.id, pinned: false)
        guard !interaction.state(for: originalCard.id).isBusy else { throw Failure(reason: "Reopened correction stayed disabled") }
        let record: [String: Any] = ["result": "passed", "documentUTF16": text.utf16.count,
            "fragmentUTF16": fragment.text.utf16.count, "selectedChunks": units.count,
            "automaticModelCalls": firstPassCalls, "totalModelCalls": service.generationCount,
            "unchangedChunksReused": true, "pendingCorrectionsAfterProposal": pending.count,
            "combinedSuggestions": combined.count, "sourceUnchanged": text.hasSuffix(target.text),
            "maximumMeasuredInputTokens": maximumTokens, "contextSize": service.contextSize,
            "outputReserve": ReviewTokenBudget.responseReserve, "framingReserve": ReviewTokenBudget.framingReserve,
            "originalCorrectionUnlocked": true, "resultProtectedFromOldHover": true,
            "hostEditorTested": false]
        print(String(decoding: try JSONSerialization.data(withJSONObject: record, options: [.sortedKeys]), as: UTF8.self))
    }
}
