import SwiftUI

struct ScratchPlatter: View {
    @State private var rotation: Double = 0
    @State private var lastRotation: Double = 0
    @State private var velocity: Double = 0
    private let impact = UIImpactFeedbackGenerator(style: .light)
    let onScratch: (Double) -> Void
    
    let timer = Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geo in
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let radius = min(geo.size.width, geo.size.height) / 2
            
            ZStack {
                // High-End Vinyl Disc
                Circle()
                    .fill(
                        AngularGradient(
                            gradient: Gradient(colors: [
                                Color(white: 0.05),
                                Color(white: 0.15),
                                Color(white: 0.05),
                                Color(white: 0.2),
                                Color(white: 0.05)
                            ]),
                            center: .center,
                            angle: .degrees(rotation)
                        )
                    )
                
                // Concentric Grooves (Procedural Texture)
                ForEach(0..<10) { i in
                    Circle()
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                        .scaleEffect(0.3 + (CGFloat(i) * 0.06))
                }
                
                // Reflection Highlight
                Circle()
                    .stroke(
                        LinearGradient(colors: [.white.opacity(0.15), .clear], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: radius * 0.1
                    )
                    .blur(radius: 2)
                
                // Center Label (Premium Hub)
                Circle()
                    .fill(LinearGradient(colors: [Color(red: 0.0, green: 0.8, blue: 1.0), Color(red: 0.0, green: 0.4, blue: 0.8)], startPoint: .top, endPoint: .bottom))
                    .frame(width: radius * 0.35, height: radius * 0.35)
                    .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 2))
                    .shadow(color: Color(red: 0.0, green: 0.8, blue: 1.0).opacity(0.4), radius: 10)
                
                // Stylized Marker
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white)
                    .frame(width: radius * 0.08, height: radius * 0.3)
                    .offset(y: -radius * 0.75)
                    .shadow(radius: 2)
                    .rotationEffect(.degrees(rotation))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onReceive(timer) { _ in
                if abs(velocity) > 0.1 {
                    rotation += velocity
                    velocity *= 0.96
                    onScratch(velocity)
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let vector = CGVector(dx: value.location.x - center.x, dy: value.location.y - center.y)
                        let angle = atan2(vector.dy, vector.dx) * 180 / .pi
                        let delta = angle - lastRotation
                        
                        if abs(delta) < 180 {
                            rotation += delta
                            velocity = delta
                            onScratch(delta)
                            impact.impactOccurred(intensity: 0.3)
                        }
                        lastRotation = angle
                    }
                    .onEnded { _ in
                        lastRotation = 0
                    }
            )
        }
    }
}
