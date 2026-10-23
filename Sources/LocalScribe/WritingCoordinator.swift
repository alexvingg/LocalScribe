import AppKit
import Combine
import WritingCore

@MainActor
final class WritingCoordinator: ObservableObject {
    let preferences: Preferences
    let model = LocalModelService()
    let editor: AccessibilityEditor
    let overlay = OverlayPresenter()
    let translation = LocalTranslationService()
    @Published private(set) var status = L10n.text("Starting…")
    @Published private(set) var detectedLanguage = L10n.text("Automatic")
    @Published private(set) var suggestionCount = 0
    @Published private(set) var lastApplicationName = ""
    @Published private(set) var geometryDiagnostic = L10n.text("No positioned suggestions")
    @Published var keyboardShortcutAvailable = false
    private(set) var snapshot: EditorSnapshot?
    private var suggestions: [WritingSuggestion] = []
    private var epoch = UUID()
    private var pending: (EditorSnapshot, UUID)?
    private var debounce: Task<Void, Never>?
    private var worker: Task<Void, Never>?
    private var applicationTask: Task<Void, Never>?
    private var reviewRetry: Task<Void, Never>?
    private var reviewFailures = 0
    private var inferenceBusy = false
    private var generatingAlternative = false
    private let cache = ReviewSessionCache()
    private struct LanguageKey: Hashable { let bundleID: String; let text: String }
    private var languageCache = ReviewMemoryCache<LanguageKey, String>(capacity: 32, maximumCost: 16_000, lifetime: 600)
    private var activeKey: FieldRevisionKey?
    private var currentIsComplete = false
    private var revisionMessage = ""
    private var ignoredSuggestions = Set<SuggestionSignature>()
    private var deferredAlternative: WritingSuggestion?
    private var alternativeLifetime = AlternativeRequestLifetime()
    private var alternativeDeadline: Task<Void, Never>?
    private var deferredDeadline: Task<Void, Never>?
    private var alternativeHistory: [String: [String]] = [:]
    private var subscription: AnyCancellable?
    private var errorUntil = Date.distantPast
    private var failedSnapshot: EditorSnapshot?
    private var lastReviewPolicy: [String]

    init(preferences: Preferences) {
        self.preferences = preferences
        lastReviewPolicy = preferences.reviewPolicyIdentity
        editor = AccessibilityEditor(preferences: preferences)
        editor.onSnapshot = { [weak self] in self?.receive($0) }
        editor.onStatus = { [weak self] message in
            guard let self, self.applicationTask == nil else { return }
            self.setStatus(message)
            let diagnostic = self.editor.geometryDiagnostic + " · " + self.cache.diagnostic
            if self.geometryDiagnostic != diagnostic { self.geometryDiagnostic = diagnostic }
        }
        editor.onTick = { [weak self] in self?.cache.pruneIfNeeded(); self?.refreshGeometry() }
        overlay.onAccept = { [weak self] in self?.accept($0) }
        overlay.onDismiss = { [weak self] in self?.dismiss($0) }
        overlay.onAlternatives = { [weak self] in self?.requestAlternative($0) }
        overlay.onTranslate = { [weak self] in self?.translateSuggestion($0) }
        overlay.onHideTranslation = { [weak self] in self?.translation.closeInline(for: $0.id) }
        translation.onInlineUpdate = { [weak self] id, state in self?.overlay.setTranslationState(state, for: id) }
        overlay.translationLanguageName = { [weak self] in
            guard let self else { return "" }
            return L10n.languageName(self.preferences.translationLanguage)
        }
        subscription = preferences.objectWillChange.sink { [weak self] _ in
            DispatchQueue.main.async {
                guard let self else { return }
                self.translation.reset()
                self.overlay.refreshTranslationLanguage()
                let policy = self.preferences.reviewPolicyIdentity
                guard policy != self.lastReviewPolicy else { return }
                self.lastReviewPolicy = policy
                self.cache.removeAll()
                self.languageCache.removeAll()
                self.invalidate(clearSnapshot: true, cancelAutomatic: true)
                self.editor.refresh()
            }
        }
    }

    func start() { model.prepare(); editor.start() }
    func stop() { applicationTask?.cancel(); invalidate(clearSnapshot: true, cancelAutomatic: true); cache.removeAll(); languageCache.removeAll(); translation.reset(); editor.stop() }

    private func setStatus(_ value: String) {
        guard Date() >= errorUntil else { return }
        if status != value { status = value }
    }

    private func invalidate(clearSnapshot: Bool, preservingOverlay: Bool = false, cancelAutomatic: Bool = false) {
        epoch = UUID()
        translation.close()
        debounce?.cancel(); debounce = nil
        reviewRetry?.cancel(); reviewRetry = nil; reviewFailures = 0
        // Let a started automatic request finish against its frozen input and populate the
        // exact-text cache. Epoch validation still prevents stale UI or writes.
        if generatingAlternative || cancelAutomatic { worker?.cancel() }
        alternativeLifetime.cancel()
        alternativeDeadline?.cancel(); alternativeDeadline = nil
        deferredDeadline?.cancel(); deferredDeadline = nil
        pending = nil
        deferredAlternative = nil
        suggestions = []; suggestionCount = 0
        currentIsComplete = false
        revisionMessage = ""
        ignoredSuggestions.removeAll()
        activeKey = nil
        alternativeHistory.removeAll()
        if !preservingOverlay { overlay.clear() }
        geometryDiagnostic = L10n.text("No positioned suggestions")
        if clearSnapshot {
            snapshot = nil; detectedLanguage = L10n.text("Automatic")
            failedSnapshot = nil
        }
    }

    private func saveCurrentRevision() {
        guard let key = activeKey, snapshot != nil, failedSnapshot == nil else { return }
        cache.save(CachedFieldRevision(suggestions: suggestions, ignored: ignoredSuggestions, history: alternativeHistory,
            language: detectedLanguage, message: revisionMessage, complete: currentIsComplete), for: key)
    }

    private func finishRevision(_ message: String) {
        currentIsComplete = true
        revisionMessage = message
        setStatus(message)
        saveCurrentRevision()
    }

    private func receive(_ incoming: EditorSnapshot?) {
        guard applicationTask == nil else { return }
        guard let incoming else {
            if snapshot != nil || failedSnapshot != nil {
                saveCurrentRevision()
                // Hide overlays and cancel work, while retaining validated text results in memory.
                invalidate(clearSnapshot: true)
            }
            return
        }
        if let failedSnapshot, failedSnapshot.sameRevision(as: incoming) { return }
        if failedSnapshot != nil { failedSnapshot = nil; errorUntil = .distantPast }
        if let snapshot, snapshot.sameRevision(as: incoming) { return }
        saveCurrentRevision()
        invalidate(clearSnapshot: false)
        snapshot = incoming
        lastApplicationName = incoming.appName
        let key = cache.key(for: incoming, languageMode: preferences.languageMode)
        activeKey = key
        if editor.isCurrent(incoming), let saved = cache.revision(for: key) {
            ignoredSuggestions = saved.ignored
            alternativeHistory = saved.history
            detectedLanguage = saved.language
            currentIsComplete = saved.complete
            revisionMessage = saved.message
            publish(saved.suggestions, input: incoming)
            if saved.complete {
                setStatus(L10n.format("Resumed without reanalysis · %@", saved.message))
                return
            }
        }
        let token = epoch
        setStatus(L10n.format("Waiting for a pause in %@…", incoming.appName))
        debounce = Task { [weak self] in
            do { try await Task.sleep(nanoseconds: 400_000_000) } catch { return }
            guard let self, token == self.epoch else { return }
            self.pending = (incoming, token)
            self.pump()
        }
    }

    private func pump() {
        guard applicationTask == nil, !inferenceBusy, let (input, token) = pending else { return }
        pending = nil
        guard token == epoch, editor.isCurrent(input) else { return }
        inferenceBusy = true
        generatingAlternative = false
        worker = Task { [weak self] in
            guard let self else { return }
            await self.analyze(input, token: token)
            self.finishWorker()
        }
    }

    private func finishWorker() {
        inferenceBusy = false
        generatingAlternative = false
        worker = nil
        if let next = deferredAlternative {
            deferredAlternative = nil
            deferredDeadline?.cancel(); deferredDeadline = nil
            requestAlternative(next)
        }
        pump()
    }

    private func valid(_ token: UUID, _ input: EditorSnapshot) -> Bool {
        applicationTask == nil && token == epoch && !Task.isCancelled && editor.isCurrent(input)
    }

    private func analyze(_ input: EditorSnapshot, token: UUID) async {
        guard model.isAvailable else { setStatus(model.availabilityDescription); return }
        let caret = input.selectedRange.location - input.fragment.range.location
        let units = ReviewChunker.window(in: input.fragment.text, caret: caret)
        guard !units.isEmpty else { return }
        var findings = suggestions
        var skippedChunk = false
        var spellingOnly = false
        var knownLanguages = Set<String>()
        let capturedPolicy = lastReviewPolicy
        func mayCache() -> Bool {
            !Task.isCancelled && capturedPolicy == lastReviewPolicy
                && !preferences.paused && !preferences.isBlocked(input.bundleID)
        }
        do {
            for unit in units {
                let range = unit.range, text = unit.text
                guard unit.isReviewable else { skippedChunk = true; continue }
                guard valid(token, input) else { return }
                var languageCode = (LanguageResolver.detect(text, manual: preferences.manualLanguage)
                    ?? LanguageResolver.detect(input.fragment.text, manual: preferences.manualLanguage))?.code
                if languageCode == nil, LanguageResolver.hasEnoughContextForModel(text) {
                    let languageKey = LanguageKey(bundleID: input.bundleID, text: text)
                    if let cached = languageCache.value(for: languageKey) {
                        languageCode = cached == "unknown" ? nil : cached
                    } else {
                        setStatus(L10n.text("Identifying the language on your Mac…"))
                        cache.willCallModel()
                        languageCode = try await model.identifyLanguage(text)
                        guard mayCache() else { return }
                        languageCache.insert(languageCode ?? "unknown", for: languageKey, cost: text.utf16.count)
                        guard valid(token, input) else { return }
                    }
                }
                guard let languageCode else { continue }
                let languageName = L10n.languageName(languageCode)
                guard model.supports(languageCode) else { setStatus(L10n.format("Unsupported language: %@", languageName)); continue }
                knownLanguages.insert(languageName)
                detectedLanguage = knownLanguages.sorted().joined(separator: ", ")
                let localEdits = SystemSpellingService.edits(in: text, language: languageCode)
                for edit in localEdits {
                    let item = WritingSuggestion(kind: .correction,
                        range: NSRange(location: range.location + edit.range.location, length: edit.range.length),
                        original: edit.original, replacement: edit.replacement, language: languageCode, context: text,
                        isFragment: !unit.isCompleteSentence || input.fragment.isTruncated)
                    if !findings.contains(where: { NSIntersectionRange($0.range, item.range).length > 0 }) {
                        findings.append(item)
                    }
                }
                if !localEdits.isEmpty { publish(findings, input: input) }
                let assessment: ReviewAssessment
                if let cached = cache.assessment(text, language: languageCode, bundleID: input.bundleID) {
                    assessment = cached
                    setStatus(L10n.format("Reusing review in %@…", languageName))
                } else {
                    setStatus(L10n.format("Reviewing on device in %@…", languageName))
                    cache.willCallModel()
                    do {
                        assessment = try await model.assess(text, language: languageCode)
                    } catch ReviewFailure.contentReviewUnavailable {
                        // This is a terminal decision, not a transient framework failure.
                        assessment = ReviewAssessment(revised: TextEdits.applying(localEdits, to: text) ?? text,
                            sentenceIssue: false, spellingOnly: true)
                    }
                    guard mayCache() else { return }
                }
                guard mayCache() else { return }
                spellingOnly = spellingOnly || assessment.spellingOnly
                let modelEdits = TextEdits.wordEdits(text, assessment.revised)
                if text != assessment.revised && modelEdits.isEmpty { throw ReviewFailure.invalidResponse }
                let edits = assessment.sentenceIssue ? modelEdits
                    : TextEdits.supplementing(modelEdits, with: localEdits, in: text)
                let revised = TextEdits.applying(edits, to: text) ?? assessment.revised
                // Cache exactly the proposals shown, including dictionary corrections, so acceptance
                // cannot later offer to undo a local correction that the model omitted.
                cache.saveSentence(text, revised: revised, language: languageCode, bundleID: input.bundleID,
                    sentenceIssue: assessment.sentenceIssue, spellingOnly: assessment.spellingOnly)
                guard valid(token, input) else {
                    FileHandle.standardError.write(Data("editor-review phase=cached-after-context-change bundle=\(input.bundleID)\n".utf8))
                    return
                }
                let fresh: [WritingSuggestion]
                if assessment.sentenceIssue {
                    fresh = [WritingSuggestion(kind: .coherence, range: range, original: text, replacement: revised,
                        language: languageCode, context: text, isFragment: !unit.isCompleteSentence || input.fragment.isTruncated,
                        hasReviewedReplacement: true)]
                } else {
                    fresh = edits.prefix(12).map { edit in
                        WritingSuggestion(kind: .correction,
                            range: NSRange(location: range.location + edit.range.location, length: edit.range.length),
                            original: edit.original, replacement: edit.replacement, language: languageCode, context: text,
                            isFragment: !unit.isCompleteSentence || input.fragment.isTruncated)
                    }
                }
                let stable = fresh.map { item in
                    findings.first(where: { SuggestionSignature($0) == SuggestionSignature(item) }) ?? item
                }
                findings.removeAll { $0.kind != .style && (NSIntersectionRange($0.range, range).length > 0 || ($0.range.length == 0 && NSLocationInRange($0.range.location, range))) }
                findings += stable
                publish(findings, input: input)
            }
            guard valid(token, input) else { return }
            reviewFailures = 0
            if knownLanguages.isEmpty { finishRevision(skippedChunk ? L10n.text("An unbroken passage is too large; split it to review") : L10n.text("Waiting for context to identify the language")); return }
            if spellingOnly {
                finishRevision(L10n.format("Spelling corrections: %ld · The Apple model declined sentence review for this passage", suggestions.count))
                return
            }
            finishRevision(suggestions.isEmpty ? L10n.text("No changes suggested in this review") : L10n.format("Suggestions: %ld · %@", suggestions.count, input.appName))
        } catch ReviewFailure.contentReviewUnavailable {
            if valid(token, input) { finishRevision(ReviewFailure.contentReviewUnavailable.localizedDescription) }
        } catch is CancellationError {
            // Results from old revisions never reach the overlay.
        } catch {
            if valid(token, input) {
                setStatus(L10n.format("Review unavailable: %@", error.localizedDescription))
                // One transient framework failure must not strand this unchanged editor forever.
                reviewFailures += 1
                if reviewFailures <= 2 {
                    let delay = UInt64(reviewFailures * 2) * 1_000_000_000
                    reviewRetry = Task { [weak self] in
                        do { try await Task.sleep(nanoseconds: delay) } catch { return }
                        guard let self, self.valid(token, input) else { return }
                        self.pending = (input, token); self.pump()
                    }
                }
            }
        }
    }

    private func publish(_ items: [WritingSuggestion], input: EditorSnapshot) {
        suggestions = items.filter { !ignoredSuggestions.contains(SuggestionSignature($0)) }
        suggestionCount = suggestions.count
        overlay.update(editor.locate(suggestions, in: input))
        geometryDiagnostic = editor.geometryDiagnostic + " · " + cache.diagnostic
        saveCurrentRevision()
    }

    private func refreshGeometry() {
        guard applicationTask == nil else { return }
        guard failedSnapshot == nil else { return }
        guard Date() >= errorUntil else { return }
        guard let snapshot, !suggestions.isEmpty else { overlay.clear(); return }
        guard editor.isCurrent(snapshot) else { overlay.clear(); return }
        overlay.update(editor.locate(suggestions, in: snapshot))
        let diagnostic = editor.geometryDiagnostic + " · " + cache.diagnostic
        if geometryDiagnostic != diagnostic { geometryDiagnostic = diagnostic }
    }

    func showFirstSuggestion() {
        guard let snapshot else { return }
        let located = editor.locate(suggestions, in: snapshot)
        overlay.update(located)
        if let first = located.first { overlay.showCard(for: first, keyboard: true) }
    }

    func reviewNow() {
        failedSnapshot = nil
        errorUntil = .distantPast
        guard let input = snapshot else { editor.refresh(); return }
        // Explicit retry bypasses both successful and empty cached results.
        cache.removeAll()
        languageCache.removeAll()
        invalidate(clearSnapshot: false, cancelAutomatic: true)
        activeKey = cache.key(for: input, languageMode: preferences.languageMode)
        pending = (input, epoch)
        pump()
    }

    func translateCurrentFragment() {
        guard let input = snapshot, editor.isCurrent(input) else { return }
        let caret = input.selectedRange.location - input.fragment.range.location
        guard let chunk = ReviewChunker.window(in: input.fragment.text, caret: caret, limit: 1).first,
              chunk.isReviewable, let language = LanguageResolver.detect(chunk.text) else { return }
        overlay.hideCard()
        translation.translate(chunk.text, source: language.code, target: preferences.translationLanguage,
            bundleID: input.bundleID, label: L10n.text("Translation of the written passage"), anchor: AXAccess.bounds(input.element,
                range: NSRange(location: input.fragment.range.location + chunk.range.location, length: chunk.range.length)).map { rect in
                    CGRect(x: rect.minX, y: (NSScreen.screens.first?.frame.maxY ?? 0) - rect.maxY, width: rect.width, height: rect.height)
                })
    }

    private func translateSuggestion(_ suggestion: WritingSuggestion) {
        guard applicationTask == nil, let input = snapshot, editor.isCurrent(input),
              suggestions.contains(where: { $0.id == suggestion.id }), let text = suggestion.translationText else { return }
        translation.translate(text, source: suggestion.language, target: preferences.translationLanguage,
            bundleID: input.bundleID, label: L10n.text("Translation of the suggestion"), anchor: nil, suggestionID: suggestion.id)
    }

    private func accept(_ suggestion: WritingSuggestion) {
        guard applicationTask == nil, suggestion.canApply, let input = snapshot,
              editor.isCurrent(input), suggestions.contains(where: { $0.id == suggestion.id }) else { return }
        debounce?.cancel(); debounce = nil; pending = nil
        worker?.cancel(); alternativeLifetime.cancel()
        epoch = UUID()
        failedSnapshot = nil; errorUntil = .distantPast
        overlay.setApplicationState(.applying, for: suggestion.id)
        status = L10n.text("Applying in the editor…")
        applicationTask = Task { [weak self] in
            guard let self else { return }
            await self.apply(suggestion, input: input)
            self.applicationTask = nil
            self.editor.refresh()
            self.pump()
        }
    }

    private func apply(_ suggestion: WritingSuggestion, input: EditorSnapshot) async {
        let wasComplete = currentIsComplete
        let absolute = suggestions.map { $0.positioned(at: NSRange(location: input.fragment.range.location + $0.range.location, length: $0.range.length)) }
        let ignoredAbsolute = ignoredSuggestions.map {
            WritingSuggestion(kind: $0.kind, range: NSRange(location: input.fragment.range.location + $0.range.location, length: $0.range.length),
                original: $0.original, replacement: $0.replacement, language: suggestion.language, context: "")
        }
        let ignoredIDs = Set(ignoredAbsolute.map(\.id))
        let edit = TextEdit(range: NSRange(location: input.fragment.range.location + suggestion.range.location, length: suggestion.range.length),
                            original: suggestion.original, replacement: suggestion.replacement)
        let oldUnit = ReviewChunker.chunks(in: input.fragment.text).first { NSLocationInRange(suggestion.range.location, $0.range) }
        let oldResult = oldUnit.flatMap { cache.assessment($0.text, language: suggestion.language, bundleID: input.bundleID) }
        do {
            try await editor.replace(suggestion, in: input)
            guard let next = editor.continuation(from: input),
                  let remaining = SuggestionLedger.rebasing(absolute + ignoredAbsolute, after: edit,
                    from: input.fieldText, to: next.fieldText, replacingWholePassage: suggestion.kind != .correction) else {
                invalidate(clearSnapshot: true); editor.refresh(); return
            }
            let mapped = remaining.compactMap { item -> WritingSuggestion? in
                guard item.range.location >= next.fragment.range.location, NSMaxRange(item.range) <= NSMaxRange(next.fragment.range) else { return nil }
                return item.positioned(at: NSRange(location: item.range.location - next.fragment.range.location, length: item.range.length))
            }
            invalidate(clearSnapshot: false, preservingOverlay: true)
            snapshot = next
            ignoredSuggestions = Set(mapped.filter { ignoredIDs.contains($0.id) }.map(SuggestionSignature.init))
            let carried = mapped.filter { !ignoredIDs.contains($0.id) }
            activeKey = cache.key(for: next, languageMode: preferences.languageMode)
            detectedLanguage = L10n.languageName(suggestion.language)
            publish(carried, input: next)
            let reviewedRange = NSRange(location: edit.range.location - next.fragment.range.location,
                                        length: suggestion.replacement.utf16.count)
            let reviewedReplacement = cache.rememberReviewedReplacement(suggestion, in: next.fragment.text,
                range: reviewedRange, bundleID: next.bundleID)
            if wasComplete && (suggestion.kind == .correction || reviewedReplacement) {
                if suggestion.kind == .correction, let unit = oldUnit, let result = oldResult {
                    let localEdit = TextEdit(range: NSRange(location: suggestion.range.location - unit.range.location, length: suggestion.range.length),
                                             original: suggestion.original, replacement: suggestion.replacement)
                    if let newText = TextEdits.applying([localEdit], to: unit.text) {
                        cache.saveSentence(newText, revised: result.revised, language: suggestion.language,
                                           bundleID: input.bundleID, sentenceIssue: result.sentenceIssue, spellingOnly: result.spellingOnly)
                    }
                }
                finishRevision(carried.isEmpty ? L10n.text("Correction applied") : L10n.format("Correction applied · suggestions kept: %ld", carried.count))
                if oldResult?.spellingOnly == true {
                    finishRevision(status + L10n.text(" · Sentence review unavailable for this passage"))
                }
                if reviewedReplacement {
                    FileHandle.standardError.write(Data("editor-review phase=reused-reviewed-proposal bundle=\(input.bundleID) remaining=\(carried.count)\n".utf8))
                }
            } else {
                setStatus(L10n.text("Change applied · checking only the necessary passages…"))
                pending = (next, epoch); pump()
            }
        } catch {
            let message = error.localizedDescription
            status = message; errorUntil = Date().addingTimeInterval(6)
            guard editor.isCurrent(input) else { invalidate(clearSnapshot: true); return }
            failedSnapshot = input
            let retry = (error as? ReviewFailure).map { if case .selectionNotVerified = $0 { return true }; return false } ?? false
            overlay.setApplicationState(.failed(message, retryAllowed: retry), for: suggestion.id)
        }
    }

    private func dismiss(_ suggestion: WritingSuggestion) {
        if deferredAlternative?.id == suggestion.id {
            deferredAlternative = nil
            deferredDeadline?.cancel(); deferredDeadline = nil
        }
        ignoredSuggestions.insert(SuggestionSignature(suggestion))
        suggestions.removeAll { $0.id == suggestion.id }
        suggestionCount = suggestions.count
        overlay.hideCard()
        refreshGeometry()
        setStatus(suggestions.isEmpty ? L10n.text("Suggestion dismissed in this review") : L10n.format("Suggestions: %ld", suggestions.count))
        revisionMessage = status
        saveCurrentRevision()
    }

    private func requestAlternative(_ suggestion: WritingSuggestion) {
        guard applicationTask == nil, failedSnapshot == nil else { return }
        guard let input = snapshot, editor.isCurrent(input), suggestions.contains(where: { $0.id == suggestion.id }) else {
            overlay.finishAlternativeRequest(for: suggestion.id)
            return
        }
        if inferenceBusy {
            guard !alternativeLifetime.hasTimedOut else {
                overlay.setAlternativeState(.failed(L10n.text("The model is still finishing the request. The original correction is available.")), for: suggestion.id)
                return
            }
            // One queued request only; repeated clicks do not start duplicate generations.
            guard deferredAlternative == nil else { return }
            deferredAlternative = suggestion
            overlay.setAlternativeState(.queued, for: suggestion.id)
            setStatus(L10n.text("Alternative queued after the current review"))
            let token = epoch
            deferredDeadline = Task { [weak self] in
                do { try await Task.sleep(nanoseconds: 25_000_000_000) } catch { return }
                guard let self, self.epoch == token, self.deferredAlternative?.id == suggestion.id else { return }
                self.deferredAlternative = nil
                self.deferredDeadline = nil
                self.overlay.setAlternativeState(.failed(L10n.text("The current review is taking a while. The original correction is still available.")), for: suggestion.id)
            }
            return
        }
        let paragraph = input.fragment.text as NSString
        guard let selectedRange = AlternativeContext.range(in: input.fragment.text, anchor: suggestion.range.location) else {
            overlay.setAlternativeState(.failed(L10n.text("Split this passage before rewriting it.")), for: suggestion.id)
            return
        }
        let range = suggestion.kind == .style ? suggestion.range : selectedRange
        let text = paragraph.substring(with: range)
        let corrections = suggestions.filter { $0.kind == .correction }.map {
            TextEdit(range: $0.range, original: $0.original, replacement: $0.replacement)
        }
        let corrected = AlternativeContext.correctedText(in: input.fragment.text, range: range, corrections: corrections) ?? text
        let baseline = suggestion.kind == .style ? suggestion.replacement : corrected
        let historyKey = "\(range.location):\(range.length):\(suggestion.language):\(text)"
        var previous = alternativeHistory[historyKey] ?? []
        if suggestion.kind == .style, !previous.contains(suggestion.replacement) { previous.append(suggestion.replacement) }
        let token = epoch
        let requestID = alternativeLifetime.begin()
        inferenceBusy = true
        generatingAlternative = true
        overlay.setAlternativeState(.generating, for: suggestion.id)
        setStatus(L10n.text("Generating an alternative on device…"))
        alternativeDeadline = Task { [weak self] in
            do { try await Task.sleep(nanoseconds: 25_000_000_000) } catch { return }
            guard let self, self.epoch == token, self.alternativeLifetime.timeout(requestID) else { return }
            self.worker?.cancel()
            self.presentAlternative(baseline, original: text, range: range, input: input, source: suggestion,
                historyKey: historyKey, previous: previous,
                notice: L10n.text("The model took too long. Showing the version with the corrections already available."))
            if let queued = self.deferredAlternative {
                self.overlay.setAlternativeState(.failed(L10n.text("The previous request took too long. The original correction is still available.")), for: queued.id)
                self.deferredAlternative = nil
                self.deferredDeadline?.cancel(); self.deferredDeadline = nil
            }
            self.setStatus(L10n.text("Rewrite stopped because the model took too long"))
        }
        worker = Task { [weak self] in
            guard let self else { return }
            defer {
                self.alternativeDeadline?.cancel(); self.alternativeDeadline = nil
                self.alternativeLifetime.finish()
                self.overlay.finishAlternativeRequest(for: suggestion.id)
                self.finishWorker()
            }
            do {
                let result = try await self.model.preparedAlternative(baseline, language: suggestion.language, excluding: previous)
                guard self.alternativeLifetime.accepts(requestID), self.valid(token, input),
                      self.suggestions.contains(where: { $0.id == suggestion.id }) else { return }
                let revised = result.text
                let notice = result.generatedNewWording ? nil : (revised == text
                    ? L10n.text("Text preserved: no further safe improvement was found.")
                    : L10n.text("Text reviewed. Your idea and most of your wording were preserved."))
                self.presentAlternative(revised, original: text, range: range, input: input, source: suggestion,
                    historyKey: historyKey, previous: previous, notice: notice, hasReviewedReplacement: true)
            } catch {
                if self.valid(token, input), self.suggestions.contains(where: { $0.id == suggestion.id }) {
                    self.presentAlternative(baseline, original: text, range: range, input: input, source: suggestion,
                        historyKey: historyKey, previous: previous,
                        notice: L10n.text("Could not generate another version. Showing the text with the available corrections."))
                }
            }
        }
    }

    private func presentAlternative(_ revised: String, original: String, range: NSRange, input: EditorSnapshot,
                                    source: WritingSuggestion, historyKey: String, previous: [String], notice: String?,
                                    hasReviewedReplacement: Bool = false) {
        guard applicationTask == nil, editor.isCurrent(input),
              suggestions.contains(where: { $0.id == source.id }),
              !revised.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              TextEdits.preservesProtectedContent(original, revised) else { return }
        if !previous.contains(revised) { alternativeHistory[historyKey] = Array((previous + [revised]).suffix(12)) }
        let item = WritingSuggestion(id: source.kind == .style && source.replacement == revised ? source.id : UUID(),
            kind: .style, range: range, original: original, replacement: revised, language: source.language,
            context: original, isFragment: input.fragment.isTruncated || range.length < input.fragment.text.utf16.count,
            hasReviewedReplacement: hasReviewedReplacement)
        let combined = SuggestionLedger.proposing(item, alongside: suggestions)
        let keepOpen = overlay.finishAlternativeRequest(for: source.id, presenting: item.id)
        publish(combined, input: input)
        if let notice { overlay.setAlternativeState(.unavailable(notice), for: item.id) }
        if keepOpen { overlay.showSuggestion(id: item.id) }
        setStatus(revised == original ? L10n.text("Text preserved in the card") : L10n.text("Text suggestion available"))
        revisionMessage = status
        saveCurrentRevision()
    }

    func blockCurrentApplication() {
        guard let app = editor.lastExternalApplication, let identifier = app.bundleIdentifier else { return }
        preferences.block(bundleID: identifier, name: app.localizedName ?? identifier)
        cache.removeAll()
        languageCache.removeAll()
        invalidate(clearSnapshot: true)
        editor.refresh()
    }
}
