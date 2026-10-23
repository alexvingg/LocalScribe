import AppKit
import ApplicationServices
import NaturalLanguage
import WritingCore

/// Read-only integration diagnostics. Reports capabilities and lengths, never field text.
@MainActor
enum EditorCapabilityCheck {
    static func watch() {
        let arguments = CommandLine.arguments
        let target = arguments.firstIndex(of: "--bundle").flatMap {
            $0 + 1 < arguments.count ? arguments[$0 + 1] : nil
        }
        let deadline = Date().addingTimeInterval(60)
        var last = ""
        while Date() < deadline {
            var state = "editor-watch other-app"
            if let app = NSWorkspace.shared.frontmostApplication,
               target == nil || app.bundleIdentifier == target {
                let root = AXUIElementCreateApplication(app.processIdentifier)
                AXUIElementSetMessagingTimeout(root, 0.15)
                let field = AXAccess.focusedElement(root: root, pid: app.processIdentifier)
                let role = field.flatMap { AXAccess.string($0, kAXRoleAttribute) } ?? "none"
                let length = field.flatMap { AXAccess.value($0, kAXNumberOfCharactersAttribute) as? NSNumber }?.intValue ?? -1
                let selection = field.flatMap { AXAccess.range($0, kAXSelectedTextRangeAttribute) }
                state = "editor-watch bundle=\(app.bundleIdentifier ?? "") role=\(role) characters=\(length) selection=\(selection.map(NSStringFromRange) ?? "unavailable") manual=\(AXAccess.value(root, "AXManualAccessibility") as? Bool ?? false) enhanced=\(AXAccess.value(root, "AXEnhancedUserInterface") as? Bool ?? false)"
            }
            if state != last { FileHandle.standardOutput.write(Data((state + "\n").utf8)); last = state }
            RunLoop.current.run(until: Date().addingTimeInterval(0.3))
        }
    }

    static func run(bundleID: String?) throws {
        let app = bundleID.map { NSRunningApplication.runningApplications(withBundleIdentifier: $0).first }
            ?? NSWorkspace.shared.frontmostApplication
        guard let app else { throw ReviewFailure.changedDestination }
        let root = AXUIElementCreateApplication(app.processIdentifier)
        AXUIElementSetMessagingTimeout(root, 0.4)
        var activationResult: Int32? = nil
        var activationAttribute = "not-requested"
        if CommandLine.arguments.contains("--enable-accessibility") {
            let activation = AXAccess.enableAccessibility(on: root)
            activationResult = activation.status.rawValue
            activationAttribute = activation.attribute
        }
        print("editor-target bundle=\(app.bundleIdentifier ?? "unknown") frontmost=\(app.isActive) manualAccessibility=\(AXAccess.value(root, "AXManualAccessibility") as? Bool ?? false) enhancedAccessibility=\(AXAccess.value(root, "AXEnhancedUserInterface") as? Bool ?? false) activationAttribute=\(activationAttribute) activationResult=\(activationResult.map(String.init) ?? "not-requested")")
        var candidate = AXAccess.focusedElement(root: root, pid: app.processIdentifier)
        if CommandLine.arguments.contains("--text-area") {
            let windows = AXAccess.value(root, kAXWindowsAttribute) as? [AXUIElement] ?? []
            let window = windows.filter { (AXAccess.string($0, kAXTitleAttribute) ?? "").contains("WhatsApp") }.max {
                let a = AXAccess.frame($0) ?? .zero, b = AXAccess.frame($1) ?? .zero
                return a.width * a.height < b.width * b.height
            }
                ?? AXAccess.element(root, kAXFocusedWindowAttribute) ?? root
            candidate = nil
            var stack: [(AXUIElement, Int)] = [(window, 0)], visited = 0
            var counts: [String: Int] = [:]
            while let (node, depth) = stack.popLast(), visited < 1800 {
                visited += 1
                let role = AXAccess.string(node, kAXRoleAttribute)
                counts[role ?? "missing", default: 0] += 1
                if role == kAXTextAreaRole { candidate = node; break }
                if depth < 24, let children = AXAccess.value(node, kAXChildrenAttribute) as? [AXUIElement] {
                    stack += children.map { ($0, depth + 1) }
                }
            }
            print("editor-tree visited=\(visited) roles=\(counts)")
        }
        guard let field = candidate else {
            print("editor-capabilities no-focused-field \(AXAccess.lastFailure)"); return
        }
        AXUIElementSetMessagingTimeout(field, 0.4)
        let text = AXAccess.string(field, kAXValueAttribute) ?? ""
        let selection = AXAccess.range(field, kAXSelectedTextRangeAttribute)
        var names: CFArray?
        let parameterStatus = AXUIElementCopyParameterizedAttributeNames(field, &names)
        let first = (text as NSString).length > 0 ? (text as NSString).rangeOfComposedCharacterSequence(at: 0) : NSRange(location: 0, length: 0)
        let rect = AXAccess.bounds(field, range: first)
        let geometry = EditorTextGeometry(field: field, text: text)
        let fallback = geometry.bounds(for: first)
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(text)
        let candidates = recognizer.languageHypotheses(withMaximum: 3).map { ["code": $0.key.rawValue, "probability": $0.value] as [String: Any] }
        var total = 0, resolved = 0
        (text as NSString).enumerateSubstrings(in: NSRange(location: 0, length: text.utf16.count), options: [.byComposedCharacterSequences]) { string, range, _, stop in
            if total >= 80 { stop.pointee = true; return }
            guard let string, !string.allSatisfy({ $0.isWhitespace }) else { return }
            total += 1
            if geometry.bounds(for: range) != nil { resolved += 1 }
        }
        let record: [String: Any] = ["bundleID": app.bundleIdentifier ?? "", "frontmost": app.isActive,
            "trusted": AXIsProcessTrusted(), "role": AXAccess.string(field, kAXRoleAttribute) ?? "",
            "subrole": AXAccess.string(field, kAXSubroleAttribute) ?? "", "textUTF16": text.utf16.count,
            "selectedRange": selection.map { NSStringFromRange($0) } ?? "unavailable",
            "selectionWritable": AXAccess.selectionWritable(field), "valueWritable": AXAccess.settable(field, kAXValueAttribute),
            "strategy": AXAccess.editStrategy(field).rawValue, "webContent": AXAccess.isWebContent(field),
            "languageDetected": LanguageResolver.detect(text)?.code ?? "unknown", "languageCandidates": candidates,
            "selectedTextWritable": AXAccess.settable(field, kAXSelectedTextAttribute),
            "boundsAvailable": rect != nil, "textLeafBoundsAvailable": fallback != nil, "glyphsChecked": total, "glyphsResolved": resolved, "parameterStatus": parameterStatus.rawValue,
            "parameters": (names as? [String]) ?? [], "lastFailure": AXAccess.lastFailure]
        print(String(decoding: try JSONSerialization.data(withJSONObject: record, options: [.sortedKeys]), as: UTF8.self))
    }
}
