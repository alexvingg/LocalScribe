import AppKit

/// Resolution-independent source for the app, settings, menu bar and installer.
/// All contours are native paths; no generated bitmap is resized to repair edges.
enum LocalScribeArtwork {
    static func appIcon() -> NSImage {
        NSImage(size: NSSize(width: 1024, height: 1024), flipped: true) { _ in
            guard let context = NSGraphicsContext.current?.cgContext else { return false }
            context.setShouldAntialias(true)
            let frame = NSRect(x: 64, y: 64, width: 896, height: 896)
            let tile = NSBezierPath(roundedRect: frame, xRadius: 214, yRadius: 214)
            let gradient = NSGradient(colorsAndLocations:
                (NSColor(srgbRed: 0.26, green: 0.94, blue: 0.61, alpha: 1), 0),
                (NSColor(srgbRed: 0.00, green: 0.66, blue: 0.45, alpha: 1), 0.46),
                (NSColor(srgbRed: 0.00, green: 0.25, blue: 0.24, alpha: 1), 1))!
            gradient.draw(in: tile, angle: 45)
            context.saveGState()
            tile.addClip()
            let light = NSBezierPath()
            light.move(to: NSPoint(x: 50, y: 90))
            light.line(to: NSPoint(x: 970, y: 90))
            light.curve(to: NSPoint(x: 50, y: 480),
                        controlPoint1: NSPoint(x: 660, y: 270), controlPoint2: NSPoint(x: 290, y: 455))
            light.close()
            NSColor.white.withAlphaComponent(0.10).setFill(); light.fill()
            let shade = NSBezierPath()
            shade.move(to: NSPoint(x: 60, y: 955))
            shade.curve(to: NSPoint(x: 966, y: 615),
                        controlPoint1: NSPoint(x: 490, y: 900), controlPoint2: NSPoint(x: 805, y: 800))
            shade.line(to: NSPoint(x: 966, y: 966)); shade.close()
            NSColor.black.withAlphaComponent(0.07).setFill(); shade.fill()
            context.restoreGState()
            drawMark(transform: AffineTransform(scale: 1024 / 1254),
                     color: .white, lineWidth: 62, mintAccent: true)
            return true
        }
    }

    static func menuBarIcon() -> NSImage {
        let image = NSImage(size: NSSize(width: 20, height: 20), flipped: true) { _ in
            drawMark(transform: AffineTransform(m11: 0.019, m12: 0, m21: 0, m22: 0.019,
                                                tX: -2.66, tY: -1.4),
                     color: .black, lineWidth: 1.38)
            return true
        }
        image.isTemplate = true
        image.accessibilityDescription = "LocalScribe"
        return image
    }

    private static func drawMark(transform: AffineTransform, color: NSColor,
                                 lineWidth: CGFloat, mintAccent: Bool = false) {
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        context.saveGState()
        context.setShouldAntialias(true)
        context.beginTransparencyLayer(auxiliaryInfo: nil)
        color.setFill(); color.setStroke()
        let ribbon = NSBezierPath()
        ribbon.move(to: NSPoint(x: 660, y: 399))
        ribbon.curve(to: NSPoint(x: 440, y: 828),
                     controlPoint1: NSPoint(x: 623, y: 510), controlPoint2: NSPoint(x: 542, y: 716))
        ribbon.curve(to: NSPoint(x: 214, y: 812),
                     controlPoint1: NSPoint(x: 345, y: 951), controlPoint2: NSPoint(x: 202, y: 899))
        ribbon.curve(to: NSPoint(x: 417, y: 708),
                     controlPoint1: NSPoint(x: 219, y: 722), controlPoint2: NSPoint(x: 317, y: 687))
        ribbon.curve(to: NSPoint(x: 758, y: 869),
                     controlPoint1: NSPoint(x: 551, y: 719), controlPoint2: NSPoint(x: 673, y: 811))
        ribbon.curve(to: NSPoint(x: 826, y: 849),
                     controlPoint1: NSPoint(x: 783, y: 892), controlPoint2: NSPoint(x: 798, y: 885))
        ribbon.curve(to: NSPoint(x: 1069, y: 580),
                     controlPoint1: NSPoint(x: 914, y: 738), controlPoint2: NSPoint(x: 1019, y: 620))
        ribbon.transform(using: transform)
        ribbon.lineWidth = lineWidth
        ribbon.lineCapStyle = .round
        ribbon.lineJoinStyle = .round
        ribbon.stroke()

        let nib = NSBezierPath()
        nib.move(to: NSPoint(x: 758, y: 234))
        nib.line(to: NSPoint(x: 776, y: 350))
        nib.curve(to: NSPoint(x: 741, y: 432),
                  controlPoint1: NSPoint(x: 779, y: 401), controlPoint2: NSPoint(x: 763, y: 416))
        nib.line(to: NSPoint(x: 650, y: 465))
        nib.line(to: NSPoint(x: 622, y: 415))
        nib.line(to: NSPoint(x: 628, y: 344))
        nib.curve(to: NSPoint(x: 659, y: 288),
                  controlPoint1: NSPoint(x: 628, y: 310), controlPoint2: NSPoint(x: 643, y: 299))
        nib.close()
        nib.transform(using: transform)
        nib.fill()

        let hole = NSBezierPath(ovalIn: NSRect(x: 689, y: 326, width: 36, height: 36))
        hole.transform(using: transform)
        let slit = NSBezierPath()
        slit.move(to: NSPoint(x: 753, y: 247))
        slit.line(to: NSPoint(x: 703, y: 340))
        slit.line(to: NSPoint(x: 674, y: 412))
        slit.line(to: NSPoint(x: 717, y: 351))
        slit.close()
        slit.transform(using: transform)
        context.saveGState()
        context.setBlendMode(.destinationOut)
        hole.fill(); slit.fill()
        context.restoreGState()

        if mintAccent {
            NSColor(srgbRed: 0.59, green: 1, blue: 0.81, alpha: 1).setStroke()
            let tip = NSBezierPath()
            tip.move(to: NSPoint(x: 1040, y: 613))
            tip.curve(to: NSPoint(x: 1069, y: 580),
                      controlPoint1: NSPoint(x: 1051, y: 600), controlPoint2: NSPoint(x: 1062, y: 587))
            tip.transform(using: transform)
            tip.lineWidth = lineWidth
            tip.lineCapStyle = .round
            tip.stroke()
        }
        context.endTransparencyLayer()
        context.restoreGState()
    }
}
