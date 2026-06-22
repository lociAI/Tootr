import AppKit

let size = CGSize(width: 1024, height: 1024)
let bounds = CGRect(origin: .zero, size: size)

let image = NSImage(size: size)
image.lockFocus()

// 1. Modern Apple Gradient Background (Purple to Deep Blue)
let gradient = NSGradient(starting: NSColor(calibratedRed: 0.36, green: 0.12, blue: 0.8, alpha: 1.0),
                          ending: NSColor(calibratedRed: 0.08, green: 0.05, blue: 0.2, alpha: 1.0))
gradient?.draw(in: bounds, angle: -45)

let center = CGPoint(x: 512, y: 512)

// 2. Minimalist Turntable (The "DJ" heart)
let platterBounds = CGRect(x: 212, y: 212, width: 600, height: 600)
let platterPath = NSBezierPath(ovalIn: platterBounds)
NSColor(calibratedWhite: 0.0, alpha: 0.3).setFill()
platterPath.fill()

// Neon Green Stylized Record Edge
let recordEdge = NSBezierPath(ovalIn: platterBounds.insetBy(dx: 10, dy: 10))
NSColor(calibratedRed: 0.4, green: 1.0, blue: 0.2, alpha: 1.0).setStroke()
recordEdge.lineWidth = 12
recordEdge.stroke()

// 3. The "Subtle" Fart: The "Bass Note"
// A musical note where the bottom circle is a soft, semi-transparent green cloud
let noteColor = NSColor.white
let cloudColor = NSColor(calibratedRed: 0.5, green: 1.0, blue: 0.3, alpha: 0.8)

// Draw the "Cloud" part of the note
let cloudPath = NSBezierPath()
let cloudCenter = CGPoint(x: 440, y: 400)
cloudPath.move(to: CGPoint(x: cloudCenter.x - 40, y: cloudCenter.y))
cloudPath.appendArc(withCenter: CGPoint(x: cloudCenter.x - 20, y: cloudCenter.y + 20), radius: 30, startAngle: 90, endAngle: 270, clockwise: true)
cloudPath.appendArc(withCenter: CGPoint(x: cloudCenter.x + 20, y: cloudCenter.y + 20), radius: 40, startAngle: 120, endAngle: 360, clockwise: true)
cloudPath.appendArc(withCenter: CGPoint(x: cloudCenter.x, y: cloudCenter.y - 10), radius: 30, startAngle: 0, endAngle: 180, clockwise: true)
cloudColor.setFill()
cloudPath.fill()

// Draw the Note Stem
let stemPath = NSBezierPath()
stemPath.move(to: CGPoint(x: 470, y: 420))
stemPath.line(to: CGPoint(x: 470, y: 650))
stemPath.line(to: CGPoint(x: 580, y: 600))
stemPath.lineWidth = 25
stemPath.lineCapStyle = .round
noteColor.setStroke()
stemPath.stroke()

// 4. Stylized "T" in the center (Brand)
let text = "T"
let font = NSFont.systemFont(ofSize: 120, weight: .black)
let attrs: [NSAttributedString.Key: Any] = [
    .font: font,
    .foregroundColor: NSColor.white
]
let stringSize = text.size(withAttributes: attrs)
let textRect = CGRect(x: center.x - stringSize.width / 2, y: center.y - stringSize.height / 2, width: stringSize.width, height: stringSize.height)
text.draw(in: textRect, withAttributes: attrs)

image.unlockFocus()

// Save the image
let path = "Developer/Tootr/Tootr/Assets.xcassets/AppIcon.appiconset/Icon-1024.png"
if let tiff = image.tiffRepresentation, let bitmap = NSBitmapImageRep(data: tiff), let png = bitmap.representation(using: .png, properties: [:]) {
    try? png.write(to: URL(fileURLWithPath: path))
    print("Successfully generated New DJ Tootr App Icon!")
}
