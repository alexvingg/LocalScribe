import Foundation

public enum EditAcknowledgement: Equatable {
    case waiting, confirmed, destinationChanged, unexpectedText
    public static func observe(original: String, expected: String, actual: String?, sameDestination: Bool) -> Self {
        guard sameDestination else { return .destinationChanged }
        guard let actual else { return .waiting }
        if actual == expected { return .confirmed }
        return actual == original ? .waiting : .unexpectedText
    }
}

public enum ApplicationFeedback: Equatable {
    case idle, applying, failed(String, retryAllowed: Bool)
    public var isBusy: Bool { self == .applying }
    public var canApply: Bool {
        switch self { case .applying: return false; case .failed(_, let retry): return retry; case .idle: return true }
    }
    public var message: String? { if case .failed(let message, _) = self { return message }; return nil }
}
