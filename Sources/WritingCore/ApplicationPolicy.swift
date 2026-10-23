import Foundation

public struct BlockedApplication: Codable, Identifiable, Equatable, Sendable {
    public let bundleID: String
    public let name: String
    public var id: String { bundleID }
    public init(bundleID: String, name: String) { self.bundleID = bundleID; self.name = name }
}

public enum ApplicationPolicy {
    public static func isBlocked(_ bundleID: String?, entries: [BlockedApplication]) -> Bool {
        guard let bundleID, !bundleID.isEmpty else { return true }
        return entries.contains { $0.bundleID == bundleID }
    }
    public static func adding(_ app: BlockedApplication, to entries: [BlockedApplication]) -> [BlockedApplication] {
        guard !app.bundleID.isEmpty, !entries.contains(where: { $0.bundleID == app.bundleID }) else { return entries }
        return (entries + [app]).sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
}
