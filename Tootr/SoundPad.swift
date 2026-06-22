import SwiftUI

struct SoundPad: View {
    let name: String
    let color: Color
    let isLooping: Bool
    let isLocked: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    private let impact = UIImpactFeedbackGenerator(style: .rigid)
    
    var body: some View {
        Button(action: {
            impact.impactOccurred()
            action()
            withAnimation(.spring(response: 0.15, dampingFraction: 0.4)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
            }
        }) {
            ZStack {
                // Outer Glow (Breathing if looping)
                RoundedRectangle(cornerRadius: 16)
                    .fill(color.opacity(isLooping ? 0.6 : 0.2))
                    .blur(radius: isLooping ? 12 : 0)
                
                // Main Button Body (Tactile Silicone Look)
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [color.opacity(0.9), color.opacity(0.7)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        // Inner Highlight
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.4), lineWidth: 4)
                            .blur(radius: 2)
                            .offset(x: 2, y: 2)
                            .mask(RoundedRectangle(cornerRadius: 16).inset(by: 2))
                    )
                    .overlay(
                        // Bevel Shadow
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.black.opacity(0.4), lineWidth: 2)
                            .blur(radius: 1)
                            .offset(x: -1, y: -1)
                            .mask(RoundedRectangle(cornerRadius: 16).inset(by: 1))
                    )
                
                // Label & Icon
                VStack(spacing: 4) {
                    if isLocked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 24, weight: .black))
                            .foregroundColor(.white.opacity(0.5))
                            .shadow(color: .black.opacity(0.3), radius: 2)
                    } else {
                        Image(systemName: iconForName(name))
                            .font(.system(size: 24, weight: .black))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 2)
                    }
                    
                    Text(name.uppercased())
                        .font(.system(size: 9, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .minimumScaleFactor(0.5)
                }
            }
            .opacity(isLocked ? 0.4 : 1.0)
            .scaleEffect(isPressed ? 0.85 : 1.0)
            .animation(.interactiveSpring(), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func iconForName(_ name: String) -> String {
        let n = name.lowercased()
        if n.contains("ripper") || n.contains("wet") { return "drop.fill" }
        if n.contains("gusher") || n.contains("dry") { return "cloud.heavyrain.fill" }
        if n.contains("squeak") { return "ant.fill" }
        if n.contains("power") { return "bolt.fill" }
        if n.contains("snap") { return "zap" }
        if n.contains("haul") || n.contains("long") { return "wind" }
        if n.contains("horn") || n.contains("trumpet") { return "trumpet.fill" }
        if n.contains("bean") { return "mouth.fill" }
        return "music.note"
    }
}
