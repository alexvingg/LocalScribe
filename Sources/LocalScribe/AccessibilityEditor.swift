import AppKit
import ApplicationServices
import WritingCore

enum AXAccess {
    private static var lastContainerProbe: (pid: pid_t, node: AXUIElement, date: Date, resolved: AXUIElement?)?
    static var lastFailure = "No AX failure recorded"
    static func value(_ element: AXUIElement, _ name: String) -> CFTypeRef? {
        var result: CFTypeRef?
        let error = AXUIElementCopyAttributeValue(element, name as CFString, &result)
        guard error == .success else { lastFailure = "\(name): AX error \(error.rawValue)"; return nil }
        return result
    }
    static func element(_ element: AXUIElement, _ name: String) -> AXUIElement? {
        guard let result = value(element, name), CFGetTypeID(result) == AXUIElementGetTypeID() else { return nil }
        return (result as! AXUIElement)
    }
    static func string(_ element: AXUIElement, _ name: String) -> String? {
        let result = value(element, name)
        return (result as? String) ?? (result as? NSAttributedString)?.string
    }
    @discardableResult
    static func enableAccessibility(on root: AXUIElement) -> (attribute: String, status: AXError) {
        let manual = "AXManualAccessibility"
        let result = AXUIElementSetAttributeValue(root, manual as CFString, kCFBooleanTrue)
        if result == .success { return (manual, result) }
        // Native WebView hosts can expose the AppKit enhanced bridge instead
        // of Electron's manual flag. Ask only when the provider advertises it.
        let enhanced = "AXEnhancedUserInterface"
        if settable(root, enhanced) {
            return (enhanced, AXUIElementSetAttributeValue(root, enhanced as CFString, kCFBooleanTrue))
        }
        return (manual, result)
    }
    static func focusedElement(root: AXUIElement, pid: pid_t) -> AXUIElement? {
        guard let focused = rawFocusedElement(root: root, pid: pid) else { return nil }
        var candidate: AXUIElement? = focused
        // Some web/native editors focus an inner static-text/group node. Inspect metadata only.
        for _ in 0..<7 {
            guard let node = candidate else { break }
            AXUIElementSetMessagingTimeout(node, 0.15)
            if string(node, kAXSubroleAttribute) == kAXSecureTextFieldSubrole { return node }
            let role = string(node, kAXRoleAttribute) ?? ""
            if [kAXTextAreaRole, kAXTextFieldRole, kAXComboBoxRole].contains(role) { return node }
            if role == kAXGroupRole, selectionWritable(node),
               settable(node, kAXSelectedTextAttribute) || settable(node, kAXValueAttribute) { return node }
            if role == kAXApplicationRole || role == kAXWindowRole { break }
            candidate = element(node, kAXParentAttribute)
        }
        if [kAXWindowRole, kAXGroupRole, "AXWebArea"].contains(string(focused, kAXRoleAttribute) ?? "") {
            if let last = lastContainerProbe, last.pid == pid, CFEqual(last.node, focused), Date().timeIntervalSince(last.date) < 1 {
                if let resolved = last.resolved, (value(resolved, kAXFocusedAttribute) as? Bool) == true { return resolved }
                if last.resolved == nil { return focused }
            }
            lastContainerProbe = (pid, focused, Date(), nil)
            let deadline = Date().addingTimeInterval(0.25)
            var stack: [(AXUIElement, Int)] = [(focused, 0)]
            var matches: [AXUIElement] = [], visited = 0
            while let (node, depth) = stack.popLast(), visited < 256, Date() < deadline {
                visited += 1
                AXUIElementSetMessagingTimeout(node, 0.1)
                let role = string(node, kAXRoleAttribute) ?? ""
                if [kAXTextAreaRole, kAXTextFieldRole, kAXComboBoxRole].contains(role),
                   (value(node, kAXFocusedAttribute) as? Bool) == true { matches.append(node) }
                if depth < 24, !["AXList", "AXOutline", "AXTable"].contains(role),
                   let children = value(node, kAXChildrenAttribute) as? [AXUIElement] {
                    stack += children.reversed().map { ($0, depth + 1) }
                }
            }
            if matches.count == 1 {
                lastContainerProbe = (pid, focused, Date(), matches[0])
                return matches[0]
            }
        }
        return focused
    }
    private static func rawFocusedElement(root: AXUIElement, pid: pid_t) -> AXUIElement? {
        let system = AXUIElementCreateSystemWide()
        AXUIElementSetMessagingTimeout(system, 0.3)
        if let focused = element(system, kAXFocusedUIElementAttribute) {
            var owner: pid_t = 0
            if AXUIElementGetPid(focused, &owner) == .success, owner == pid { return focused }
        }
        return element(root, kAXFocusedUIElementAttribute)
    }
    static func range(_ element: AXUIElement, _ name: String) -> NSRange? {
        let single = value(element, name)
        let result = single ?? (name == kAXSelectedTextRangeAttribute
            ? (value(element, kAXSelectedTextRangesAttribute) as? [AXValue])?.first : nil)
        guard let result, CFGetTypeID(result) == AXValueGetTypeID() else { return nil }
        var range = CFRange()
        guard AXValueGetValue(result as! AXValue, .cfRange, &range), range.location >= 0, range.length >= 0 else { return nil }
        return NSRange(location: range.location, length: range.length)
    }
    static func frame(_ element: AXUIElement) -> CGRect? {
        guard let position = value(element, kAXPositionAttribute), let size = value(element, kAXSizeAttribute),
              CFGetTypeID(position) == AXValueGetTypeID(), CFGetTypeID(size) == AXValueGetTypeID() else { return nil }
        var point = CGPoint.zero, dimensions = CGSize.zero
        guard AXValueGetValue(position as! AXValue, .cgPoint, &point), AXValueGetValue(size as! AXValue, .cgSize, &dimensions) else { return nil }
        return CGRect(origin: point, size: dimensions)
    }
    static func bounds(_ element: AXUIElement, range: NSRange) -> CGRect? {
        var range = CFRange(location: range.location, length: range.length)
        guard let parameter = AXValueCreate(.cfRange, &range) else { return nil }
        var result: CFTypeRef?
        guard AXUIElementCopyParameterizedAttributeValue(element, kAXBoundsForRangeParameterizedAttribute as CFString,
            parameter, &result) == .success,
            let result, CFGetTypeID(result) == AXValueGetTypeID() else { return nil }
        var rect = CGRect.zero
        guard AXValueGetValue(result as! AXValue, .cgRect, &rect), !rect.isEmpty else { return nil }
        return rect
    }
    static func settable(_ element: AXUIElement, _ attribute: String) -> Bool {
        var result: DarwinBoolean = false
        return AXUIElementIsAttributeSettable(element, attribute as CFString, &result) == .success && result.boolValue
    }
    static func setRange(_ range: NSRange, on element: AXUIElement) -> Bool {
        var range = CFRange(location: range.location, length: range.length)
        guard let value = AXValueCreate(.cfRange, &range) else { return false }
        if settable(element, kAXSelectedTextRangeAttribute) {
            return AXUIElementSetAttributeValue(element, kAXSelectedTextRangeAttribute as CFString, value) == .success
        }
        return AXUIElementSetAttributeValue(element, kAXSelectedTextRangesAttribute as CFString, [value] as CFArray) == .success
    }
    static func selectionWritable(_ element: AXUIElement) -> Bool {
        settable(element, kAXSelectedTextRangeAttribute) || settable(element, kAXSelectedTextRangesAttribute)
    }
    static func isWebContent(_ field: AXUIElement) -> Bool {
        var parameters: CFArray?
        if AXUIElementCopyParameterizedAttributeNames(field, &parameters) == .success,
           let names = parameters as? [String],
           names.contains("AXTextMarkerRangeForUIElement") || names.contains("AXTextMarkerForPosition") { return true }
        var candidate: AXUIElement? = field
        for _ in 0..<24 {
            guard let node = candidate else { return false }
            let role = string(node, kAXRoleAttribute)
            if role == "AXWebArea" { return true }
            if role == kAXApplicationRole || role == kAXWindowRole { return false }
            candidate = element(node, kAXParentAttribute)
        }
        return false
    }
    static func editStrategy(_ field: AXUIElement) -> EditorEditStrategy {
        EditorCompatibility.editStrategy(selectionWritable: selectionWritable(field),
            selectedTextWritable: settable(field, kAXSelectedTextAttribute), valueWritable: settable(field, kAXValueAttribute),
            webContent: isWebContent(field), secure: string(field, kAXSubroleAttribute) == kAXSecureTextFieldSubrole)
    }
}

struct EditorSnapshot {
    let element: AXUIElement
    let pid: pid_t
    let bundleID: String
    let appName: String
    let fieldText: String
    let selectedRange: NSRange
    let fragment: WritingFragment
    let analysisWindow: NSRange

    func sameRevision(as other: EditorSnapshot) -> Bool {
        pid == other.pid && bundleID == other.bundleID && CFEqual(element, other.element)
            && fieldText == other.fieldText && fragment == other.fragment && analysisWindow == other.analysisWindow
    }
}

struct LocatedSuggestion {
    let suggestion: WritingSuggestion
    let rects: [CGRect] // AppKit global screen coordinates.
    var isFieldAnchor = false
}

@MainActor
final class AccessibilityEditor {
    let preferences: Preferences
    var onSnapshot: ((EditorSnapshot?) -> Void)?
    var onStatus: ((String) -> Void)?
    var onTick: (() -> Void)?
    private(set) var lastExternalApplication: NSRunningApplication?
    private(set) var geometryDiagnostic = L10n.text("No positioned suggestions")
    private var timer: Timer?
    private var activationToken: NSObjectProtocol?
    private var observer: AXObserver?
    private var observedField: AXUIElement?
    private var observedPID: pid_t?
    private let ownPID = ProcessInfo.processInfo.processIdentifier
    private var writeInProgress = false
    private struct AccessibilityActivation { let attempted: Date; let attempts: Int; var editorObserved: Bool }
    private var accessibilityActivation: [pid_t: AccessibilityActivation] = [:]

    init(preferences: Preferences) { self.preferences = preferences }

    func start() {
        activationToken = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification, object: nil, queue: .main
        ) { [weak self] _ in Task { @MainActor in self?.refresh() } }
        timer = Timer.scheduledTimer(withTimeInterval: 0.35, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.refresh(); self?.onTick?() }
        }
        refresh()
    }

    func stop() {
        timer?.invalidate(); timer = nil
        if let activationToken { NSWorkspace.shared.notificationCenter.removeObserver(activationToken) }
        activationToken = nil
        clearObserver()
    }

    func requestPermission() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        _ = AXIsProcessTrustedWithOptions(options)
        refresh()
    }

    func refresh() {
        guard !writeInProgress else { return }
        guard !preferences.paused else { unavailable(L10n.text("Checking paused")); return }
        guard AXIsProcessTrusted() else { unavailable(L10n.text("Allow Accessibility to check text in other apps")); return }
        guard let app = NSWorkspace.shared.frontmostApplication, app.processIdentifier != ownPID else {
            unavailable(L10n.text("Write in a supported app")); return
        }
        lastExternalApplication = app
        guard let identifier = app.bundleIdentifier else { unavailable(L10n.text("App without a verifiable identity")); return }
        // Check the exclusion policy before asking AX for any field or text.
        guard !preferences.isBlocked(identifier) else { unavailable(L10n.format("Checking disabled in %@", app.localizedName ?? identifier)); return }
        let root = AXUIElementCreateApplication(app.processIdentifier)
        AXUIElementSetMessagingTimeout(root, 0.15)
        var focused = AXAccess.focusedElement(root: root, pid: app.processIdentifier)
        let hasTypedEditor = focused.map { node in
            let role = AXAccess.string(node, kAXRoleAttribute) ?? ""
            return [kAXTextAreaRole, kAXTextFieldRole, kAXComboBoxRole].contains(role)
                || (role == kAXGroupRole && AXAccess.selectionWritable(node)
                    && (AXAccess.settable(node, kAXSelectedTextAttribute) || AXAccess.settable(node, kAXValueAttribute)))
        } ?? false
        let activation = accessibilityActivation[app.processIdentifier]
        let retryDelay: TimeInterval = (activation?.attempts ?? 0) < 3 ? 2 : 30
        if activation == nil || (!hasTypedEditor && activation?.editorObserved == false
            && Date().timeIntervalSince(activation!.attempted) >= retryDelay) {
            // Electron may report false even with a usable tree. Confirm an actual editor,
            // not its mode flag, and stop retrying as soon as the provider supplies one.
            _ = AXAccess.string(root, kAXRoleAttribute)
            AXAccess.enableAccessibility(on: root)
            accessibilityActivation[app.processIdentifier] = AccessibilityActivation(attempted: Date(),
                attempts: (activation?.attempts ?? 0) + 1, editorObserved: hasTypedEditor)
            focused = AXAccess.focusedElement(root: root, pid: app.processIdentifier)
            if accessibilityActivation.count > 64 {
                accessibilityActivation = accessibilityActivation.filter { Date().timeIntervalSince($0.value.attempted) < 120 }
            }
        } else if hasTypedEditor { accessibilityActivation[app.processIdentifier]?.editorObserved = true }
        guard let field = focused else {
            unavailable(L10n.text("Select a text field")); return
        }
        AXUIElementSetMessagingTimeout(field, 0.15)
        let role = AXAccess.string(field, kAXRoleAttribute) ?? ""
        let subrole = AXAccess.string(field, kAXSubroleAttribute) ?? ""
        let editableGroup = role == kAXGroupRole && AXAccess.selectionWritable(field)
            && (AXAccess.settable(field, kAXSelectedTextAttribute) || AXAccess.settable(field, kAXValueAttribute))
        guard [kAXTextAreaRole, kAXTextFieldRole, kAXComboBoxRole].contains(role) || editableGroup,
              subrole != kAXSecureTextFieldSubrole else {
            unavailable(L10n.format("Field does not support checking in %@", app.localizedName ?? identifier),
                        detail: L10n.format("Role: %@; subrole: %@; %@", role.isEmpty ? L10n.text("unavailable") : role, subrole, AXAccess.lastFailure))
            return
        }
        if let size = AXAccess.value(field, kAXNumberOfCharactersAttribute) as? NSNumber, size.intValue > ReviewChunker.maximumFieldUTF16 {
            unavailable(L10n.text("This field is too large for the prototype")); return
        }
        guard let text = AXAccess.string(field, kAXValueAttribute), text.utf16.count <= ReviewChunker.maximumFieldUTF16,
              let selection = AXAccess.range(field, kAXSelectedTextRangeAttribute),
              NSMaxRange(selection) <= text.utf16.count else {
            unavailable(L10n.text("The editor does not provide text and position through Accessibility")); return
        }
        observe(pid: app.processIdentifier, root: root, field: field)
        guard let fragment = WritingFragment(fieldText: text, caret: selection.location) else {
            onSnapshot?(nil)
            onStatus?(text.isEmpty ? L10n.text("Waiting for text") : L10n.text("Passage empty or without enough word boundaries to review"))
            return
        }
        let units = ReviewChunker.window(in: fragment.text, caret: selection.location - fragment.range.location)
        let analysisWindow = units.reduce(NSRange(location: NSNotFound, length: 0)) { result, unit in
            result.location == NSNotFound ? unit.range : NSUnionRange(result, unit.range)
        }
        onSnapshot?(EditorSnapshot(element: field, pid: app.processIdentifier, bundleID: identifier,
            appName: app.localizedName ?? identifier, fieldText: text, selectedRange: selection, fragment: fragment,
            analysisWindow: analysisWindow))
    }

    private func unavailable(_ message: String, detail: String? = nil) {
        geometryDiagnostic = detail ?? L10n.text("No positioned suggestions")
        clearObserver()
        onSnapshot?(nil)
        onStatus?(message)
    }

    private func observe(pid: pid_t, root: AXUIElement, field: AXUIElement) {
        if observedPID == pid, let observedField, CFEqual(observedField, field) { return }
        clearObserver()
        var result: AXObserver?
        let callback: AXObserverCallback = { _, _, _, context in
            guard let context else { return }
            let owner = Unmanaged<AccessibilityEditor>.fromOpaque(context).takeUnretainedValue()
            Task { @MainActor in owner.refresh() }
        }
        guard AXObserverCreate(pid, callback, &result) == .success, let result else { return }
        observer = result; observedPID = pid; observedField = field
        let context = Unmanaged.passUnretained(self).toOpaque()
        _ = AXObserverAddNotification(result, root, kAXFocusedUIElementChangedNotification as CFString, context)
        _ = AXObserverAddNotification(result, field, kAXValueChangedNotification as CFString, context)
        _ = AXObserverAddNotification(result, field, kAXSelectedTextChangedNotification as CFString, context)
        CFRunLoopAddSource(CFRunLoopGetMain(), AXObserverGetRunLoopSource(result), .commonModes)
    }

    private func clearObserver() {
        if let observer { CFRunLoopRemoveSource(CFRunLoopGetMain(), AXObserverGetRunLoopSource(observer), .commonModes) }
        observer = nil; observedField = nil; observedPID = nil
    }

    private func sameFocusedField(_ snapshot: EditorSnapshot) -> Bool {
        guard !preferences.paused, !preferences.isBlocked(snapshot.bundleID), AXIsProcessTrusted(),
              NSWorkspace.shared.frontmostApplication?.processIdentifier == snapshot.pid else { return false }
        let app = AXUIElementCreateApplication(snapshot.pid)
        guard let focused = AXAccess.focusedElement(root: app, pid: snapshot.pid), CFEqual(focused, snapshot.element) else { return false }
        return true
    }

    func isCurrent(_ snapshot: EditorSnapshot) -> Bool {
        sameFocusedField(snapshot) && AXAccess.string(snapshot.element, kAXValueAttribute) == snapshot.fieldText
    }

    private func traceWrite(_ message: String) {
        FileHandle.standardError.write(Data(("editor-write " + message + "\n").utf8))
    }

    private func awaitValue(_ expected: String, replacing original: String, in snapshot: EditorSnapshot,
                            selection: NSRange? = nil) async throws {
        let deadline = ContinuousClock.now.advanced(by: .seconds(2))
        repeat {
            try Task.checkCancellation()
            switch EditAcknowledgement.observe(original: original, expected: expected,
                actual: AXAccess.string(snapshot.element, kAXValueAttribute), sameDestination: sameFocusedField(snapshot)) {
            case .confirmed:
                if selection == nil || AXAccess.range(snapshot.element, kAXSelectedTextRangeAttribute) == selection { return }
            case .destinationChanged: throw ReviewFailure.changedDestination
            case .unexpectedText: throw ReviewFailure.notVerified
            case .waiting: break
            }
            guard ContinuousClock.now < deadline else { throw ReviewFailure.notVerified }
            try await Task.sleep(nanoseconds: 20_000_000)
        } while true
    }

    func replace(_ suggestion: WritingSuggestion, in snapshot: EditorSnapshot) async throws {
        guard !writeInProgress, isCurrent(snapshot) else { throw ReviewFailure.changedDestination }
        let source = snapshot.fieldText as NSString
        let target = NSRange(location: snapshot.fragment.range.location + suggestion.range.location, length: suggestion.range.length)
        guard target.location >= 0, NSMaxRange(target) <= source.length, Range(target, in: snapshot.fieldText) != nil,
              source.substring(with: target) == suggestion.original else { throw ReviewFailure.changedDestination }
        let strategy = AXAccess.editStrategy(snapshot.element)
        let browserInput = strategy == .nativeInput
        let chunks = browserInput ? BrowserTextInputPlan.chunks(for: suggestion.replacement) : []
        guard strategy != .readOnly, AXAccess.selectionWritable(snapshot.element),
              browserInput ? chunks != nil : AXAccess.settable(snapshot.element, kAXSelectedTextAttribute) else { throw ReviewFailure.notWritable }
        writeInProgress = true
        defer { writeInProgress = false }
        let oldSelection = AXAccess.range(snapshot.element, kAXSelectedTextRangeAttribute)
        var dispatched = false
        do {
            guard AXAccess.setRange(target, on: snapshot.element) else { throw ReviewFailure.notWritable }
            // Chromium acknowledges the IPC before its renderer has necessarily changed the selection.
            let selectionDeadline = ContinuousClock.now.advanced(by: .milliseconds(900))
            while AXAccess.range(snapshot.element, kAXSelectedTextRangeAttribute) != target {
                try Task.checkCancellation()
                guard isCurrent(snapshot) else { throw ReviewFailure.changedDestination }
                guard ContinuousClock.now < selectionDeadline else { throw ReviewFailure.selectionNotVerified }
                try await Task.sleep(nanoseconds: 20_000_000)
            }
            guard isCurrent(snapshot) else { throw ReviewFailure.changedDestination }
            try Task.checkCancellation()
            traceWrite("phase=selection-confirmed bundle=\(snapshot.bundleID)")
            if browserInput {
                if chunks!.count > 1 {
                    guard let (down, up) = NativeBrowserInput.pasteEvents(),
                          let clipboard = BrowserPasteTransaction(text: suggestion.replacement) else { throw ReviewFailure.notWritable }
                    defer { clipboard.restore() }
                    guard isCurrent(snapshot), AXAccess.range(snapshot.element, kAXSelectedTextRangeAttribute) == target,
                          clipboard.stage() else { throw ReviewFailure.changedDestination }
                    guard isCurrent(snapshot), AXAccess.range(snapshot.element, kAXSelectedTextRangeAttribute) == target else {
                        throw ReviewFailure.changedDestination
                    }
                    dispatched = true
                    down.postToPid(snapshot.pid); up.postToPid(snapshot.pid)
                    let expected = source.replacingCharacters(in: target, with: suggestion.replacement)
                    try await awaitValue(expected, replacing: snapshot.fieldText, in: snapshot,
                        selection: NSRange(location: target.location + suggestion.replacement.utf16.count, length: 0))
                    traceWrite("phase=verified adapter=native-paste bundle=\(snapshot.bundleID)")
                    return
                }
                var previous = snapshot.fieldText, inserted = ""
                var selection = target
                let deadline = ContinuousClock.now.advanced(by: .seconds(8))
                // An empty replacement means delete this selection, never a Return event.
                let parts = chunks!.isEmpty ? [""] : chunks!
                for part in parts {
                    try Task.checkCancellation()
                    guard ContinuousClock.now < deadline, sameFocusedField(snapshot),
                          AXAccess.string(snapshot.element, kAXValueAttribute) == previous,
                          AXAccess.range(snapshot.element, kAXSelectedTextRangeAttribute) == selection else {
                        throw ReviewFailure.changedDestination
                    }
                    guard let (down, up) = NativeBrowserInput.events(text: part, deleting: suggestion.replacement.isEmpty) else {
                        throw ReviewFailure.notWritable
                    }
                    dispatched = true
                    down.postToPid(snapshot.pid); up.postToPid(snapshot.pid)
                    inserted += part
                    let expected = source.replacingCharacters(in: target, with: inserted)
                    selection = NSRange(location: target.location + inserted.utf16.count, length: 0)
                    try await awaitValue(expected, replacing: previous, in: snapshot, selection: selection)
                    previous = expected
                }
                traceWrite("phase=verified adapter=native-text-input bundle=\(snapshot.bundleID)")
                return
            }
            let result = AXUIElementSetAttributeValue(snapshot.element, kAXSelectedTextAttribute as CFString,
                                                      suggestion.replacement as CFString)
            traceWrite("phase=dispatched axStatus=\(result.rawValue)")
            dispatched = true // Even an AX error may be returned after the renderer received the operation.
            guard result == .success else { throw ReviewFailure.notVerified }
            let expected = source.replacingCharacters(in: target, with: suggestion.replacement)
            try await awaitValue(expected, replacing: snapshot.fieldText, in: snapshot)
            traceWrite("phase=verified adapter=accessibility")
        } catch {
            // A dispatched edit is never repeated or undone blindly. Before dispatch, restore only this unchanged field.
            traceWrite("phase=failed dispatched=\(dispatched) error=\(error)")
            if !dispatched, isCurrent(snapshot), AXAccess.range(snapshot.element, kAXSelectedTextRangeAttribute) == target,
               let oldSelection { _ = AXAccess.setRange(oldSelection, on: snapshot.element) }
            throw error
        }
    }

    /// Capture the verified editor synchronously, before queued value-change notifications run.
    func continuation(from previous: EditorSnapshot) -> EditorSnapshot? {
        guard !preferences.paused, !preferences.isBlocked(previous.bundleID), AXIsProcessTrusted(),
              NSWorkspace.shared.frontmostApplication?.processIdentifier == previous.pid else { return nil }
        let root = AXUIElementCreateApplication(previous.pid)
        guard let focused = AXAccess.focusedElement(root: root, pid: previous.pid), CFEqual(focused, previous.element),
              let text = AXAccess.string(focused, kAXValueAttribute),
              let selection = AXAccess.range(focused, kAXSelectedTextRangeAttribute), NSMaxRange(selection) <= text.utf16.count,
              let fragment = WritingFragment(fieldText: text, caret: selection.location) else { return nil }
        let units = ReviewChunker.window(in: fragment.text, caret: selection.location - fragment.range.location)
        let window = units.reduce(NSRange(location: NSNotFound, length: 0)) { result, unit in
            result.location == NSNotFound ? unit.range : NSUnionRange(result, unit.range)
        }
        return EditorSnapshot(element: focused, pid: previous.pid, bundleID: previous.bundleID, appName: previous.appName,
            fieldText: text, selectedRange: selection, fragment: fragment, analysisWindow: window)
    }

    func locate(_ suggestions: [WritingSuggestion], in snapshot: EditorSnapshot) -> [LocatedSuggestion] {
        guard isCurrent(snapshot) else { geometryDiagnostic = L10n.text("Destination unfocused or text changed"); return [] }
        let fieldFrame = AXAccess.frame(snapshot.element)
        let windowFrame = AXAccess.element(snapshot.element, kAXWindowAttribute).flatMap { AXAccess.frame($0) }
        let source = snapshot.fieldText as NSString
        let geometry = EditorTextGeometry(field: snapshot.element, text: snapshot.fieldText)
        var located: [LocatedSuggestion] = []
        let windows = CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID) as? [[String: Any]] ?? []
        var boundsCount = 0, clippedCount = 0, occludedCount = 0
        for suggestion in suggestions {
            var range = NSRange(location: snapshot.fragment.range.location + suggestion.range.location, length: suggestion.range.length)
            if suggestion.kind == .style || range.length == 0 {
                let index = min(max(0, (suggestion.kind == .style ? NSMaxRange(range) : range.location) - 1), source.length - 1)
                range = source.rangeOfComposedCharacterSequence(at: index)
            }
            guard NSMaxRange(range) <= source.length else { continue }
            var pieces: [CGRect] = [], count = 0
            source.enumerateSubstrings(in: range, options: [.byComposedCharacterSequences, .substringNotRequired]) { _, characterRange, _, stop in
                count += 1
                if count > 80 { stop.pointee = true; return }
                guard let raw = geometry.bounds(for: characterRange) else { return }
                boundsCount += 1
                let rect = fieldFrame.map { raw.intersection($0) } ?? raw
                guard !rect.isNull, !rect.isEmpty else { clippedCount += 1; return }
                guard self.visible(rect, for: snapshot.pid, windows: windows) else { occludedCount += 1; return }
                if let last = pieces.last, abs(last.minY - rect.minY) < 2, abs(last.height - rect.height) < 3,
                   rect.minX >= last.minX, rect.minX <= last.maxX + 3 {
                    pieces[pieces.count - 1] = last.union(rect)
                } else { pieces.append(rect) }
            }
            let screenTop = NSScreen.screens.first?.frame.maxY ?? 0
            let converted = pieces.map { CGRect(x: $0.minX, y: screenTop - $0.maxY, width: $0.width, height: $0.height) }
            if !converted.isEmpty { located.append(LocatedSuggestion(suggestion: suggestion, rects: converted)) }
            else if let frame = fieldFrame ?? windowFrame, frame.width >= 48, frame.height >= 24 {
                // This is a clearly distinct count badge, never a guessed underline on a word.
                let anchor = CGRect(x: frame.maxX - 32, y: frame.maxY - 22, width: 26, height: 18)
                if visible(anchor, for: snapshot.pid, windows: windows) {
                    located.append(LocatedSuggestion(suggestion: suggestion, rects: [CGRect(x: anchor.minX,
                        y: screenTop - anchor.maxY, width: anchor.width, height: anchor.height)], isFieldAnchor: true))
                }
            }
        }
        geometryDiagnostic = L10n.format("Geometry: %@; rectangles: %ld; outside field: %ld; occluded: %ld; marks: %ld; no exact position: %ld; windows: %ld", geometry.usedTextLeaves ? L10n.text("internal web text") : L10n.text("field"), boundsCount, clippedCount, occludedCount, located.count, located.filter(\.isFieldAnchor).count, windows.count)
        return located
    }

    private func visible(_ rect: CGRect, for pid: pid_t, windows: [[String: Any]]) -> Bool {
        let points = [CGPoint(x: rect.midX, y: rect.midY), CGPoint(x: rect.minX + 1, y: rect.midY), CGPoint(x: rect.maxX - 1, y: rect.midY)]
        return points.allSatisfy { point in
            for window in windows {
                guard let owner = (window[kCGWindowOwnerPID as String] as? NSNumber)?.int32Value,
                      owner != ownPID,
                      (window[kCGWindowLayer as String] as? NSNumber)?.intValue == 0,
                      let bounds = window[kCGWindowBounds as String] as? [String: Any],
                      let frame = CGRect(dictionaryRepresentation: bounds as CFDictionary), frame.contains(point) else { continue }
                return owner == pid
            }
            return false
        }
    }
}
