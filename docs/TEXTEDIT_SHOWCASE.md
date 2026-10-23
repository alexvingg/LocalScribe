# TextEdit walkthrough and screenshot evidence

The README walkthrough uses synthetic English text from [readme-demo.txt](../Fixtures/readme-demo.txt): 112 words, 649 characters, four sentences. It was exercised in a real TextEdit rich-text document, at 18-point Helvetica, with LocalScribe 0.8.0 running normally, automatic source-language detection, and Portuguese as the translation destination.

## Observed behavior

1. The integration reported English and seven suggestions. The first word card proposed `has` → `have`.
2. Clicking **Rewrite sentence** showed **Rewriting on your Mac…**. The model produced a reviewed proposal covering the full passage, not just the selected word.
3. The output retained the report topic, Friday deadline, client, schedule, tomorrow-morning delivery, and request for feedback. It corrected agreement, spelling, the doubled modal, and `advise` → `advice`.
4. Clicking **Apply suggestion** changed the actual TextEdit document. The Accessibility value was read back and matched [readme-demo-reviewed.txt](../Fixtures/readme-demo-reviewed.txt) exactly.
5. The long-passage translation exposed a factual error: `Friday` became `quinta-feira`. This result was rejected as a showcase example. It motivated the unreleased 0.8.1 weekday safeguard described below.

A targeted shortcut attempt through automation inserted U+0012 into the synthetic word `understand`. This was interference from the test setup, not attributed to LocalScribe. The accepted full proposal removed it; the final editor readback matched the clean reviewed fixture. The earlier permission/focus steps and synthetic nature of the text prevent this walkthrough from establishing general compatibility with every editor.

## Images

- [Red underlines in TextEdit — screenshot provided by the author](images/textedit-review-underlines.png)

- [English passage before accepting](images/textedit-review-before.png)
- [Word correction card](images/textedit-word-correction.png)
- [Rewrite loading state](images/textedit-rewrite-loading.png)
- [Reviewed proposal](images/textedit-rewrite-suggestion.png)
- [Actual editor result](images/textedit-review-after.png)

The underlined editor screenshot was supplied by the author and is included unchanged. The remaining screenshots are native per-application captures. The capture API separates the editor and assistant windows; no synthetic overlay or reconstructed screenshot was used. The native `screencapture` command was attempted with authorization but macOS did not permit a display capture. The translation image used in the README is explicitly a separate, previously validated short example.

## Weekday safeguard — 0.8.1

`TranslationCalendarGuard` obtains weekday names from Foundation locale data. When named weekdays appear in the source, the local translation prompt supplies their target-language equivalents, and the returned text must preserve their identities and counts. A mismatch gets one bounded retry; another mismatch produces a validation failure rather than displaying the altered day.

This is a narrow integrity check, not a general semantic guarantee. It checks full weekday names, with locale-dependent limits; other dates, facts, names, and nuanced meaning still require human review. The existing number, URL, and email checks remain in place. The 0.8.0 release assets are unchanged.

The follow-up real-model test translated the first sentence with `sexta-feira` (1.90 seconds). All 63 core checks and the translation smoke suite passed. These checks do not certify the semantic accuracy of every possible translation.
