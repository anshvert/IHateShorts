import AppKit

/**
 * @param size
 * @returns NSImage
 */
func renderIcon(size: CGFloat) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()

    let rect = NSRect(x: 0, y: 0, width: size, height: size)
    let cornerRadius = size * 0.22
    let bgPath = NSBezierPath(roundedRect: rect, xRadius: cornerRadius, yRadius: cornerRadius)
    
    let redGradient = NSGradient(starting: NSColor(red: 1.0, green: 0.2, blue: 0.3, alpha: 1.0),
                                 ending: NSColor(red: 0.75, green: 0.08, blue: 0.15, alpha: 1.0))
    redGradient?.draw(in: bgPath, angle: -45)

    let inset = size * 0.2
    let iconRect = rect.insetBy(dx: inset, dy: inset)

    let circlePath = NSBezierPath(ovalIn: iconRect)
    circlePath.lineWidth = max(1.5, size * 0.08)
    NSColor.white.setStroke()
    circlePath.stroke()

    let slashPath = NSBezierPath()
    let offset = iconRect.width * 0.146
    slashPath.move(to: NSPoint(x: iconRect.minX + offset, y: iconRect.minY + offset))
    slashPath.line(to: NSPoint(x: iconRect.maxX - offset, y: iconRect.maxY - offset))
    slashPath.lineWidth = circlePath.lineWidth
    slashPath.lineCapStyle = .round
    NSColor.white.setStroke()
    slashPath.stroke()

    let playPath = NSBezierPath()
    let cx = iconRect.midX
    let cy = iconRect.midY
    let pw = size * 0.14
    let ph = size * 0.18
    playPath.move(to: NSPoint(x: cx - pw * 0.6, y: cy - ph * 0.5))
    playPath.line(to: NSPoint(x: cx + pw * 0.8, y: cy))
    playPath.line(to: NSPoint(x: cx - pw * 0.6, y: cy + ph * 0.5))
    playPath.close()
    NSColor(white: 1.0, alpha: 0.75).setFill()
    playPath.fill()

    image.unlockFocus()
    return image
}

/**
 * @param image
 * @param path
 */
func savePNG(image: NSImage, path: String) {
    guard let tiff = image.tiffRepresentation,
          let rep = NSBitmapImageRep(data: tiff),
          let png = rep.representation(using: .png, properties: [:]) else {
        return
    }
    try? png.write(to: URL(fileURLWithPath: path))
}

let sizes: [CGFloat] = [16, 32, 48, 128, 512]
let baseDir = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "extension/icons"

for s in sizes {
    let img = renderIcon(size: s)
    let filename = "\(baseDir)/icon-\(Int(s)).png"
    savePNG(image: img, path: filename)
    print("Generated \(filename)")
}
