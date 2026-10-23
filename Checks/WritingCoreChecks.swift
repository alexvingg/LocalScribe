import Foundation
import WritingCore

struct WritingCoreChecks {
    func testTranslationCannotChangeCalendarWeekdays() {
        expectTrue(TranslationCalendarGuard.preservesWeekdays("Before Friday.", "Antes da sexta-feira.", source: "en", target: "pt"))
        expectFalse(TranslationCalendarGuard.preservesWeekdays("Before Friday.", "Antes da quinta-feira.", source: "en", target: "pt"))
        expectFalse(TranslationCalendarGuard.preservesWeekdays("Friday and Monday.", "Sexta-feira e terça-feira.", source: "en", target: "pt"))
        expectTrue(TranslationCalendarGuard.preservesWeekdays("Monday and Friday.", "Lunes y viernes.", source: "en", target: "es"))
        expectTrue(TranslationCalendarGuard.preservesWeekdays("Friday.", "星期五之前。", source: "en", target: "zh-Hans"))
        expectFalse(TranslationCalendarGuard.preservesWeekdays("Friday.", "星期四之前。", source: "en", target: "zh-Hans"))
        expectTrue(TranslationCalendarGuard.instruction("Before Friday.", source: "en", target: "pt").contains("sexta-feira"))
        expectEqual(TranslationCalendarGuard.instruction("A sunny day.", source: "en", target: "pt"), "")
    }
    func testReviewedPassageConsumesBoundaryPunctuationOnlyForPassages() {
        let original = "hello"
        let punctuation = WritingSuggestion(kind: .correction, range: NSRange(location: 5, length: 0),
            original: "", replacement: "!", language: "en", context: original)
        let word = TextEdit(range: NSRange(location: 0, length: 5), original: original, replacement: "Hello")
        let wordRemaining = SuggestionLedger.rebasing([punctuation], after: word, from: original, to: "Hello")!
        expectEqual(wordRemaining.count, 1)
        let passage = TextEdit(range: word.range, original: original, replacement: "Hello!")
        expectEqual(SuggestionLedger.rebasing([punctuation], after: passage, from: original, to: "Hello!",
            replacingWholePassage: true)!.count, 0)
    }
    func testReviewedPhraseAcceptanceKeepsIndependentCorrections() {
        let text = "hi my friend ! how are u ? Other erorr."
        let range = (text as NSString).range(of: "hi my friend ! how are u ?")
        let proposal = WritingSuggestion(kind: .style, range: range, original: (text as NSString).substring(with: range),
            replacement: "Hi, my friend! How are you?", language: "en", context: text, hasReviewedReplacement: true)
        let outside = WritingSuggestion(kind: .correction, range: (text as NSString).range(of: "erorr"),
            original: "erorr", replacement: "error", language: "en", context: text)
        let overlap = WritingSuggestion(kind: .correction, range: (text as NSString).range(of: "u"),
            original: "u", replacement: "you", language: "en", context: text)
        let edit = TextEdit(range: range, original: proposal.original, replacement: proposal.replacement)
        let revised = TextEdits.applying([edit], to: text)!
        let pending = SuggestionLedger.rebasing([proposal, overlap, outside], after: edit, from: text, to: revised)!
        expectEqual(pending.count, 1)
        expectEqual(pending.first?.id, outside.id)
        expectEqual((revised as NSString).substring(with: pending[0].range), "erorr")
        expectTrue(proposal.positioned(at: NSRange(location: 10, length: range.length)).hasReviewedReplacement)
        expectFalse(outside.hasReviewedReplacement)
    }
    func testRewriteIncludesMessageAfterGreetingAndPunctuation() {
        let text = "Hey ! How are you ? I would like to mention something about my vacations with you, do you know that im a single ?"
        let range = AlternativeContext.range(in: text, anchor: 3)!
        expectEqual(range, NSRange(location: 0, length: text.utf16.count))
        let corrected = "Hey! How are you? I would like to mention something about my vacations with you, do you know that I'm single?"
        let baseline = AlternativeContext.correctedText(in: text, range: range, corrections: TextEdits.wordEdits(text, corrected))
        expectEqual(baseline, corrected)
        expectTrue(baseline!.contains("vacations with you"))
    }
    func testRewriteContextIsBoundedAndKeepsUnicode() {
        let text = String(repeating: "First sentence. ", count: 70) + "Unique 🧑🏽‍💻 ending."
        let anchor = (text as NSString).range(of: "Unique").location
        let range = AlternativeContext.range(in: text, anchor: anchor, maximumUTF16: 120)!
        expectTrue(range.length <= 120)
        expectTrue(NSLocationInRange(anchor, range))
        expectTrue(Range(range, in: text) != nil)
    }
    func testRewriteStaysCloseToIdeaAndReferences() {
        expectTrue(AlternativePolicy.isCloseRewrite("I'd like to discuss my vacations with you.", to: "I would like to discuss my vacations with you.", language: "en"))
        expectFalse(AlternativePolicy.isCloseRewrite("Let's plan our vacation without you.", to: "I would like to discuss my vacations with you.", language: "en"))
        expectFalse(AlternativePolicy.isCloseRewrite("I can't attend the meeting.", to: "I can attend the meeting.", language: "en"))
        expectFalse(AlternativePolicy.isCloseRewrite("Send 20 reports.", to: "Send 12 reports.", language: "en"))
    }
    func testWhitespaceRemovalCardExplainsTheTarget() {
        let space = WritingSuggestion(kind: .correction, range: NSRange(location: 3, length: 1), original: " ", replacement: "", language: "en", context: "Hey !")
        expectEqual(space.correctionSourceLabel, L10n.text("Espaço"))
        expectEqual(space.correctionActionLabel, L10n.text("Remover espaço extra"))
        expectTrue(space.canApply)
    }
    func testIndependentSpellingSurvivesModelProposalAndNoChange() {
        let text = "my friyend has two cat."
        let spelling = TextEdits.wordEdits(text, "my friend has two cat.")
        let model = TextEdits.wordEdits(text, "my friyend has two cats.")
        let merged = TextEdits.supplementing(model, with: spelling, in: text)
        expectEqual(TextEdits.applying(merged, to: text), "my friend has two cats.")
        expectEqual(TextEdits.applying(TextEdits.supplementing([], with: spelling, in: text), to: text), "my friend has two cat.")
    }
    func testModelOverlapWinsAndStaleSpellingIsRejected() {
        let text = "my friyend"
        let model = TextEdits.wordEdits(text, "my friends")
        let spelling = TextEdits.wordEdits(text, "my friend")
        expectEqual(TextEdits.applying(TextEdits.supplementing(model, with: spelling, in: text), to: text), "my friends")
        let stale = TextEdit(range: NSRange(location: 3, length: 7), original: "another", replacement: "friend")
        expectEqual(TextEdits.supplementing([], with: [stale], in: text), [])
    }
    func testWebEditorUsesVerifiedNativeInputInAnyApplication() {
        expectEqual(EditorCompatibility.editStrategy(selectionWritable: true, selectedTextWritable: true,
            valueWritable: true, webContent: true), .nativeInput)
        expectEqual(EditorCompatibility.editStrategy(selectionWritable: true, selectedTextWritable: false,
            valueWritable: true, webContent: true), .nativeInput)
    }
    func testNativeEditorPrefersAccessibilityAndUsesInputWhenNeeded() {
        expectEqual(EditorCompatibility.editStrategy(selectionWritable: true, selectedTextWritable: true,
            valueWritable: true, webContent: false), .accessibility)
        expectEqual(EditorCompatibility.editStrategy(selectionWritable: true, selectedTextWritable: false,
            valueWritable: true, webContent: false), .nativeInput)
    }
    func testReadOnlyAndSecureEditorsNeverGetAnInputFallback() {
        expectEqual(EditorCompatibility.editStrategy(selectionWritable: true, selectedTextWritable: false,
            valueWritable: false, webContent: true), .readOnly)
        expectEqual(EditorCompatibility.editStrategy(selectionWritable: false, selectedTextWritable: true,
            valueWritable: true, webContent: false), .readOnly)
        expectEqual(EditorCompatibility.editStrategy(selectionWritable: true, selectedTextWritable: true,
            valueWritable: true, webContent: true, secure: true), .readOnly)
    }
    func testLanguageFallbackRequiresContextInsteadOfAForcedDefault() {
        for text in ["ok", "ola", "helo", "12345", "https://example.com"] {
            expectFalse(LanguageResolver.hasEnoughContextForModel(text))
        }
        expectTrue(LanguageResolver.hasEnoughContextForModel("hellou miey fryend"))
        expectTrue(LanguageResolver.hasEnoughContextForModel("ola tudo beem"))
        expectTrue(LanguageResolver.hasEnoughContextForModel("bonjour mon amii"))
    }
    func testScreenshotRewriteCannotIntroduceRegionalSlang() {
        let source = "hellou miey fryend ! what's up.?"
        expectTrue(AlternativePolicy.introducesSlang("g'day, mate! how ya goin'!", original: source, language: "en"))
        expectTrue(AlternativePolicy.introducesSlang("greetings, mate ! how are things ?", original: source, language: "en"))
        expectTrue(AlternativePolicy.introducesSlang("Hey, buddy! What's up?", original: source, language: "en"))
        expectFalse(AlternativePolicy.introducesSlang("Hello, my friend! What's up?", original: source, language: "en"))
    }

    func testExistingDialectIsPreservedAndWholeWordsAreMatched() {
        expectFalse(AlternativePolicy.introducesSlang("G’day, mate!", original: "g'day mate", language: "en"))
        expectFalse(AlternativePolicy.introducesSlang("My teammate is here.", original: "My colleague is here.", language: "en"))
        expectTrue(AlternativePolicy.introducesSlang("G’day, mate!", original: "Hello, my friend!", language: "en"))
    }

    func testPortugueseRewriteDoesNotInventSlang() {
        expectTrue(AlternativePolicy.introducesSlang("Fala, mano! Tudo certo?", original: "Olá! Tudo bem?", language: "pt"))
        expectFalse(AlternativePolicy.introducesSlang("O relatório está pronto para envio.", original: "O relatório está pronto para ser enviado.", language: "pt"))
        expectFalse(AlternativePolicy.introducesSlang("Mano, o relatório está pronto.", original: "Mano, eu terminei o relatório.", language: "pt"))
    }
    func testCardTranslationUsesDisplayedProposalForWordsAndPhrases() {
        let word = WritingSuggestion(kind: .correction, range: NSRange(location: 0, length: 5),
            original: "frien", replacement: "friend", language: "en", context: "hi my frien how are he ?")
        let phrase = WritingSuggestion(kind: .style, range: NSRange(location: 0, length: 24),
            original: "i could can go to there.?", replacement: "I could go there.", language: "en", context: "")
        expectEqual(word.translationText, "friend")
        expectEqual(phrase.translationText, "I could go there.")
        expectTrue(word.translationText != word.context)
        expectEqual(word.original, "frien")
        expectTrue(word.canApply)
    }

    func testRemovingTextDoesNotOfferTranslationOfOriginalMistake() {
        for replacement in ["", " ", "\n"] {
            let removal = WritingSuggestion(kind: .correction, range: NSRange(location: 0, length: 6),
                original: "really", replacement: replacement, language: "en", context: "")
            expectNil(removal.translationText)
            expectTrue(removal.canApply)
        }
    }
    func testDelayedEditorAcknowledgementDoesNotTreatStaleTextAsFailure() {
        let values: [String?] = ["She go.", nil, "She go.", "She goes."]
        let results = values.map { EditAcknowledgement.observe(original: "She go.", expected: "She goes.", actual: $0, sameDestination: true) }
        expectEqual(results, [.waiting, .waiting, .waiting, .confirmed])
    }
    func testEditorAcknowledgementRejectsChangedDestinationOrUnexpectedText() {
        expectEqual(EditAcknowledgement.observe(original: "go", expected: "goes", actual: "goes", sameDestination: false), .destinationChanged)
        expectEqual(EditAcknowledgement.observe(original: "go", expected: "goes", actual: "user typing", sameDestination: true), .unexpectedText)
        expectEqual(EditAcknowledgement.observe(original: "go", expected: "goes", actual: "goesgoes", sameDestination: true), .unexpectedText)
    }
    func testApplicationFeedbackPreventsDuplicateOrUnconfirmedWrites() {
        expectFalse(ApplicationFeedback.applying.canApply)
        expectTrue(ApplicationFeedback.applying.isBusy)
        expectFalse(ApplicationFeedback.failed("Unconfirmed write", retryAllowed: false).canApply)
        expectTrue(ApplicationFeedback.failed("Selection never confirmed; no write sent", retryAllowed: true).canApply)
        expectTrue(ApplicationFeedback.idle.canApply)
    }

    func testWebTextSegmentsMatchRepeatedWordsAndUnicode() {
        let text = "👩🏽‍💻 hi my frien\nhow are he ?"
        let leaves = ["👩🏽‍💻 hi my frien", "how are he ?"]
        let ranges = EditorTextSegments.ranges(for: leaves, in: text)!
        expectEqual((text as NSString).substring(with: ranges[1]), leaves[1])
        let repeated = EditorTextSegments.ranges(for: ["go", "go"], in: "go go")!
        expectEqual(repeated.map(\.location), [0, 3])
    }
    func testWebTextSegmentsRejectMissingAndStaleContent() {
        expectNil(EditorTextSegments.ranges(for: ["hi", "you"], in: "hi my you"))
        expectNil(EditorTextSegments.ranges(for: ["hi"], in: "hi there"))
        expectNil(EditorTextSegments.ranges(for: [""], in: "hi"))
        expectNil(EditorTextSegments.ranges(for: ["changed"], in: "original"))
    }
    func testReplacementsNeverSplitOneTargetWordBetweenCards() {
        let before = "ola tudo bem com vc mizere"
        let after = "Olá, tudo bem com você?"
        let edits = TextEdits.wordEdits(before, after)
        expectEqual(TextEdits.applying(edits, to: before), after)
        expectEqual(edits.count, 2)
        expectEqual(edits.last?.original, "vc mizere")
        expectEqual(edits.last?.replacement, "você?")
        expectFalse(edits.contains { $0.replacement == "voc" || $0.replacement == "ê?" })
        let joined = TextEdits.wordEdits("an other", "another")
        expectEqual(joined.first?.original, "an other")
        expectEqual(joined.first?.replacement, "another")
    }
    func testScreenshotPortugueseUsesWholeWordsWithPunctuation() {
        let before = "ola tudo bem com vc mizere"
        for after in ["Olá, tudo bem com você, mizere?", "Olá, tudo bem com você, miséria?",
                      "olá, tudo bem com vc mizere", "Olá, tudo bem com você, miséria.",
                      "Olá, tudo bem com você, Mizere?"] {
            let edits = TextEdits.wordEdits(before, after)
            let greeting = edits.first { NSIntersectionRange($0.range, NSRange(location: 0, length: 3)).length > 0 }
            if greeting?.original != "ola" { print("SCREENSHOT REGRESSION \(after): \(edits)") }
            expectEqual(greeting?.original, "ola")
            expectEqual(TextEdits.applying(edits, to: before), after)
        }
    }
    func testObservedEnglishCorrectionsRoundTrip() {
        let before = "She go to school every days. I has a meeting and need your advise."
        let after = "She goes to school every day. I have a meeting and need your advice."
        let edits = TextEdits.wordEdits(before, after)
        expectEqual(TextEdits.applying(edits, to: before), after)
        expectTrue(edits.contains { $0.original == "go" && $0.replacement == "goes" })
        expectTrue(edits.contains { $0.original == "days" && $0.replacement == "day" })
        expectTrue(edits.contains { $0.original == "has" && $0.replacement == "have" })
    }

    func testRepeatedWordsTargetOnlyTheChangedOccurrence() {
        let before = "She go home. They go home."
        let edits = TextEdits.wordEdits(before, "She goes home. They go home.")
        expectEqual(edits.count, 1)
        expectEqual(edits.first?.range, NSRange(location: 4, length: 2))
        expectEqual(TextEdits.applying(edits, to: before), "She goes home. They go home.")
    }

    func testUnicodeOffsetsAfterEmojiAndCombiningMarks() {
        let before = "👩🏽‍💻 Cafe\u{301}: ola eu sou Ana."
        let after = "👩🏽‍💻 Cafe\u{301}: olá eu sou Ana."
        let edits = TextEdits.wordEdits(before, after)
        expectEqual(edits.count, 1)
        expectEqual(edits.first?.range, (before as NSString).range(of: "ola"))
        expectEqual(edits.first?.original, "ola")
        expectEqual(TextEdits.applying(edits, to: before), after)
    }

    func testInsertionsDeletionsAndWholeTextChanges() {
        for (before, after) in [("", "Olá"), ("Hello", ""), ("Hello world", "Hello, world!"),
                                ("a a a", "a a"), ("wrong", "correct"), ("🇧🇷🙂", "🙂🇧🇷"),
                                ("one\ntwo", "One\nTwo"), ("a  b", "a b")] {
            expectEqual(TextEdits.applying(TextEdits.between(before, after), to: before), after,
                           "Failed \(before.debugDescription) → \(after.debugDescription)")
        }
    }

    func testRejectsStaleTextAndOverlappingReplacements() {
        let edit = TextEdit(range: NSRange(location: 0, length: 3), original: "ola", replacement: "Olá")
        expectNil(TextEdits.applying([edit], to: "Ana eu sou"))
        expectNil(TextEdits.applying([edit, edit], to: "ola eu sou"))
    }

    func testRejectsRangeSplittingAnEmoji() {
        let invalid = TextEdit(range: NSRange(location: 0, length: 1), original: "", replacement: "x")
        expectNil(TextEdits.applying([invalid], to: "🙂"))
    }

    func testProtectsNumbersAddressesAndURLs() {
        let before = "Send 42 reports to ana@example.com at https://example.com/a."
        expectTrue(TextEdits.preservesProtectedContent(before, "Please send 42 reports to ana@example.com at https://example.com/a."))
        expectFalse(TextEdits.preservesProtectedContent(before, before.replacingOccurrences(of: "42", with: "43")))
        expectFalse(TextEdits.preservesProtectedContent(before, before.replacingOccurrences(of: "ana@", with: "anne@")))
        expectFalse(TextEdits.preservesProtectedContent(before, before.replacingOccurrences(of: "/a.", with: "/b.")))
    }

    func testNoEditsOnAlreadyCorrectText() {
        let text = "The meeting starts at nine tomorrow. Please bring the report."
        expectTrue(TextEdits.wordEdits(text, text).isEmpty)
    }

    func testFragmentChoosesCurrentParagraphWithoutBreakingUTF16() {
        let text = "English paragraph.\n👋 ola eu sou Ana.\nAnother one."
        let target = (text as NSString).range(of: "ola")
        let fragment = WritingFragment(fieldText: text, caret: target.location + 2)
        expectEqual(fragment?.text, "👋 ola eu sou Ana.")
        expectEqual((text as NSString).substring(with: fragment!.range), fragment?.text)
        expectNil(WritingFragment(fieldText: String(repeating: "a", count: 1200), caret: 1200, maximumUTF16: 1100))
    }

    func testAutomaticLanguagesAndShortAmbiguity() {
        expectEqual(LanguageResolver.detect("ola eu sou tesx")?.code, "pt")
        expectEqual(LanguageResolver.detect("Olá, eu preciso que você revise os documentos enviados ontem.")?.code, "pt")
        expectEqual(LanguageResolver.detect("The meeting starts tomorrow and we need to finish the report.")?.code, "en")
        expectNil(LanguageResolver.detect("a"))
        expectEqual(LanguageResolver.detect("ambiguous", manual: "pt")?.code, "pt")
    }

    func testMixedLanguageSentencesStaySeparate() {
        let text = "Preciso revisar os documentos. She go to school every days."
        let units = LanguageResolver.sentences(in: text)
        expectEqual(units.count, 2)
        expectEqual(LanguageResolver.detect(units[0].1)?.code, "pt")
        expectEqual(LanguageResolver.detect(units[1].1)?.code, "en")
        for (range, unit) in units { expectEqual((text as NSString).substring(with: range), unit) }
    }

    func testAppBlocksUseIdentityAndSurviveSerialization() {
        let first = BlockedApplication(bundleID: "test.one", name: "Same name")
        let second = BlockedApplication(bundleID: "test.two", name: "Same name")
        var entries = ApplicationPolicy.adding(first, to: [])
        entries = ApplicationPolicy.adding(first, to: entries)
        entries = ApplicationPolicy.adding(second, to: entries)
        expectEqual(entries.count, 2)
        let restored = try! JSONDecoder().decode([BlockedApplication].self, from: JSONEncoder().encode(entries))
        expectTrue(ApplicationPolicy.isBlocked("test.one", entries: restored))
        expectTrue(ApplicationPolicy.isBlocked("test.two", entries: restored))
        expectFalse(ApplicationPolicy.isBlocked("test.other", entries: restored))
        expectTrue(ApplicationPolicy.isBlocked(nil, entries: restored))
        let removed = restored.filter { $0.bundleID != first.bundleID }
        expectFalse(ApplicationPolicy.isBlocked("test.one", entries: removed))
        expectTrue(ApplicationPolicy.isBlocked("test.two", entries: removed))
    }

    func testReviewWindowFollowsEditsEarlierInParagraph() {
        let text = "First sentence. Second sentence. Third sentence. Fourth sentence. Fifth sentence. Sixth sentence."
        let beginning = LanguageResolver.sentenceWindow(in: text, caret: 2)
        let ending = LanguageResolver.sentenceWindow(in: text, caret: text.utf16.count)
        expectEqual(beginning.count, 4)
        expectTrue(beginning.first?.1.contains("First") == true)
        expectFalse(beginning.last?.1.contains("Sixth") == true)
        expectTrue(ending.last?.1.contains("Sixth") == true)
        expectEqual(ending.count, 4)
    }

    func testAlternativesRejectRepeatedOrCosmeticVersions() {
        let original = "O relatório está pronto."
        let previous = ["O relatório já foi concluído.", "Já concluímos o relatório."]
        expectFalse(AlternativePolicy.isDistinct("  O RELATÓRIO está pronto!  ", original: original, previous: previous))
        expectFalse(AlternativePolicy.isDistinct("Já concluímos o relatório!", original: original, previous: previous))
        expectFalse(AlternativePolicy.isDistinct("  ... ", original: original, previous: previous))
        expectTrue(AlternativePolicy.isDistinct("A conclusão do relatório já ocorreu.", original: original, previous: previous))
    }

    func testReviewCacheRetainsEmptyAndPositiveResultsAcrossFocusGaps() {
        struct Revision: Hashable { let field: String; let text: String; let language: String }
        var cache = ReviewMemoryCache<Revision, [String]>(capacity: 4, maximumCost: 100, lifetime: 600)
        let time = Date(timeIntervalSince1970: 100)
        let original = Revision(field: "one", text: "She go home.", language: "en")
        let correct = Revision(field: "one", text: "She goes home.", language: "en")
        cache.insert(["go → goes"], for: original, cost: 20, now: time)
        cache.insert([], for: correct, cost: 10, now: time)
        expectEqual(cache.value(for: original, now: time.addingTimeInterval(30)), ["go → goes"])
        expectEqual(cache.value(for: correct, now: time.addingTimeInterval(30)), [])
        expectNil(cache.value(for: Revision(field: "two", text: original.text, language: "en"), now: time))
        expectNil(cache.value(for: Revision(field: "one", text: original.text, language: "pt"), now: time))
        expectNil(cache.value(for: Revision(field: "one", text: "She go out.", language: "en"), now: time))
    }

    func testReviewCacheExpiresEvenWhenRecentlyRead() {
        var cache = ReviewMemoryCache<String, String>(capacity: 2, maximumCost: 100, lifetime: 10)
        let time = Date(timeIntervalSince1970: 100)
        cache.insert("correction", for: "sentence", cost: 10, now: time)
        expectEqual(cache.value(for: "sentence", now: time.addingTimeInterval(9)), "correction")
        expectNil(cache.value(for: "sentence", now: time.addingTimeInterval(10)))
        expectEqual(cache.count, 0)
    }

    func testReviewCacheEvictsLeastRecentAndRespectsTextBudget() {
        var cache = ReviewMemoryCache<String, String>(capacity: 2, maximumCost: 10, lifetime: 600)
        let time = Date(timeIntervalSince1970: 100)
        cache.insert("A", for: "a", cost: 4, now: time)
        cache.insert("B", for: "b", cost: 4, now: time)
        _ = cache.value(for: "a", now: time)
        cache.insert("C", for: "c", cost: 4, now: time)
        expectNil(cache.value(for: "b", now: time))
        expectEqual(cache.value(for: "a", now: time), "A")
        expectTrue(cache.cost <= 10)
        cache.insert("large", for: "d", cost: 9, now: time)
        expectEqual(cache.count, 1)
        expectEqual(cache.value(for: "d", now: time), "large")
        cache.insert("oversize", for: "e", cost: 11, now: time)
        expectNil(cache.value(for: "e", now: time))
    }

    func testReviewCachePurgesExcludedAppsAndAllOnReset() {
        var cache = ReviewMemoryCache<String, String>(capacity: 4, maximumCost: 100, lifetime: 600)
        cache.insert("one", for: "blocked.one", cost: 5)
        cache.insert("two", for: "allowed.two", cost: 5)
        cache.removeAll { $0.hasPrefix("blocked.") }
        expectNil(cache.value(for: "blocked.one"))
        expectEqual(cache.value(for: "allowed.two"), "two")
        cache.removeAll()
        expectEqual(cache.count, 0)
        expectEqual(cache.cost, 0)
    }

    func testProposingPhraseKeepsEveryPendingCorrection() {
        let error = WritingSuggestion(kind: .correction, range: NSRange(location: 4, length: 2), original: "go", replacement: "goes", language: "en", context: "She go home.")
        let second = WritingSuggestion(kind: .correction, range: NSRange(location: 23, length: 4), original: "days", replacement: "day", language: "en", context: "She go to school every days.")
        let phrase = WritingSuggestion(kind: .style, range: NSRange(location: 0, length: 27), original: "She go to school every days.", replacement: "She attends school daily.", language: "en", context: "")
        let proposed = SuggestionLedger.proposing(phrase, alongside: [error, second])
        expectEqual(proposed.filter { $0.kind == .correction }.map(\.id), [error.id, second.id])
        expectEqual(proposed.count, 3)
        let next = WritingSuggestion(kind: .style, range: phrase.range, original: phrase.original, replacement: "Every day, she goes to school.", language: "en", context: "")
        let again = SuggestionLedger.proposing(next, alongside: proposed)
        expectEqual(again.count, 3)
        expectEqual(again.filter { $0.kind == .correction }.map(\.id), [error.id, second.id])
        expectFalse(again.contains { $0.id == phrase.id })
        expectEqual((phrase.original as NSString).substring(with: error.range), error.original)
    }

    func testLongParagraphGetsBoundedFragmentNearCaret() {
        let text = String(repeating: "Uma frase longa com café e 👩🏽‍💻 para revisar. ", count: 500)
        let caret = text.utf16.count - 100
        let fragment = WritingFragment(fieldText: text, caret: caret)
        expectTrue(fragment != nil)
        expectTrue(fragment?.isTruncated == true)
        expectTrue((fragment?.range.length ?? 0) <= 6000)
        expectTrue(fragment.map { NSLocationInRange(caret, $0.range) } == true)
        if let fragment { expectEqual((text as NSString).substring(with: fragment.range), fragment.text) }
    }

    func testLongSentenceChunksPreserveWordsUnicodeAndOffsets() {
        let text = String(repeating: "Palavras com café e 👩🏽‍💻 precisam de contexto ", count: 80) + "."
        let chunks = ReviewChunker.chunks(in: text)
        expectTrue(chunks.count > 4)
        expectEqual(chunks.map(\.text).joined(), text)
        for chunk in chunks {
            expectTrue(chunk.isReviewable)
            expectTrue(chunk.range.length <= ReviewChunker.maximumInputUTF16)
            expectTrue(Range(chunk.range, in: text) != nil)
            expectEqual((text as NSString).substring(with: chunk.range), chunk.text)
            expectFalse(chunk.isCompleteSentence)
        }
    }

    func testOversizeSingleWordIsSkippedIntact() {
        let word = String(repeating: "x", count: 1200)
        let text = "Word " + word + " end."
        let chunks = ReviewChunker.chunks(in: text)
        expectEqual(chunks.map(\.text).joined(), text)
        expectTrue(chunks.contains { !$0.isReviewable && $0.text.contains(word) })
        expectFalse(chunks.filter(\.isReviewable).contains { $0.text.contains(String(repeating: "x", count: 10)) })
    }

    func testChunkWindowFollowsCurrentPositionInLongSentence() {
        let text = String(repeating: "We review a few words at a time ", count: 200) + "."
        let beginning = ReviewChunker.window(in: text, caret: 2)
        let end = ReviewChunker.window(in: text, caret: text.utf16.count)
        expectEqual(beginning.count, 4)
        expectEqual(end.count, 4)
        expectEqual(beginning.first?.range.location, 0)
        expectEqual(end.last.map { NSMaxRange($0.range) }, text.utf16.count)
        expectTrue((end.first?.range.location ?? 0) > 0)
    }

    func testTokenBudgetReservesOutputAndFraming() {
        expectTrue(ReviewTokenBudget.fits(inputTokens: 2940, contextSize: 4096))
        expectFalse(ReviewTokenBudget.fits(inputTokens: 2941, contextSize: 4096))
        expectFalse(ReviewTokenBudget.fits(inputTokens: -1, contextSize: 4096))
        expectFalse(ReviewTokenBudget.fits(inputTokens: 0, contextSize: 1000))
    }

    func testReviewKeepsSentenceSeparatorsAndIndentation() {
        expectEqual(TextEdits.preservingBoundaryWhitespace(of: "The report is ready. ", in: "The report is ready."), "The report is ready. ")
        expectEqual(TextEdits.preservingBoundaryWhitespace(of: "\tShe go home.\n", in: "She goes home."), "\tShe goes home.\n")
        expectEqual(TextEdits.preservingBoundaryWhitespace(of: "Olá.", in: "  Olá.\n"), "Olá.")
        expectTrue(TextEdits.wordEdits("Correct. ", TextEdits.preservingBoundaryWhitespace(of: "Correct. ", in: "Correct.")).isEmpty)
    }

    func testPhraseResultCannotBeOverriddenByHoverOnOldCorrection() {
        let word = UUID(), phrase = UUID()
        var interaction = SuggestionInteractionState()
        interaction.open(word, pinned: false)
        interaction.set(.generating, for: word)
        expectTrue(interaction.state(for: word).isBusy)
        expectEqual(interaction.finish(for: word, presenting: phrase), phrase)
        interaction.open(phrase, pinned: true)
        expectEqual(interaction.state(for: word), .idle)
        expectFalse(interaction.allowsHover(on: word))
        expectTrue(interaction.allowsHover(on: phrase))
        expectEqual(interaction.openID, phrase)
        interaction.hide()
        expectTrue(interaction.allowsHover(on: word))
        interaction.open(word, pinned: false)
        expectFalse(interaction.state(for: word).isBusy)
    }

    func testClosedCardDoesNotReopenWhenResultFinishes() {
        let word = UUID(), phrase = UUID()
        var interaction = SuggestionInteractionState()
        interaction.open(word, pinned: false)
        interaction.set(.generating, for: word)
        interaction.hide()
        expectNil(interaction.finish(for: word, presenting: phrase))
        expectNil(interaction.openID)
        expectFalse(interaction.state(for: word).isBusy)
    }

    func testTerminalFeedbackSurvivesFinalCleanupAndUnlocksCorrection() {
        let word = UUID()
        for terminal in [AlternativeState.failed("Timeout"), .unavailable("No distinct wording")] {
            var interaction = SuggestionInteractionState()
            interaction.open(word, pinned: false)
            interaction.set(.generating, for: word)
            interaction.set(terminal, for: word)
            interaction.finish(for: word)
            expectEqual(interaction.state(for: word), terminal)
            expectFalse(interaction.state(for: word).isBusy)
        }
    }

    func testQueuedOrCancelledRequestAlwaysLeavesBusyState() {
        let word = UUID(), other = UUID()
        var interaction = SuggestionInteractionState()
        interaction.open(word, pinned: false)
        interaction.set(.queued, for: word)
        interaction.finish(for: word)
        expectFalse(interaction.state(for: word).isBusy)
        interaction.set(.generating, for: word)
        interaction.open(other, pinned: true)
        expectNil(interaction.finish(for: word, presenting: UUID()))
        expectEqual(interaction.openID, other)
        expectFalse(interaction.state(for: word).isBusy)
    }

    func testLateAnswerCannotReplaceNewRequestAfterTimeoutOrCancellation() {
        var lifetime = AlternativeRequestLifetime()
        let old = lifetime.begin()
        expectTrue(lifetime.accepts(old))
        expectTrue(lifetime.timeout(old))
        expectTrue(lifetime.hasTimedOut)
        expectFalse(lifetime.accepts(old))
        lifetime.finish()
        let current = lifetime.begin()
        expectFalse(lifetime.timeout(old))
        expectTrue(lifetime.accepts(current))
        expectFalse(lifetime.hasTimedOut)
        lifetime.cancel()
        expectFalse(lifetime.accepts(current))
    }

    func testPunctuationInsertionAtChangedWordEndIsAppliedOnce() {
        for (before, after, originalWord, replacementWord) in [
            ("ola tudo bem com vc mizere", "Olá, tudo bem com você, Mizere?", "mizere", "Mizere?"),
            ("hello world", "Hello, World!", "world", "World!"),
            ("ola ana", "Olá, Ana!", "ana", "Ana!"),
            ("👩🏽‍💻 ola ana", "👩🏽‍💻 Olá, Ana!", "ana", "Ana!")
        ] {
            let edits = TextEdits.wordEdits(before, after)
            expectEqual(TextEdits.applying(edits, to: before), after)
            expectTrue(edits.contains { $0.original == originalWord && $0.replacement == replacementWord })
            expectEqual(edits.filter { $0.original == originalWord }.count, 1)
            expectFalse(edits.contains { $0.original == "a" && $0.replacement == "á," })
        }
    }

    func testAcceptOneWordImmediatelyKeepsOtherCorrectionAndIdentity() {
        let source = "👩🏽‍💻 She go to school every days."
        let corrected = "👩🏽‍💻 She goes to school every day."
        let proposals = TextEdits.wordEdits(source, corrected).map {
            WritingSuggestion(kind: .correction, range: $0.range, original: $0.original, replacement: $0.replacement, language: "en", context: source)
        }
        let accepted = proposals.first { $0.original == "go" }!
        let other = proposals.first { $0.original == "days" }!
        let edit = TextEdit(range: accepted.range, original: accepted.original, replacement: accepted.replacement)
        let updated = TextEdits.applying([edit], to: source)!
        let carried = SuggestionLedger.rebasing(proposals, after: edit, from: source, to: updated)!
        expectEqual(carried.count, 1)
        expectEqual(carried.first?.id, other.id)
        expectEqual(carried.first?.range.location, other.range.location + 2)
        expectEqual(carried.first?.original, "days")
        expectEqual((updated as NSString).substring(with: carried[0].range), "days")
        expectEqual(TextEdits.applying(carried.map { TextEdit(range: $0.range, original: $0.original, replacement: $0.replacement) }, to: updated), corrected)
    }

    func testAcceptLaterWordKeepsEarlierCorrectionAndRejectsUnverifiedText() {
        let source = "She go every days."
        let proposals = TextEdits.wordEdits(source, "She goes every day.").map {
            WritingSuggestion(kind: .correction, range: $0.range, original: $0.original, replacement: $0.replacement, language: "en", context: source)
        }
        let accepted = proposals.last!
        let edit = TextEdit(range: accepted.range, original: accepted.original, replacement: accepted.replacement)
        let updated = TextEdits.applying([edit], to: source)!
        let carried = SuggestionLedger.rebasing(proposals, after: edit, from: source, to: updated)!
        expectEqual(carried.first?.id, proposals.first?.id)
        expectEqual(carried.first?.range, proposals.first?.range)
        expectNil(SuggestionLedger.rebasing(proposals, after: edit, from: source, to: "A different editor value"))
    }

    func testAcceptedWordInvalidatesOverlappingPhraseButKeepsIndependentMarks() {
        let source = "She go home. I has time."
        let first = WritingSuggestion(kind: .correction, range: (source as NSString).range(of: "go"), original: "go", replacement: "goes", language: "en", context: source)
        let second = WritingSuggestion(kind: .correction, range: (source as NSString).range(of: "has"), original: "has", replacement: "have", language: "en", context: source)
        let phrase = WritingSuggestion(kind: .coherence, range: NSRange(location: 0, length: 12), original: "She go home.", replacement: "She heads home.", language: "en", context: source)
        let edit = TextEdit(range: first.range, original: first.original, replacement: first.replacement)
        let updated = TextEdits.applying([edit], to: source)!
        let carried = SuggestionLedger.rebasing([first, second, phrase], after: edit, from: source, to: updated)!
        expectEqual(carried.map(\.id), [second.id])
        expectEqual((updated as NSString).substring(with: carried[0].range), "has")
    }

    func testAmbiguousCoherenceCanBeFlaggedWithoutInventingReplacement() {
        let original = "Yesterday tomorrow is now."
        let issue = WritingSuggestion(kind: .coherence, range: NSRange(location: 0, length: original.utf16.count), original: original, replacement: original, language: "en", context: original)
        expectFalse(issue.canApply)
        expectEqual(issue.original, issue.replacement)
    }
}

private var failures = 0
private func expectTrue(_ condition: @autoclosure () -> Bool, _ message: String = "", file: StaticString = #filePath, line: UInt = #line) {
    if !condition() { failures += 1; print("FAIL \(file):\(line) \(message)") }
}
private func expectFalse(_ condition: @autoclosure () -> Bool, file: StaticString = #filePath, line: UInt = #line) {
    expectTrue(!condition(), file: file, line: line)
}
private func expectNil<T>(_ value: T?, file: StaticString = #filePath, line: UInt = #line) {
    expectTrue(value == nil, file: file, line: line)
}
private func expectEqual<T: Equatable>(_ left: T, _ right: T, _ message: String = "", file: StaticString = #filePath, line: UInt = #line) {
    expectTrue(left == right, "\(message) expected \(right), got \(left)", file: file, line: line)
}

@main struct CheckMain {
    static func main() {
        let longPhrase = "Olá, amigo 👩🏽‍💻! Como você está? This is a longer suggestion."
        let inputChunks = BrowserTextInputPlan.chunks(for: longPhrase)!
        expectEqual(inputChunks.joined(), longPhrase)
        expectTrue(inputChunks.allSatisfy { !$0.isEmpty && $0.utf16.count <= 16 })
        expectTrue(inputChunks.flatMap { Array($0) } == Array(longPhrase))
        print("Checked browser input preserves graphemes across bounded events")
        for text in ["hello\nworld", "hello\rworld", "hello\tworld", "hello\u{1B}", "hello\u{2028}"] {
            expectNil(BrowserTextInputPlan.chunks(for: text))
        }
        print("Checked browser input rejects controls and line submission characters")
        expectEqual(BrowserTextInputPlan.chunks(for: ""), [])
        expectNil(BrowserTextInputPlan.chunks(for: "a" + String(repeating: "\u{0301}", count: 20)))
        print("Checked empty replacement and oversized grapheme handling")
        let checks = WritingCoreChecks()
        checks.testTranslationCannotChangeCalendarWeekdays(); print("Checked calendar weekday fidelity across translation languages")
        checks.testWebEditorUsesVerifiedNativeInputInAnyApplication(); print("Checked web adapter chosen from capabilities, independent of bundle ID")
        checks.testNativeEditorPrefersAccessibilityAndUsesInputWhenNeeded(); print("Checked native editor strategies")
        checks.testReadOnlyAndSecureEditorsNeverGetAnInputFallback(); print("Checked read-only and secure field exclusions")
        checks.testLanguageFallbackRequiresContextInsteadOfAForcedDefault(); print("Checked automatic language fallback context gate")
        checks.testScreenshotRewriteCannotIntroduceRegionalSlang(); print("Checked screenshot rewrite rejects newly introduced slang")
        checks.testExistingDialectIsPreservedAndWholeWordsAreMatched(); print("Checked existing dialect and exact word matching")
        checks.testPortugueseRewriteDoesNotInventSlang(); print("Checked Portuguese register guard")
        checks.testCardTranslationUsesDisplayedProposalForWordsAndPhrases(); print("Checked card translation uses displayed word or phrase proposal")
        checks.testRemovingTextDoesNotOfferTranslationOfOriginalMistake(); print("Checked empty proposal has no translation but remains applicable")
        checks.testObservedEnglishCorrectionsRoundTrip(); print("Checked testObservedEnglishCorrectionsRoundTrip")
        checks.testRepeatedWordsTargetOnlyTheChangedOccurrence(); print("Checked testRepeatedWordsTargetOnlyTheChangedOccurrence")
        checks.testUnicodeOffsetsAfterEmojiAndCombiningMarks(); print("Checked testUnicodeOffsetsAfterEmojiAndCombiningMarks")
        checks.testInsertionsDeletionsAndWholeTextChanges(); print("Checked testInsertionsDeletionsAndWholeTextChanges")
        checks.testRejectsStaleTextAndOverlappingReplacements(); print("Checked testRejectsStaleTextAndOverlappingReplacements")
        checks.testRejectsRangeSplittingAnEmoji(); print("Checked testRejectsRangeSplittingAnEmoji")
        checks.testProtectsNumbersAddressesAndURLs(); print("Checked testProtectsNumbersAddressesAndURLs")
        checks.testNoEditsOnAlreadyCorrectText(); print("Checked testNoEditsOnAlreadyCorrectText")
        checks.testFragmentChoosesCurrentParagraphWithoutBreakingUTF16(); print("Checked testFragmentChoosesCurrentParagraphWithoutBreakingUTF16")
        checks.testAutomaticLanguagesAndShortAmbiguity(); print("Checked testAutomaticLanguagesAndShortAmbiguity")
        checks.testMixedLanguageSentencesStaySeparate(); print("Checked testMixedLanguageSentencesStaySeparate")
        checks.testAppBlocksUseIdentityAndSurviveSerialization(); print("Checked testAppBlocksUseIdentityAndSurviveSerialization")
        checks.testReviewWindowFollowsEditsEarlierInParagraph(); print("Checked testReviewWindowFollowsEditsEarlierInParagraph")
        checks.testAlternativesRejectRepeatedOrCosmeticVersions(); print("Checked testAlternativesRejectRepeatedOrCosmeticVersions")
        checks.testReviewCacheRetainsEmptyAndPositiveResultsAcrossFocusGaps(); print("Checked testReviewCacheRetainsEmptyAndPositiveResultsAcrossFocusGaps")
        checks.testReviewCacheExpiresEvenWhenRecentlyRead(); print("Checked testReviewCacheExpiresEvenWhenRecentlyRead")
        checks.testReviewCacheEvictsLeastRecentAndRespectsTextBudget(); print("Checked testReviewCacheEvictsLeastRecentAndRespectsTextBudget")
        checks.testReviewCachePurgesExcludedAppsAndAllOnReset(); print("Checked testReviewCachePurgesExcludedAppsAndAllOnReset")
        checks.testProposingPhraseKeepsEveryPendingCorrection(); print("Checked testProposingPhraseKeepsEveryPendingCorrection")
        checks.testLongParagraphGetsBoundedFragmentNearCaret(); print("Checked testLongParagraphGetsBoundedFragmentNearCaret")
        checks.testLongSentenceChunksPreserveWordsUnicodeAndOffsets(); print("Checked testLongSentenceChunksPreserveWordsUnicodeAndOffsets")
        checks.testOversizeSingleWordIsSkippedIntact(); print("Checked testOversizeSingleWordIsSkippedIntact")
        checks.testChunkWindowFollowsCurrentPositionInLongSentence(); print("Checked testChunkWindowFollowsCurrentPositionInLongSentence")
        checks.testTokenBudgetReservesOutputAndFraming(); print("Checked testTokenBudgetReservesOutputAndFraming")
        checks.testReviewKeepsSentenceSeparatorsAndIndentation(); print("Checked testReviewKeepsSentenceSeparatorsAndIndentation")
        checks.testPhraseResultCannotBeOverriddenByHoverOnOldCorrection(); print("Checked testPhraseResultCannotBeOverriddenByHoverOnOldCorrection")
        checks.testClosedCardDoesNotReopenWhenResultFinishes(); print("Checked testClosedCardDoesNotReopenWhenResultFinishes")
        checks.testTerminalFeedbackSurvivesFinalCleanupAndUnlocksCorrection(); print("Checked testTerminalFeedbackSurvivesFinalCleanupAndUnlocksCorrection")
        checks.testQueuedOrCancelledRequestAlwaysLeavesBusyState(); print("Checked testQueuedOrCancelledRequestAlwaysLeavesBusyState")
        checks.testLateAnswerCannotReplaceNewRequestAfterTimeoutOrCancellation(); print("Checked testLateAnswerCannotReplaceNewRequestAfterTimeoutOrCancellation")
        checks.testScreenshotPortugueseUsesWholeWordsWithPunctuation(); print("Checked testScreenshotPortugueseUsesWholeWordsWithPunctuation")
        checks.testPunctuationInsertionAtChangedWordEndIsAppliedOnce(); print("Checked testPunctuationInsertionAtChangedWordEndIsAppliedOnce")
        checks.testAcceptOneWordImmediatelyKeepsOtherCorrectionAndIdentity(); print("Checked testAcceptOneWordImmediatelyKeepsOtherCorrectionAndIdentity")
        checks.testAcceptLaterWordKeepsEarlierCorrectionAndRejectsUnverifiedText(); print("Checked testAcceptLaterWordKeepsEarlierCorrectionAndRejectsUnverifiedText")
        checks.testAcceptedWordInvalidatesOverlappingPhraseButKeepsIndependentMarks(); print("Checked testAcceptedWordInvalidatesOverlappingPhraseButKeepsIndependentMarks")
        checks.testAmbiguousCoherenceCanBeFlaggedWithoutInventingReplacement(); print("Checked testAmbiguousCoherenceCanBeFlaggedWithoutInventingReplacement")
        checks.testReplacementsNeverSplitOneTargetWordBetweenCards(); print("Checked testReplacementsNeverSplitOneTargetWordBetweenCards")
        checks.testWebTextSegmentsMatchRepeatedWordsAndUnicode(); print("Checked testWebTextSegmentsMatchRepeatedWordsAndUnicode")
        checks.testWebTextSegmentsRejectMissingAndStaleContent(); print("Checked testWebTextSegmentsRejectMissingAndStaleContent")
        checks.testDelayedEditorAcknowledgementDoesNotTreatStaleTextAsFailure(); print("Checked testDelayedEditorAcknowledgementDoesNotTreatStaleTextAsFailure")
        checks.testEditorAcknowledgementRejectsChangedDestinationOrUnexpectedText(); print("Checked testEditorAcknowledgementRejectsChangedDestinationOrUnexpectedText")
        checks.testApplicationFeedbackPreventsDuplicateOrUnconfirmedWrites(); print("Checked testApplicationFeedbackPreventsDuplicateOrUnconfirmedWrites")
        checks.testIndependentSpellingSurvivesModelProposalAndNoChange(); print("Checked independent spelling and canonical result")
        checks.testModelOverlapWinsAndStaleSpellingIsRejected(); print("Checked model precedence and stale spelling rejection")
        checks.testRewriteIncludesMessageAfterGreetingAndPunctuation(); print("Checked complete rewrite context and corrected baseline")
        checks.testRewriteContextIsBoundedAndKeepsUnicode(); print("Checked bounded Unicode rewrite context")
        checks.testRewriteStaysCloseToIdeaAndReferences(); print("Checked close wording and preserved references/negation/numbers")
        checks.testWhitespaceRemovalCardExplainsTheTarget(); print("Checked visible whitespace-removal target")
        checks.testReviewedPhraseAcceptanceKeepsIndependentCorrections(); print("Checked reviewed phrase acceptance and independent pending corrections")
        checks.testReviewedPassageConsumesBoundaryPunctuationOnlyForPassages(); print("Checked passage punctuation is consumed while independent word punctuation survives")
        print("63 checks, \(failures) failures")
        if failures > 0 { exit(1) }
    }
}
