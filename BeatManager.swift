import Foundation
import AVFoundation

/// Manages rhythmic loops to create "fart songs".
class BeatManager: ObservableObject {
    private var timer: Timer?
    private var soundManager: SoundManager?
    
    @Published var isPlaying = false
    @Published var bpm: Double = 120.0
    @Published var currentStep = 0
    
    func setup(soundManager: SoundManager) {
        self.soundManager = soundManager
    }
    
    func toggleBeat() {
        if isPlaying {
            stop()
        } else {
            start()
        }
    }
    
    private func start() {
        isPlaying = true
        currentStep = 0
        let interval = 60.0 / bpm / 2.0 // 8th notes
        
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.playStep()
            self.currentStep = (self.currentStep + 1) % 16
        }
    }
    
    private func stop() {
        isPlaying = false
        timer?.invalidate()
        timer = nil
    }
    
    private func playStep() {
        // Simple 4/4 beat logic
        if currentStep % 4 == 0 {
            // Kick (Low Toot)
            soundManager?.playToot(baseFrequency: 40.0, richness: 5)
        } else if currentStep % 4 == 2 {
            // Snare (Short high toot)
            soundManager?.playToot(baseFrequency: 150.0, richness: 2)
        }
        
        // Random "hi-hat" squeaks
        if Int.random(in: 0...3) == 0 {
            soundManager?.playToot(baseFrequency: 400.0, richness: 1)
        }
    }
}
