import Foundation
import WritingCore

@MainActor
enum AlternativeSafetySmokeCheck {
    static func run() async throws {
        let service = LocalModelService()
        for (name, text, language) in [
            ("screenshot", "hellou miey fryend ! what's up.?", "en"),
            ("plain-greeting", "Hello, my friend! What's up?", "en"),
            ("ambiguous-english", "I saw her duck.", "en"),
            ("clear-english", "The meeting starts at nine tomorrow.", "en"),
            ("clear-portuguese", LanguageSamples.text("report.readyToSend.portuguese"), "pt")
        ] {
            let start = Date()
            let calls = service.generationCount
            var record: [String: Any] = ["case": name, "input": text, "hostEditorTested": false]
            do {
                let result = try await service.alternative(text, language: language, excluding: [])
                record["rewriteStatus"] = service.lastRewriteStatus ?? "none"
                if service.lastRewriteStatus == "unchanged", result == nil, service.generationCount - calls != 1 {
                    throw ReviewFailure.invalidResponse
                }
                if let result {
                    guard !AlternativePolicy.introducesSlang(result, original: text, language: language),
                          TextEdits.preservesProtectedContent(text, result) else { throw ReviewFailure.invalidResponse }
                }
                record["output"] = result ?? ""; record["changed"] = result != nil
                if name == "clear-english", let first = result {
                    let next = try await service.alternative(text, language: language, excluding: [first])
                    if let next {
                        guard AlternativePolicy.isDistinct(next, original: text, previous: [first]),
                              !AlternativePolicy.introducesSlang(next, original: text, language: language) else { throw ReviewFailure.invalidResponse }
                    }
                    record["secondVersion"] = next ?? ""
                }
            } catch ReviewFailure.unclearMeaning {
                record["blocked"] = "unclear-meaning"; record["changed"] = false
            } catch ReviewFailure.unsafeAlternative {
                record["blocked"] = "register-changed"; record["changed"] = false
            }
            record["seconds"] = Date().timeIntervalSince(start)
            record["modelCalls"] = service.generationCount - calls
            print(String(decoding: try JSONSerialization.data(withJSONObject: record, options: [.sortedKeys]), as: UTF8.self))
        }
    }
}
