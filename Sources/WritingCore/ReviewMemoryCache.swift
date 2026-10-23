import Foundation

/// Process-local, expiring LRU. Empty results are values, not cache misses.
/// Costs are caller-supplied text units; no serialization or disk persistence.
public struct ReviewMemoryCache<Key: Hashable, Value> {
    private struct Entry {
        let value: Value
        let expires: Date
        let cost: Int
        var access: UInt64
    }
    private var entries: [Key: Entry] = [:]
    private var clock: UInt64 = 0
    private let capacity: Int
    private let maximumCost: Int
    private let lifetime: TimeInterval
    public var count: Int { entries.count }
    public var cost: Int { entries.values.reduce(0) { $0 + $1.cost } }

    public init(capacity: Int, maximumCost: Int, lifetime: TimeInterval) {
        self.capacity = max(0, capacity)
        self.maximumCost = max(0, maximumCost)
        self.lifetime = max(0, lifetime)
    }

    public mutating func value(for key: Key, now: Date = Date()) -> Value? {
        prune(now: now)
        guard var entry = entries[key] else { return nil }
        clock &+= 1
        entry.access = clock
        entries[key] = entry
        return entry.value
    }

    public mutating func insert(_ value: Value, for key: Key, cost: Int, now: Date = Date()) {
        prune(now: now)
        entries.removeValue(forKey: key)
        guard capacity > 0, lifetime > 0, cost >= 0, cost <= maximumCost else { return }
        clock &+= 1
        entries[key] = Entry(value: value, expires: now.addingTimeInterval(lifetime), cost: cost, access: clock)
        while entries.count > capacity || self.cost > maximumCost {
            guard let oldest = entries.min(by: { $0.value.access < $1.value.access })?.key else { break }
            entries.removeValue(forKey: oldest)
        }
    }

    public mutating func prune(now: Date = Date()) {
        entries = entries.filter { $0.value.expires > now }
    }

    public mutating func removeAll(where predicate: (Key) -> Bool) {
        entries = entries.filter { !predicate($0.key) }
    }

    public mutating func removeAll() { entries.removeAll() }
}
