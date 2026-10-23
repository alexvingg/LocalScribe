import AppKit
import ImageIO
import UniformTypeIdentifiers

@main
struct RenderBrandIcon {
    static func png(_ image: NSImage, size: Int, at url: URL) throws {
        // Render curves above their target resolution, then filter once. Small
        // Finder representations get their own antialiased raster, not a 1x crop.
        let scale = size <= 256 ? 4 : 2
        let pixels = size * scale
        func bitmap(_ width: Int) -> CGContext {
            CGContext(data: nil, width: width, height: width, bitsPerComponent: 8, bytesPerRow: 0,
                space: CGColorSpace(name: CGColorSpace.sRGB)!,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        }
        let large = bitmap(pixels)
        large.setShouldAntialias(true)
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(cgContext: large, flipped: false)
        image.draw(in: NSRect(x: 0, y: 0, width: pixels, height: pixels), from: .zero,
                   operation: .sourceOver, fraction: 1, respectFlipped: true, hints: nil)
        NSGraphicsContext.restoreGraphicsState()
        let output = bitmap(size)
        output.interpolationQuality = .high
        output.draw(large.makeImage()!, in: CGRect(x: 0, y: 0, width: size, height: size))
        guard let destination = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) else {
            throw CocoaError(.fileWriteUnknown)
        }
        CGImageDestinationAddImage(destination, output.makeImage()!, nil)
        guard CGImageDestinationFinalize(destination) else { throw CocoaError(.fileWriteUnknown) }
    }

    static func main() throws {
        let args = CommandLine.arguments
        if args.count == 4, args[1] == "set-icon" {
            guard let image = NSImage(contentsOfFile: args[2]),
                  NSWorkspace.shared.setIcon(image, forFile: URL(fileURLWithPath: args[3]).standardizedFileURL.path, options: []) else {
                throw CocoaError(.fileWriteUnknown)
            }
            print("custom-file-icon=installed")
            return
        }
        if args.count == 4, args[1] == "inspect-icon" {
            let path = URL(fileURLWithPath: args[2]).standardizedFileURL.path
            try png(NSWorkspace.shared.icon(forFile: path), size: 128, at: URL(fileURLWithPath: args[3]))
            return
        }
        guard args.count == 2 else { throw CocoaError(.fileReadInvalidFileName) }
        let assets = URL(fileURLWithPath: args[1], isDirectory: true)
        let iconset = assets.appendingPathComponent("LocalScribe.iconset", isDirectory: true)
        try FileManager.default.createDirectory(at: iconset, withIntermediateDirectories: true)
        let image = LocalScribeArtwork.appIcon()
        for size in [16, 32, 128, 256, 512] {
            try png(image, size: size, at: iconset.appendingPathComponent("icon_\(size)x\(size).png"))
            try png(image, size: size * 2, at: iconset.appendingPathComponent("icon_\(size)x\(size)@2x.png"))
        }
        try png(image, size: 1024, at: assets.appendingPathComponent("LocalScribe.png"))
        let pdfURL = assets.appendingPathComponent("LocalScribe.pdf")
        var box = CGRect(x: 0, y: 0, width: 1024, height: 1024)
        guard let consumer = CGDataConsumer(url: pdfURL as CFURL),
              let context = CGContext(consumer: consumer, mediaBox: &box, nil) else { throw CocoaError(.fileWriteUnknown) }
        context.beginPDFPage(nil)
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(cgContext: context, flipped: false)
        image.draw(in: box, from: .zero, operation: .sourceOver, fraction: 1, respectFlipped: true, hints: nil)
        NSGraphicsContext.restoreGraphicsState()
        context.endPDFPage(); context.closePDF()
        print("vector-icon=rendered sizes=16,32,64,128,256,512,1024 pdf=vector")
    }
}
