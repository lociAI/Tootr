import SwiftUI

struct PrankTimerView: View {
    @ObservedObject var soundManager: SoundManager
    @State private var timeRemaining = 0
    @State private var isTimerRunning = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("💨 Prank Timer 💨")
                .font(.largeTitle.bold())
                .foregroundColor(.green)
            
            if timeRemaining > 0 {
                Text("\(timeRemaining)")
                    .font(.system(size: 80, weight: .black, design: .rounded))
                    .transition(.scale)
            } else {
                Text("Select Delay")
                    .font(.headline)
            }
            
            HStack(spacing: 15) {
                TimerButton(seconds: 5, timeRemaining: $timeRemaining, isRunning: $isTimerRunning)
                TimerButton(seconds: 10, timeRemaining: $timeRemaining, isRunning: $isTimerRunning)
                TimerButton(seconds: 30, timeRemaining: $timeRemaining, isRunning: $isTimerRunning)
            }
            .disabled(isTimerRunning)
            
            if isTimerRunning {
                Button("Abort Mission!") {
                    isTimerRunning = false
                    timeRemaining = 0
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
            }
        }
        .padding()
        .background(Color.black.opacity(0.05))
        .cornerRadius(25)
        .onReceive(timer) { _ in
            guard isTimerRunning else { return }
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                isTimerRunning = false
                soundManager.playToot(baseFrequency: 40.0, richness: 8) // Big one!
            }
        }
    }
}

struct TimerButton: View {
    let seconds: Int
    @Binding var timeRemaining: Int
    @Binding var isRunning: Bool
    
    var body: some View {
        Button("\(seconds)s") {
            timeRemaining = seconds
            isRunning = true
        }
        .buttonStyle(.bordered)
        .controlSize(.large)
    }
}
