import Foundation
import WritingCore

@MainActor
enum ExperienceSmokeCheck {
    struct Failure: Error { let reason: String }
    static func run() async throws {
        let service = LocalModelService()
        let source = "She go to school every days."
        let first = try await service.assess(source, language: "en")
        print("agreement-assessment output=\(first.revised) sentenceIssue=\(first.sentenceIssue)")
        guard !first.sentenceIssue else { throw Failure(reason: "Local agreement mistaken for whole-sentence issue") }
        let pending = TextEdits.wordEdits(source, first.revised).map {
            WritingSuggestion(kind: .correction, range: $0.range, original: $0.original, replacement: $0.replacement, language: "en", context: source)
        }
        guard pending.count == 2, let accepted = pending.first(where: { $0.original == "go" }) else { throw Failure(reason: "Expected independent word corrections") }
        let calls = service.generationCount
        let edit = TextEdit(range: accepted.range, original: accepted.original, replacement: accepted.replacement)
        let updated = TextEdits.applying([edit], to: source)!
        guard let carried = SuggestionLedger.rebasing(pending, after: edit, from: source, to: updated),
              carried.count == 1, carried[0].original == "days", service.generationCount == calls else {
            throw Failure(reason: "Accepting one word lost another or needed generation")
        }
        print("incremental-accept remaining=\(carried[0].original) preservedID=\(carried[0].id == pending.last?.id) additionalModelCalls=0")
        for (text, language, shouldFlag) in [("i could can go to there.?", "en", true), ("I can will attend the meeting.", "en", true), ("I could go there.", "en", false), ("The report is ready.", "en", false), ("Ela pode ir amanhã.", "pt", false)] {
            let start = Date()
            let assessment = try await service.assess(text, language: language)
            let record: [String: Any] = ["input": text, "output": assessment.revised, "sentenceIssue": assessment.sentenceIssue,
                "seconds": Date().timeIntervalSince(start), "inputTokens": service.lastInputTokens]
            print(String(decoding: try JSONSerialization.data(withJSONObject: record, options: [.sortedKeys]), as: UTF8.self))
            guard assessment.sentenceIssue == shouldFlag else { throw Failure(reason: "Sentence issue classification mismatch") }
            if !shouldFlag, assessment.revised != text { throw Failure(reason: "Correct sentence was changed") }
        }
        print("experience-smoke=passed hostEditorTested=false")
    }
}
