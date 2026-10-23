import Foundation

/// Rejects late results after timeout, cancellation or replacement by a newer request.
public struct AlternativeRequestLifetime {
    private var current: UUID?
    public private(set) var hasTimedOut = false
    public init() {}
    public mutating func begin() -> UUID {
        let id = UUID(); current = id; hasTimedOut = false; return id
    }
    public func accepts(_ id: UUID) -> Bool { current == id }
    @discardableResult public mutating func timeout(_ id: UUID) -> Bool {
        guard current == id else { return false }
        current = nil; hasTimedOut = true; return true
    }
    public mutating func cancel() { current = nil }
    public mutating func finish() { current = nil; hasTimedOut = false }
}
