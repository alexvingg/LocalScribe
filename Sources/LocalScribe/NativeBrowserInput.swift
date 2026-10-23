import CoreGraphics
import AppKit

/// Product adapter invoked only after an explicit Apply and verified AX selection.
enum NativeBrowserInput {
    static func pasteEvents() -> (CGEvent, CGEvent)? {
        guard CGPreflightPostEventAccess(), let source = CGEventSource(stateID: .privateState),
              let down = CGEvent(keyboardEventSource: source, virtualKey: 9, keyDown: true),
              let up = CGEvent(keyboardEventSource: source, virtualKey: 9, keyDown: false) else { return nil }
        down.flags = .maskCommand; up.flags = .maskCommand
        return (down, up)
    }
    static func events(text: String, deleting: Bool = false) -> (CGEvent, CGEvent)? {
        guard CGPreflightPostEventAccess(),
              let source = CGEventSource(stateID: .privateState),
              let down = CGEvent(keyboardEventSource: source, virtualKey: deleting ? 51 : 0, keyDown: true),
              let up = CGEvent(keyboardEventSource: source, virtualKey: deleting ? 51 : 0, keyDown: false) else { return nil }
        down.flags = []; up.flags = []
        if !deleting {
            let units = Array(text.utf16)
            units.withUnsafeBufferPointer {
                down.keyboardSetUnicodeString(stringLength: $0.count, unicodeString: $0.baseAddress)
                up.keyboardSetUnicodeString(stringLength: $0.count, unicodeString: $0.baseAddress)
            }
        }
        return (down, up)
    }
}

/// One paste gives rich editors one native undo operation for a whole phrase.
/// Restore only if nobody has copied anything since our temporary value.
@MainActor
final class BrowserPasteTransaction {
    private let pasteboard = NSPasteboard.general
    private let saved: [NSPasteboardItem]
    private let originalChange: Int
    private let text: String
    private var stagedChange: Int?

    init?(text: String) {
        self.text = text
        originalChange = pasteboard.changeCount
        var items: [NSPasteboardItem] = []
        for item in pasteboard.pasteboardItems ?? [] {
            let copy = NSPasteboardItem()
            for type in item.types {
                guard let data = item.data(forType: type), copy.setData(data, forType: type) else { return nil }
            }
            items.append(copy)
        }
        guard pasteboard.changeCount == originalChange else { return nil }
        saved = items
    }

    func stage() -> Bool {
        guard pasteboard.changeCount == originalChange else { return false }
        pasteboard.clearContents()
        stagedChange = pasteboard.changeCount
        let result = pasteboard.setString(text, forType: .string)
        stagedChange = pasteboard.changeCount
        return result
    }

    func restore() {
        guard let stagedChange, pasteboard.changeCount == stagedChange else { return }
        pasteboard.clearContents()
        if !saved.isEmpty { _ = pasteboard.writeObjects(saved) }
        self.stagedChange = nil
    }
}
