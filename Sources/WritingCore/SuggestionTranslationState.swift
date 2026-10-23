import Foundation

public enum SuggestionTranslationState: Equatable, Sendable {
    case hidden
    case loading(target: String)
    case ready(text: String, target: String)
    case failed(message: String, target: String)

    public var isVisible: Bool { self != .hidden }
    public var target: String {
        switch self {
        case .hidden: return ""
        case .loading(let target), .ready(_, let target), .failed(_, let target): return target
        }
    }
}

public extension WritingSuggestion {
    /// Translate exactly the proposal displayed in the card, never the uncorrected context.
    var translationText: String? {
        replacement.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : replacement
    }
}
