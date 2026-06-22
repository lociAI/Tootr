import Foundation
import AVFoundation
import Combine

enum SoundCategory: String, CaseIterable {
    case classic = "Classic"
    case melodic = "Melodic"
    case industrial = "Industrial"
    case nature = "Nature"
    case github = "GitHub Special"
}

class AudioManager: ObservableObject {
    private var engine = AVAudioEngine()
    private var soundMixer = AVAudioMixerNode()
    private var playerNodes: [String: AVAudioPlayerNode] = [:]
    private var pitchNodes: [String: AVAudioUnitTimePitch] = [:]
    private var audioBuffers: [String: AVAudioPCMBuffer] = [:]
    
    private var reverbNode = AVAudioUnitReverb()
    private var distortionNode = AVAudioUnitDistortion()
    private var delayNode = AVAudioUnitDelay()
    
    private let audioQueue = DispatchQueue(label: "com.tootr.audioQueue", qos: .userInteractive)
    private var isEngineReady = false
    
    @Published var bpm: Double = 120
    @Published var isBeatActive = false {
        didSet { if isBeatActive { startBeat() } else { stopBeat() } }
    }
    private var beatTimer: Timer?
    
    @Published var currentCategory: SoundCategory = .classic {
        didSet { 
            audioQueue.async { self.updateFXSettings() }
            DispatchQueue.main.async { self.objectWillChange.send() } 
        }
    }
    
    @Published var isGrossModeEnabled = false {
        didSet { audioQueue.async { self.updateFXSettings() } }
    }
    
    private let bundledFiles = ["wet", "dry", "squeak", "power", "short", "long", "trumpet", "bean"]
    
    private let padNames: [SoundCategory: [String]] = [
        .classic: ["Ripper", "Gusher", "Squeaker", "Power", "Snap", "Haul", "Horn", "Bean"],
        .melodic: ["Do", "Re", "Mi", "Fa", "Sol", "La", "Ti", "High"],
        .industrial: ["Valve", "Piston", "Vent", "Crush", "Drip", "Grind", "Spark", "Hydra"],
        .nature: ["Quake", "Slide", "Echo", "Gust", "Snap", "Roll", "Splash", "Thunder"],
        .github: ["Push", "Null", "Buffer", "Logic", "Root", "Dump", "Panic", "Init"]
    ]
    
    var currentSounds: [String] { padNames[currentCategory] ?? [] }
    
    init() {
        setupAudioSession()
        audioQueue.async {
            self.setupEngine()
            self.preloadAllBuffers()
            self.updateFXSettings()
            self.isEngineReady = true
        }
        setupNotifications()
    }
    
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.defaultToSpeaker, .allowBluetoothA2DP])
            try session.setActive(true)
        } catch { print("AudioSession error: \(error)") }
    }
    
    func setupEngine() {
        engine.attach(soundMixer)
        engine.attach(reverbNode)
        engine.attach(distortionNode)
        engine.attach(delayNode)
        
        engine.connect(soundMixer, to: reverbNode, format: nil)
        engine.connect(reverbNode, to: distortionNode, format: nil)
        engine.connect(distortionNode, to: delayNode, format: nil)
        engine.connect(delayNode, to: engine.mainMixerNode, format: nil)
        
        for cat in SoundCategory.allCases {
            for name in padNames[cat]! {
                let key = "\(cat.rawValue)_\(name)"
                let playerNode = AVAudioPlayerNode()
                let pitchNode = AVAudioUnitTimePitch()
                engine.attach(playerNode)
                engine.attach(pitchNode)
                engine.connect(playerNode, to: pitchNode, format: nil)
                engine.connect(pitchNode, to: soundMixer, format: nil)
                playerNodes[key] = playerNode
                pitchNodes[key] = pitchNode
            }
        }
        
        engine.prepare()
        try? engine.start()
    }
    
    private func preloadAllBuffers() {
        for name in bundledFiles {
            if let url = Bundle.main.url(forResource: name, withExtension: "mp3") {
                do {
                    let file = try AVAudioFile(forReading: url)
                    if let buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: AVAudioFrameCount(file.length)) {
                        try file.read(into: buffer)
                        audioBuffers[name] = buffer
                    }
                } catch { print("Load error \(name): \(error)") }
            }
        }
    }
    
    func playSound(name: String, pitch: Float = 1.0) {
        let key = "\(currentCategory.rawValue)_\(name)"
        let namesList = padNames[currentCategory]!
        let index = namesList.firstIndex(of: name) ?? 0
        let baseFile = bundledFiles[index % bundledFiles.count]
        
        let now = Date()
        if let lastTime = lastPlayTime[baseFile], now.timeIntervalSince(lastTime) < 0.04 { return }
        lastPlayTime[baseFile] = now
        
        audioQueue.async { [weak self] in
            guard let self = self, self.isEngineReady, 
                  let playerNode = self.playerNodes[key], 
                  let pitchNode = self.pitchNodes[key],
                  let buffer = self.audioBuffers[baseFile] else { return }
            
            if !self.engine.isRunning { try? self.engine.start() }
            
            var uniquePitch: Float = 1.0
            switch self.currentCategory {
            case .melodic: uniquePitch = 1.3 + (Float(index) * 0.12)
            case .nature: uniquePitch = 0.5 + (Float(index) * 0.05)
            case .industrial: uniquePitch = 0.8
            case .github: uniquePitch = 1.1 + (Float(index) * 0.15)
            case .classic: uniquePitch = (name == "Squeaker") ? 1.8 : 1.0
            }
            
            pitchNode.pitch = ((pitch * uniquePitch) - 1.0) * 1200
            playerNode.stop()
            playerNode.scheduleBuffer(buffer, at: nil, options: .interrupts, completionHandler: nil)
            playerNode.play()
        }
    }
    
    func playPumpItUp() {
        let interval = 0.25
        let sequence = [
            (name: "Horn", pitch: 0.8),
            (name: "Horn", pitch: 0.8),
            (name: "Horn", pitch: 1.0),
            (name: "Horn", pitch: 1.2)
        ]
        
        for (i, note) in sequence.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + (Double(i) * interval)) {
                self.playSound(name: note.name, pitch: Float(note.pitch))
            }
        }
    }
    
    private func updateFXSettings() {
        let isGross = isGrossModeEnabled
        switch currentCategory {
        case .classic:
            reverbNode.loadFactoryPreset(.smallRoom); reverbNode.wetDryMix = isGross ? 70 : 10
            distortionNode.wetDryMix = isGross ? 60 : 0; delayNode.wetDryMix = 0
        case .melodic:
            reverbNode.loadFactoryPreset(.mediumHall); reverbNode.wetDryMix = 45
            distortionNode.wetDryMix = isGross ? 40 : 0
            delayNode.wetDryMix = 25; delayNode.delayTime = 0.25; delayNode.feedback = 35
        case .industrial:
            reverbNode.loadFactoryPreset(.plate); reverbNode.wetDryMix = 25
            distortionNode.loadFactoryPreset(.multiDistortedFunk); distortionNode.wetDryMix = isGross ? 85 : 55
            delayNode.wetDryMix = 15; delayNode.delayTime = 0.1; delayNode.feedback = 25
        case .nature:
            reverbNode.loadFactoryPreset(.cathedral); reverbNode.wetDryMix = 65
            distortionNode.wetDryMix = isGross ? 35 : 0
            delayNode.wetDryMix = 40; delayNode.delayTime = 0.55; delayNode.feedback = 45
        case .github:
            reverbNode.loadFactoryPreset(.cathedral); reverbNode.wetDryMix = 80
            distortionNode.loadFactoryPreset(.speechAlienChatter); distortionNode.wetDryMix = 55
            delayNode.wetDryMix = 55; delayNode.delayTime = 0.35; delayNode.feedback = 65
        }
    }
    
    @Published var loopingPads: Set<Int> = []
    
    func toggleLoop(index: Int) {
        if loopingPads.contains(index) {
            loopingPads.remove(index)
        } else {
            loopingPads.insert(index)
            if !isBeatActive { isBeatActive = true }
        }
    }

    private var beatStep = 0
    private func startBeat() {
        stopBeat()
        beatStep = 0
        beatTimer = Timer.scheduledTimer(withTimeInterval: 60.0/max(30, bpm), repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.audioQueue.async {
                if self.beatStep % 2 == 0 {
                    self.playSound(name: self.currentSounds[3], pitch: 0.7) // Kick
                } else {
                    self.playSound(name: self.currentSounds[4], pitch: 1.1) // Snare
                }
                for padIndex in self.loopingPads {
                    if padIndex < self.currentSounds.count {
                        self.playSound(name: self.currentSounds[padIndex], pitch: 1.0)
                    }
                }
                self.beatStep = (self.beatStep + 1) % 4
            }
        }
    }
    private func stopBeat() { beatTimer?.invalidate(); beatTimer = nil }
    func updateBPM(_ newBPM: Double) { self.bpm = newBPM; if isBeatActive { startBeat() } }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(forName: AVAudioSession.interruptionNotification, object: nil, queue: .main) { [weak self] _ in
            self?.audioQueue.async { try? self?.engine.start() }
        }
    }
    
    @Published var isRecording = false
    private var recordingFile: AVAudioFile?
    
    @Published var recordedURL: URL?
    
    func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    private func startRecording() {
        let format = delayNode.outputFormat(forBus: 0)
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsDirectory.appendingPathComponent("TootrMix_\(Int(Date().timeIntervalSince1970)).caf")
        
        do {
            recordingFile = try AVAudioFile(forWriting: fileURL, settings: format.settings)
            isRecording = true
            recordedURL = nil
            
            delayNode.installTap(onBus: 0, bufferSize: 4096, format: format) { [weak self] (buffer, time) in
                guard let self = self else { return }
                do {
                    try self.recordingFile?.write(from: buffer)
                } catch {
                    print("Error writing to recording file: \(error)")
                }
            }
        } catch {
            print("Could not create recording file: \(error)")
        }
    }
    
    private func stopRecording() {
        delayNode.removeTap(onBus: 0)
        isRecording = false
        recordedURL = recordingFile?.url
        recordingFile = nil
    }
    
    func playRecording() {
        guard let url = recordedURL else { return }
        let player = AVPlayer(url: url)
        player.play()
    }
    
    private var lastPlayTime: [String: Date] = [:]
}
