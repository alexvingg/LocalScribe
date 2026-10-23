import Foundation
import WritingCore

@MainActor
enum ProposalStabilitySmokeCheck {
    struct Failure: Error { let reason: String }

    static func run() async throws {
        let model = LocalModelService()
        for (language, baseline) in [
            ("en", "hi my friend ! How are you?"),
            ("en", "She goes to school every day."),
            ("pt", "Olá, meu amigo ! Como você está ?")
        ] {
            let prepared = try await model.preparedAlternative(baseline, language: language, excluding: [])
            guard !prepared.text.isEmpty, TextEdits.preservesProtectedContent(baseline, prepared.text),
                  !prepared.text.contains(" !"), !prepared.text.contains(" ?") else {
                throw Failure(reason: "The complete proposal still contains punctuation spacing errors")
            }
            if baseline.hasPrefix("hi ") {
                guard prepared.text.hasPrefix("Hi,"), prepared.text.lowercased().contains("my friend"),
                      prepared.text.contains("How are you?") else {
                    throw Failure(reason: "The screenshot greeting was not fully corrected before presentation")
                }
            }
            let cache = ReviewSessionCache()
            let proposal = WritingSuggestion(kind: .style, range: NSRange(location: 0, length: baseline.utf16.count),
                original: baseline, replacement: prepared.text, language: language, context: baseline,
                hasReviewedReplacement: true)
            let beforeAcceptance = model.generationCount
            guard cache.rememberReviewedReplacement(proposal, in: prepared.text,
                range: NSRange(location: 0, length: prepared.text.utf16.count), bundleID: "dev.localscribe.test") else {
                throw Failure(reason: "A complete reviewed proposal lost its review coverage")
            }
            for unit in ReviewChunker.chunks(in: prepared.text) {
                guard let cached = cache.assessment(unit.text, language: language, bundleID: "dev.localscribe.test"),
                      cached.revised == unit.text, !cached.spellingOnly, !cached.sentenceIssue else {
                    throw Failure(reason: "Accepted text was not reusable without another inference")
                }
            }
            guard model.generationCount == beforeAcceptance,
                  cache.assessment(prepared.text + " more text", language: language, bundleID: "dev.localscribe.test") == nil else {
                throw Failure(reason: "Acceptance made another inference or incorrectly covered edited text")
            }
            let record: [String: Any] = ["language": language, "baseline": baseline, "proposal": prepared.text,
                "reviewedBeforePresentation": true, "additionalModelCallsAfterAcceptance": 0,
                "hostEditorTested": false]
            print(String(decoding: try JSONSerialization.data(withJSONObject: record, options: [.sortedKeys]), as: UTF8.self))
        }
        let cache = ReviewSessionCache()
        let fallback = WritingSuggestion(kind: .style, range: NSRange(location: 0, length: 5), original: "helo!",
            replacement: "hello!", language: "en", context: "helo!")
        guard !cache.rememberReviewedReplacement(fallback, in: "hello!", range: NSRange(location: 0, length: 6),
            bundleID: "dev.localscribe.test"), cache.assessment("hello!", language: "en", bundleID: "dev.localscribe.test") == nil else {
            throw Failure(reason: "An unchecked fallback was incorrectly marked reviewed")
        }
        let partial = WritingSuggestion(kind: .style, range: NSRange(location: 0, length: 6), original: "repotr",
            replacement: "report", language: "en", context: "repotr", hasReviewedReplacement: true)
        let sentence = "Please finish the report today."
        guard !cache.rememberReviewedReplacement(partial, in: sentence, range: (sentence as NSString).range(of: "report"),
            bundleID: "dev.localscribe.test"), cache.assessment(sentence, language: "en", bundleID: "dev.localscribe.test") == nil else {
            throw Failure(reason: "A mid-sentence edit incorrectly certified the surrounding sentence")
        }
        print("proposal-stability-smoke=passed uncheckedFallback=notCached partialContext=notCertified hostEditorTested=false")
    }
}
