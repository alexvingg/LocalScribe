import Foundation
import FoundationModels
import WritingCore

enum TranslationFailure: LocalizedError {
    case unavailable, unsupported, empty, invalid, tooLarge, refused

    var errorDescription: String? {
        switch self {
        case .unavailable: return L10n.text("Translation needs the local Apple Intelligence model to be ready in System Settings.")
        case .unsupported: return L10n.text("The local model does not support this language pair.")
        case .empty: return L10n.text("Translation returned no text. Try again.")
        case .invalid: return L10n.text("Could not validate the translation. The original text was preserved.")
        case .tooLarge: return L10n.text("This passage is too large to translate at once. Select a smaller part.")
        case .refused: return L10n.text("The Apple model could not translate this passage.")
        }
    }
}

/// Uses only SystemLanguageModel: no Translation framework, language downloads,
/// tools, cloud provider, or shared conversation with the writing reviewer.
@MainActor
final class LocalTranslationEngine {
    private let model = SystemLanguageModel.default
    private(set) var modelCallCount = 0

    func translate(_ text: String, source: String, target: String) async throws -> String {
        try Task.checkCancellation()
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw TranslationFailure.empty }
        guard text.utf16.count <= 6_000 else { throw TranslationFailure.tooLarge }
        guard case .available = model.availability else { throw TranslationFailure.unavailable }
        guard model.supportsLocale(Locale(identifier: source)), model.supportsLocale(Locale(identifier: target)) else {
            throw TranslationFailure.unsupported
        }
        guard !Locale.Language(identifier: source).isEquivalent(to: Locale.Language(identifier: target)) else { return text }

        let chunks = ReviewChunker.chunks(in: text)
        guard !chunks.isEmpty, chunks.count <= 32, chunks.allSatisfy(\.isReviewable) else { throw TranslationFailure.tooLarge }
        var edits: [TextEdit] = []
        for chunk in chunks {
            try Task.checkCancellation()
            let translated = try await translateChunk(chunk.text, source: source, target: target)
            edits.append(TextEdit(range: chunk.range, original: chunk.text, replacement: translated))
        }
        try Task.checkCancellation()
        guard let result = TextEdits.applying(edits, to: text) else { throw TranslationFailure.invalid }
        return result
    }

    private func translateChunk(_ text: String, source: String, target: String, retryingWeekday: Bool = false) async throws -> String {
        let request = TranslationPrompt(text: text, source: source, target: target, retryingWeekday: retryingWeekday)
        let instructions = request.instructions
        let prompt = request.input
        let inputTokens = try await model.tokenCount(for: Instructions(instructions))
            + model.tokenCount(for: prompt)
        guard ReviewTokenBudget.fits(inputTokens: inputTokens, contextSize: model.contextSize) else { throw TranslationFailure.tooLarge }
        try Task.checkCancellation()
        let session = LanguageModelSession(model: model, instructions: instructions)
        let responseLimit = TranslationPrompt.responseTokenLimit(for: text)
        let response: LanguageModelSession.Response<String>
        do {
            modelCallCount += 1
            response = try await session.respond(to: prompt,
                options: GenerationOptions(samplingMode: .greedy, maximumResponseTokens: responseLimit))
        } catch {
            if LocalModelService.isContentRefusal(error) { throw TranslationFailure.refused }
            throw error
        }
        try Task.checkCancellation()
        let value = response.content
        // Do not display a response that may have been cut off at the generation budget.
        guard try await model.tokenCount(for: value) < responseLimit - 8 else { throw TranslationFailure.invalid }
        try Task.checkCancellation()
        let bounded = TextEdits.preservingBoundaryWhitespace(of: text, in: value)
        guard let result = TranslationProtectedContent.preservingBoundaries(of: text, in: bounded) else { throw TranslationFailure.invalid }
        guard !result.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              result.utf16.count <= max(text.utf16.count * 4, 200) else { throw TranslationFailure.invalid }
        if !TranslationCalendarGuard.preservesWeekdays(text, result, source: source, target: target) {
            guard !retryingWeekday else { throw TranslationFailure.invalid }
            return try await translateChunk(text, source: source, target: target, retryingWeekday: true)
        }
        // Short translations often have ambiguous language detection; do not reject those.
        if result.filter(\.isLetter).count >= 24, let detected = LanguageResolver.detect(result),
           detected.probability > 0.9,
           detected.code != Locale(identifier: target).language.languageCode?.identifier {
            throw TranslationFailure.invalid
        }
        return result
    }
}
