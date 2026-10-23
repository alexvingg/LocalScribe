import AppKit

enum LocalScribeBrand {
    static var menuBarIcon: NSImage { LocalScribeArtwork.menuBarIcon() }

    static var icon: NSImage {
        // PDF preserves the vector artwork at every display scale.
        if let url = Bundle.main.url(forResource: "LocalScribe", withExtension: "pdf"),
           let image = NSImage(contentsOf: url) { return image }
        return LocalScribeArtwork.appIcon()
    }
}
