import AppKit
import ApplicationServices
import WritingCore

/// Exercises the actual store and local model using synthetic snapshots; never reads/writes a host editor.
@MainActor
enum CacheSmokeCheck {
    struct Failure: Error { let reason: String }

    static func run() async throws {
        let store = ReviewSessionCache()
        let text = "She go to school every days."
        let element = AXUIElementCreateApplication(ProcessInfo.processInfo.processIdentifier)
        func input(_ text: String, element: AXUIElement) -> EditorSnapshot {
            let range = NSRange(location: 0, length: text.utf16.count)
            return EditorSnapshot(element: element, pid: ProcessInfo.processInfo.processIdentifier,
                bundleID: "dev.localscribe.synthetic-cache-test", appName: "Synthetic", fieldText: text,
                selectedRange: NSRange(location: text.utf16.count, length: 0),
                fragment: WritingFragment(fieldText: text, caret: text.utf16.count)!, analysisWindow: range)
        }
        let first = input(text, element: element)
        let key = store.key(for: first, languageMode: "automatic")
        store.willCallModel()
        let revised = try await LocalModelService().revise(text, language: "en")
        let proposals = TextEdits.wordEdits(text, revised).map {
            WritingSuggestion(kind: .correction, range: $0.range, original: $0.original,
                replacement: $0.replacement, language: "en", context: text)
        }
        guard proposals.count == 2 else { throw Failure(reason: "Expected two synthetic corrections") }
        store.saveSentence(text, revised: revised, language: "en", bundleID: first.bundleID)
        store.save(CachedFieldRevision(suggestions: proposals, ignored: [], history: [:], language: "English",
            message: "2 corrections", complete: true), for: key)
        // Leaving focus does not mutate the process-local store. A fresh AX reference must identify the same field.
        let returnInput = input(text, element: AXUIElementCreateApplication(ProcessInfo.processInfo.processIdentifier))
        let returnKey = store.key(for: returnInput, languageMode: "automatic")
        guard let restored = store.revision(for: returnKey), restored.complete,
              restored.suggestions.map(\.id) == proposals.map(\.id), store.modelCalls == 1 else {
            throw Failure(reason: "Completed revision did not survive the focus gap")
        }
        let ignored = SuggestionSignature(proposals[0])
        let history = ["synthetic": ["A different phrasing."]]
        store.save(CachedFieldRevision(suggestions: Array(proposals.dropFirst()), ignored: [ignored], history: history,
            language: "English", message: "1 correction", complete: true), for: key)
        guard let decision = store.revision(for: returnKey), decision.ignored.contains(ignored), decision.history == history,
              decision.suggestions.count == 1 else { throw Failure(reason: "Ignore/history not retained") }
        let changedKey = store.key(for: input("She goes to school every day.", element: element), languageMode: "automatic")
        guard store.revision(for: changedKey) == nil else { throw Failure(reason: "Changed text reused stale ranges") }
        let otherField = store.key(for: input(text, element: AXUIElementCreateSystemWide()), languageMode: "automatic")
        guard store.revision(for: otherField) == nil else { throw Failure(reason: "Different field reused decisions") }
        let manual = store.key(for: first, languageMode: "pt")
        guard store.revision(for: manual) == nil else { throw Failure(reason: "Different language reused decisions") }
        guard store.sentence(text, language: "en", bundleID: first.bundleID) == revised,
              store.sentence(text, language: "en", bundleID: "another.app") == nil else {
            throw Failure(reason: "Sentence reuse/app isolation failed")
        }
        store.save(CachedFieldRevision(suggestions: [], ignored: [], history: [:], language: "English",
            message: "No corrections", complete: true), for: changedKey)
        guard store.revision(for: changedKey)?.complete == true else { throw Failure(reason: "Empty result was not cached") }
        store.removeAll()
        guard store.revision(for: key) == nil, store.sentence(text, language: "en", bundleID: first.bundleID) == nil else {
            throw Failure(reason: "Privacy reset did not purge results")
        }
        let record: [String: Any] = ["result": "passed", "modelCalls": store.modelCalls,
            "restoredCorrections": proposals.count, "ignoreAndHistoryRestored": true,
            "changedTextRejected": true, "differentFieldRejected": true, "languageIsolated": true,
            "emptyResultCached": true, "privacyReset": true, "hostEditorTested": false]
        print(String(decoding: try JSONSerialization.data(withJSONObject: record, options: [.sortedKeys]), as: UTF8.self))
    }
}
