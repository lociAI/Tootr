import SwiftUI

struct ContentView: View {
    @StateObject private var soundManager = SoundManager()
    @StateObject private var beatManager = BeatManager()
    @StateObject private var gasSystem = GasParticleSystem()
    @State private var isRecording = false
    @State private var stinkLevel: Double = 0.0
    @State private var showMegaBlast = false
    
    let sounds = [
        ("💨", Color.purple, "fart1"),
        ("📣", Color.blue, "fart2"),
        ("💦", Color.green, "fart3"),
        ("⚡️", Color.orange, "fart4"),
        ("👻", Color.gray, "fart5"),
        ("💣", Color.red, "fart6"),
        ("🎺", Color.yellow, "fart7"),
        ("🐭", Color.pink, "fart8"),
        ("🌋", Color.brown, "fart9")
    ]
    
    var body: some View {
        ZStack {
            VStack(spacing: 8) {
                // Header & Stink-O-Meter
                HStack {
                    VStack(alignment: .leading) {
                        Text("Tootr Pro")
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundColor(.purple)
                        
                        // Stink-O-Meter
                        HStack {
                            Text("🤢")
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(Color.black.opacity(0.1))
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(LinearGradient(colors: [.green, .yellow], startPoint: .leading, endPoint: .trailing))
                                        .frame(width: geo.size.width * (stinkLevel / 100))
                                }
                            }
                            .frame(height: 10)
                            Text("🤮")
                        }
                        .frame(width: 150)
                    }
                    
                    Spacer()
                    
                    // Voice Warp Placeholder / Record
                    Button(action: { isRecording.toggle() }) {
                        VStack(spacing: 2) {
                            Image(systemName: isRecording ? "mic.fill" : "mic")
                                .foregroundColor(isRecording ? .red : .primary)
                            Text(isRecording ? "WARP" : "VOICE")
                                .font(.system(size: 8, weight: .bold))
                        }
                        .padding(8)
                        .background(Circle().fill(Color.black.opacity(0.05)))
                    }
                }
                .padding(.horizontal)
                
                // Dual Decks
                HStack(spacing: 15) {
                    ScratchDisc(color: .purple) {
                        handleToot(named: "fart10", at: CGPoint(x: 100, y: 150))
                    }
                    
                    VStack {
                        Text("Pitch")
                            .font(.system(size: 10, weight: .bold))
                        Slider(value: $soundManager.pitch, in: 0.5...2.0)
                            .tint(.purple)
                    }
                    .frame(width: 60)
                    
                    ScratchDisc(color: .blue) {
                        handleToot(named: "fart11", at: CGPoint(x: 250, y: 150))
                    }
                }
                .padding(8)
                .background(Color.black.opacity(0.05))
                .cornerRadius(15)
                
                // Beat Looper
                HStack {
                    Button(action: { 
                        beatManager.setup(soundManager: soundManager)
                        beatManager.toggleBeat() 
                    }) {
                        Text(beatManager.isPlaying ? "STOP" : "BEAT")
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 15)
                            .background(beatManager.isPlaying ? Color.red : Color.green)
                            .cornerRadius(10)
                    }
                    
                    Slider(value: $beatManager.bpm, in: 60...180)
                        .tint(.green)
                }
                .padding(.horizontal)
                
                // Grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 5), count: 3), spacing: 5) {
                    ForEach(sounds, id: \.0) { sound in
                        SoundButton(title: sound.0, color: sound.1) {
                            handleToot(named: sound.2, at: .zero) // Position determined by button in real app, here we randomize or emit center
                        }
                        .frame(height: 65)
                    }
                }
                .padding(.horizontal, 10)
                
                // Big Red Button (Shake/Quake simulation)
                Button(action: triggerMegaBlast) {
                    Text("🔴 DON'T PRESS")
                        .font(.system(size: 14, weight: .black))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(stinkLevel > 80 ? Color.red : Color.gray)
                        .cornerRadius(15)
                }
                .disabled(stinkLevel < 80)
                .padding(.horizontal)
                
                Spacer(minLength: 0)
            }
            .padding(.top, 5)
            
            // Visual Effects Layer
            GasCloudView(system: gasSystem)
            
            if showMegaBlast {
                VStack {
                    Text("🤢 MEGA BLAST! 🤢")
                        .font(.system(size: 40, weight: .black, design: .rounded))
                        .foregroundColor(.green)
                        .shadow(radius: 10)
                    Text("☁️☁️☁️")
                        .font(.system(size: 100))
                }
                .transition(.scale.combined(with: .opacity))
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation { showMegaBlast = false }
                    }
                }
            }
        }
        .background(Color(.windowBackgroundColor))
    }
    
    private func handleToot(named: String, at point: CGPoint) {
        soundManager.playSound(named: named)
        stinkLevel = min(100, stinkLevel + 5)
        
        // Emit gas particles at the tap location or random location if point is zero
        let emitPoint = point == .zero ? CGPoint(x: CGFloat.random(in: 100...300), y: CGFloat.random(in: 300...500)) : point
        gasSystem.emit(at: emitPoint)
    }
    
    private func triggerMegaBlast() {
        soundManager.playSound(named: "fart12")
        soundManager.playSound(named: "fart13")
        withAnimation { showMegaBlast = true }
        stinkLevel = 0
        // Fill screen with gas
        for _ in 0..<10 {
            gasSystem.emit(at: CGPoint(x: CGFloat.random(in: 0...400), y: CGFloat.random(in: 0...600)))
        }
    }
}

#if !os(macOS)
extension Color {
    static let windowBackgroundColor = Color(UIColor.systemBackground)
}
#endif
