# Local translation and interface localization

## Selected translation target

`Preferences.translationLanguage` stores the code selected in **Translate to**. The picker lists `LocalModelService.supportedLanguageCodes`, which comes from the installed Apple model. Names in the picker follow the interface language. The selected code, rather than the interface language or detected source language, is passed to the translator for both the current passage and a suggestion card. Demonstration cards and the standalone translation preview use the same preference.

Existing selections are preserved. Portuguese remains the initial fallback for an installation without a saved preference; it does not override a subsequent selection. Correcting and rewriting preserve the source language. Translation runs only when requested.

`TranslationPrompt` resolves the source and selected target names in English, includes their language codes, and explicitly tells the model to follow the selected target regardless of the interface language. For example, choosing Japanese produces `The user selected Japanese (ja) as the translation target.` Locale display names and weekday mappings are generated from Foundation locale data, rather than hard-coded translations.

## On-device translation

`LocalTranslationEngine` uses `SystemLanguageModel.default` and a fresh `LanguageModelSession` per chunk. It does not use the Translation framework, extra translation language packs, a cloud fallback, or a shared writing-review conversation. Apple Intelligence must still be enabled with its general on-device model available.

The optional translation action uses `WritingSuggestion.translationText` for the proposal shown in a card, or the written passage when requested from the menu. The result is read-only and supports loading, selection, copying, hiding, and retry. Translation does not accept a proposal or change the host editor.

Input is limited to 6,000 UTF-16 positions, split into up to 32 chunks of at most 800 positions with real token counting before inference. Oversized unbroken tokens are rejected. Translation uses plain-text generation with greedy sampling. The Japanese regression showed that a JSON string field could lead the model to append explanations and repetitive text. Response budgets scale from 128 to 900 tokens with input length; output near that budget is rejected rather than displayed as potentially truncated text. Known URLs and email addresses are separated from adjacent CJK prose before exact protected-content validation, without accepting changed addresses, links, numbers, or duplicate entities. The app preserves separators, checks numbers/URLs/email addresses, and rejects empty output, excessive expansion, or a confidently detected wrong output language. Named weekdays are checked against Foundation calendar data; a mismatch retries once and is then rejected. These checks do not prove full semantic fidelity.

The total deadline is 45 seconds. Closing a card, changing context or preferences, or blocking an app cancels/invalidates the request. Late responses cannot reopen a card or replace the current result. The memory-only cache separates text, source, target, and app identity, with 32 entries, a ten-minute lifetime, and a 32,000-unit cost budget.

## English source code and localization resources

Swift identifiers, comments, prompts, diagnostic messages, and localization keys are written in English. `en.lproj/Localizable.strings` uses English keys and identical English fallback values. `pt.lproj/Localizable.strings` uses the same English keys with Portuguese values. User-facing Portuguese belongs in localization resources, rather than Swift string literals.

Language-specific words required for rewrite validation live in `Resources/LanguageReviewRules.json`. Multilingual synthetic examples and regression inputs live in `Resources/LanguageSamples.json`, referenced through English keys. These are linguistic data, not implementation-language strings. Existing Portuguese and Unicode regression coverage is preserved.

`WritingResources` locates the bundle inside the distributed app first and uses `Bundle.module` during development. `L10n.text` and `L10n.format` retrieve interface translations and preserve format arguments. The package default is English; macOS preferred languages, including an app-specific override, choose the interface catalog. Portuguese supports pt-BR and pt-PT; other unavailable interface languages fall back to English. The translation target remains an independent preference.

The build copies `LocalScribe_WritingCore.bundle` into `Contents/Resources`, including localization catalogs, linguistic rules, and synthetic samples. A distributed app does not depend on the development checkout.

## Validation

- `python3 scripts/check-localizations.py`: checks English source keys, catalog coverage, format placeholders, and sample references.
- `swift run WritingCoreChecks`: checks prompt targets, weekday fidelity, edit ranges, Unicode, cache behavior, and rewrite safety.
- `LocalScribe --translation-configuration-smoke`: exercises every selectable target using isolated preferences and a deterministic translator. Checks persistence, the actual requested target, result labels, and cache separation without changing user preferences or calling the model.
- `LocalScribe --translation-japanese-smoke`: exercises real Japanese translation of the screenshot greeting, a short sentence, and a passage containing numbers, email, a URL, and a weekday; checks card loading/result transitions and cache reuse.
- `LocalScribe --translation-smoke`: adds real on-device translation, protected content, weekday checks, cache reuse, unsupported/oversized input, and request lifecycle checks.
- `LocalScribe --localization-smoke -AppleLanguages '(en)'` and `'(pt-BR)'`: verify localized interface strings per process without changing system language settings.

See [VALIDATION.md](VALIDATION.md) for recorded results and limits.
