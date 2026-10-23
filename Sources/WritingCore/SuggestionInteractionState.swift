import Foundation

public enum AlternativeState: Equatable, Sendable {
    case idle, queued, generating, unavailable(String), failed(String)
    public var isBusy: Bool { self == .queued || self == .generating }
}

/// UI-independent state for a request and the card that owns the interaction.
public struct SuggestionInteractionState {
    public var states: [UUID: AlternativeState] = [:]
    public private(set) var openID: UUID?
    public private(set) var isPinned = false
    public init() {}
    public func state(for id: UUID) -> AlternativeState { states[id] ?? .idle }

    public mutating func open(_ id: UUID, pinned: Bool) {
        openID = id; isPinned = pinned
    }
    public mutating func pin() { isPinned = true }
    public mutating func hide() { openID = nil; isPinned = false }
    public mutating func clear() { states.removeAll(); hide() }

    public mutating func set(_ state: AlternativeState, for id: UUID) {
        states[id] = state
        if openID == id { isPinned = true }
    }

    /// Every exit clears busy feedback. A closed or different card must not be reopened by a late answer.
    @discardableResult public mutating func finish(for sourceID: UUID, presenting resultID: UUID? = nil) -> UUID? {
        if state(for: sourceID).isBusy { states[sourceID] = .idle }
        return openID == sourceID ? resultID : nil
    }

    public func allowsHover(on id: UUID) -> Bool {
        !isPinned || openID == nil || openID == id
    }
}
