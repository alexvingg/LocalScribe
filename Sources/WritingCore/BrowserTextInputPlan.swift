import Foundation

/// Bounded text events; never turns model output into Return, Tab or shortcuts.
public enum BrowserTextInputPlan {
    public static func chunks(for text: String) -> [String]? {
        guard !text.unicodeScalars.contains(where: {
            $0.value < 32 || (127...159).contains($0.value) || $0.value == 0x2028 || $0.value == 0x2029
        }) else { return nil }
        var result: [String] = [], chunk = ""
        for character in text {
            let part = String(character)
            guard part.utf16.count <= 16 else { return nil }
            if chunk.utf16.count + part.utf16.count > 16 { result.append(chunk); chunk = "" }
            chunk += part
        }
        if !chunk.isEmpty { result.append(chunk) }
        return result
    }
}
