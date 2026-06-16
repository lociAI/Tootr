import SwiftUI

struct SoundButton: View {
    let title: String
    let color: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            action()
            withAnimation(.spring(response: 0.2, dampingFraction: 0.4, blendDuration: 0)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring()) {
                    isPressed = false
                }
            }
        }) {
            VStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
            }
            .frame(maxWidth: .infinity, minHeight: 100)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(color)
                    .shadow(color: color.opacity(0.4), radius: isPressed ? 2 : 10, x: 0, y: isPressed ? 2 : 5)
            )
            .scaleEffect(isPressed ? 0.9 : 1.0)
            .rotationEffect(.degrees(isPressed ? Double.random(in: -5...5) : 0))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SoundButton_Previews: PreviewProvider {
    static var previews: some View {
        SoundButton(title: "The Squeaker", color: .purple) {}
            .padding()
    }
}
