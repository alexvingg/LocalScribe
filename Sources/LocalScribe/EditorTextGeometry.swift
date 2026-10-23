import AppKit
import ApplicationServices
import WritingCore

/// Native text fields expose glyph bounds on the field. Chromium rich editors expose them on text leaves.
@MainActor
final class EditorTextGeometry {
    private let field: AXUIElement
    private let text: String
    private var leaves: [(AXUIElement, NSRange)]?
    private(set) var usedTextLeaves = false
    init(field: AXUIElement, text: String) { self.field = field; self.text = text }

    func bounds(for range: NSRange) -> CGRect? {
        if let rect = AXAccess.bounds(field, range: range) { return rect }
        if leaves == nil { leaves = loadLeaves() }
        var result = CGRect.null
        for (element, span) in leaves ?? [] {
            let part = NSIntersectionRange(span, range)
            guard part.length > 0 else { continue }
            let local = NSRange(location: part.location - span.location, length: part.length)
            guard let rect = AXAccess.bounds(element, range: local) else { return nil }
            result = result.union(rect)
        }
        guard !result.isNull, !result.isEmpty else { return nil }
        usedTextLeaves = true
        return result
    }

    private func loadLeaves() -> [(AXUIElement, NSRange)] {
        var stack: [(AXUIElement, Int)] = [(field, 0)]
        var elements: [AXUIElement] = [], values: [String] = [], visited = 0
        while let (node, depth) = stack.popLast() {
            visited += 1
            guard visited <= 256, depth <= 12 else { return [] }
            AXUIElementSetMessagingTimeout(node, 0.15)
            if AXAccess.string(node, kAXRoleAttribute) == kAXStaticTextRole {
                guard let value = AXAccess.string(node, kAXValueAttribute), !value.isEmpty else { continue }
                elements.append(node); values.append(value)
            } else if let children = AXAccess.value(node, kAXChildrenAttribute) as? [AXUIElement] {
                stack += children.reversed().map { ($0, depth + 1) }
            }
        }
        guard !values.isEmpty, let spans = EditorTextSegments.ranges(for: values, in: text) else { return [] }
        return Array(zip(elements, spans))
    }
}
