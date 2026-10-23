import Foundation
import WritingCore

@MainActor
enum RewriteMessageSmokeCheck {
    static func run() async throws {
        for (name, text) in [
            ("message-after-greeting", "Hey ! How are you ? I would like to mention something about my vacations with you, do you know that im a single ?"),
            ("slack-draft", "hy my frienda ! how are yoi ?")
        ] {
            let model = LocalModelService()
            var corrections: [TextEdit] = []
            for unit in ReviewChunker.chunks(in: text) {
                let assessment = try await model.assess(unit.text, language: "en")
                corrections.append(TextEdit(range: unit.range, original: unit.text, replacement: assessment.revised))
            }
            guard let range = AlternativeContext.range(in: text, anchor: 3),
                  let baseline = AlternativeContext.correctedText(in: text, range: range, corrections: corrections) else { throw ReviewFailure.invalidResponse }
            let result: String
            do { result = try await model.alternative(baseline, language: "en", excluding: []) ?? baseline }
            catch ReviewFailure.unsafeAlternative { result = baseline }
            catch ReviewFailure.unclearMeaning { result = baseline }
            guard range.length == text.utf16.count, !result.isEmpty,
                  AlternativePolicy.isCloseRewrite(result, to: baseline, language: "en"),
                  TextEdits.preservesProtectedContent(text, result),
                  name != "message-after-greeting" || (result.lowercased().contains("vacation") && result.lowercased().contains("single")) else {
                throw ReviewFailure.invalidResponse
            }
            let record: [String: Any] = ["case": name, "original": text, "correctedBaseline": baseline,
                "proposal": result, "fullMessage": true, "modelCalls": model.generationCount, "hostEditorTested": false]
            print(String(decoding: try JSONSerialization.data(withJSONObject: record, options: [.sortedKeys]), as: UTF8.self))
        }
        print("rewrite-message-smoke=passed")
    }
}
