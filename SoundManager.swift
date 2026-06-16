import Foundation
import AVFoundation

/// The upgraded brain of Tootr Pro. Handles file-based playback and real-time effects.
class SoundManager: ObservableObject {
    private var engine = AVAudioEngine()
    private var pitchNode = AVAudioUnitTimePitch()
    private var playerNodes: [AVAudioPlayerNode] = []
    
    @Published var pitch: Float = 1.0 {
        didSet {
            pitchNode.pitch = Float(log2(Double(pitch)) * 1200.0)
        }
    }
    
    init() {
        setupEngine()
    }
    
    private func setupEngine() {
        engine.attach(pitchNode)
        let format = engine.mainMixerNode.outputFormat(forBus: 0)
        engine.connect(pitchNode, to: engine.mainMixerNode, format: format)
        
        do {
            try engine.start()
        } catch {
            print("Error starting audio engine: \(error.localizedDescription)")
        }
    }
    
    /// Plays a sound file from the local Sounds directory
    func playSound(named name: String) {
        // Find the file in the Sounds folder
        let fileName = name.replacingOccurrences(of: " ", with: "").lowercased()
        
        // Try mp3 first, then wav
        var fileURL: URL?
        let extensions = ["mp3", "wav"]
        
        for ext in extensions {
            let path = NSString(string: "~/Documents/TootrApp_Source/Sounds/\(name).\(ext)").expandingTildeInPath
            let url = URL(fileURLWithPath: path)
            if FileManager.default.fileExists(atPath: path) {
                fileURL = url
                break
            }
        }
        
        guard let url = fileURL else {
            print("Could not find sound file: \(name)")
            // Fallback to synthesized sound if file is missing
            playToot(baseFrequency: 100, richness: 5)
            return
        }
        
        do {
            let file = try AVAudioFile(forReading: url)
            let playerNode = AVAudioPlayerNode()
            engine.attach(playerNode)
            engine.connect(playerNode, to: pitchNode, format: file.processingFormat)
            
            playerNode.scheduleFile(file, at: nil) {
                // Cleanup after playback
                DispatchQueue.main.async {
                    self.engine.detach(playerNode)
                }
            }
            playerNode.play()
        } catch {
            print("Error playing sound file: \(error.localizedDescription)")
        }
    }
    
    /// Legacy synthesis method (remains for backup or specific effects)
    func playToot(baseFrequency: Double, richness: Int) {
        let sampleRate = 44100.0
        var phase: Double = 0
        var sampleCount = 0
        let duration = 0.6
        let totalSamples = Int(sampleRate * duration)
        
        let sourceNode = AVAudioSourceNode { _, _, frameCount, audioBufferList -> OSStatus in
            let abl = UnsafeMutableAudioBufferListPointer(audioBufferList)
            for frame in 0..<Int(frameCount) {
                if sampleCount >= totalSamples {
                    for buffer in abl {
                        let buf: UnsafeMutableBufferPointer<Float> = UnsafeMutableBufferPointer(buffer)
                        buf[frame] = 0
                    }
                    continue
                }
                
                var sample: Double = 0
                for i in 1...richness {
                    sample += (sin(phase * Double(i))) / Double(i)
                }
                
                let progress = Double(sampleCount) / Double(totalSamples)
                let envelope = progress < 0.1 ? progress * 10 : (1.0 - progress)
                let finalSample = Float(sample * envelope * 0.3)
                
                for buffer in abl {
                    let buf: UnsafeMutableBufferPointer<Float> = UnsafeMutableBufferPointer(buffer)
                    buf[frame] = finalSample
                }
                
                let currentFreq = baseFrequency * (1.0 - progress * 0.2)
                phase += (2.0 * .pi * currentFreq) / sampleRate
                sampleCount += 1
            }
            return noErr
        }
        
        engine.attach(sourceNode)
        engine.connect(sourceNode, to: pitchNode, format: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + duration + 0.1) {
            self.engine.detach(sourceNode)
        }
    }
}
