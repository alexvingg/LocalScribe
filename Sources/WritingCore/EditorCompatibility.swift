import Foundation

public enum EditorEditStrategy: String, Equatable, Sendable {
    case accessibility, nativeInput, readOnly
}

public enum EditorCompatibility {
    /// Choose from field capabilities, never a list of permitted application IDs.
    public static func editStrategy(selectionWritable: Bool, selectedTextWritable: Bool,
                                    valueWritable: Bool, webContent: Bool, secure: Bool = false) -> EditorEditStrategy {
        guard !secure, selectionWritable, selectedTextWritable || valueWritable else { return .readOnly }
        if webContent || !selectedTextWritable { return .nativeInput }
        return .accessibility
    }
}
