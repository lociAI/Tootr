import SwiftUI

struct ScratchDisc: View {
    let color: Color
    var isSpinning: Bool = false
    let action: () -> Void
    
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            Circle()
                .fill(RadialGradient(colors: [Color.black.opacity(0.8), .black], center: .center, startRadius: 0, endRadius: 100))
                .frame(width: 80, height: 80)
                .overlay(
                    Circle().stroke(color.opacity(0.3), lineWidth: 4)
                )
            
            // Vinyl grooves
            ForEach(0..<3) { i in
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    .frame(width: CGFloat(20 + i * 20), height: CGFloat(20 + i * 20))
            }
            
            // Center label
            Circle()
                .fill(color)
                .frame(width: 25, height: 25)
            
            // Stylus marker
            Rectangle()
                .fill(Color.white.opacity(0.6))
                .frame(width: 2, height: 10)
                .offset(y: -30)
                .rotationEffect(.degrees(rotation))
        }
        .rotationEffect(.degrees(rotation))
        .onTapGesture {
            action()
            withAnimation(.spring()) {
                rotation += 45
            }
        }
        .onAppear {
            if isSpinning {
                withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
        }
    }
}
