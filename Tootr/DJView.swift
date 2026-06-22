import SwiftUI

// MARK: - 5-Star Styling Extensions
extension View {
    func tactilePanel(padding: CGFloat = 12) -> some View {
        self.padding(padding)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(white: 0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(LinearGradient(colors: [.white.opacity(0.12), .black.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1.5)
                    )
                    .shadow(color: .black.opacity(0.4), radius: 10, x: 0, y: 5)
            )
    }
}

struct DJView: View {
    @StateObject private var audioManager = AudioManager()
    @StateObject private var storeManager = StoreManager()
    @State private var masterPitch: Float = 1.0
    @State private var showingInfo = false
    @State private var showingPaywall = false
    @State private var isLoopMode = false
    @State private var pulseAnim = 0.0
    
    // 5-Star Kids Palette
    let kidBlue = Color(red: 0.0, green: 0.7, blue: 1.0)
    let kidPink = Color(red: 1.0, green: 0.2, blue: 0.6)
    let kidGreen = Color(red: 0.2, green: 1.0, blue: 0.5)
    let kidYellow = Color(red: 1.0, green: 0.9, blue: 0.0)
    let kidPurple = Color(red: 0.7, green: 0.3, blue: 1.0)
    let kidOrange = Color(red: 1.0, green: 0.5, blue: 0.0)
    
    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            let safe = geometry.safeAreaInsets
            
            ZStack {
                Color(white: 0.04).ignoresSafeArea()
                
                // Studio Ambient Lighting
                ZStack {
                    RadialGradient(colors: [currentCategoryColor().opacity(0.18), .clear], center: .topLeading, startRadius: 0, endRadius: geometry.size.width * 0.8)
                    RadialGradient(colors: [kidPink.opacity(0.1), .clear], center: .bottomTrailing, startRadius: 0, endRadius: geometry.size.width * 0.8)
                }.blur(radius: 60).ignoresSafeArea().blendMode(.screen)
                
                if isLandscape {
                    iphoneLandscapeStoreReady(w: geometry.size.width, h: geometry.size.height, safe: safe)
                } else {
                    iphonePortrait(w: geometry.size.width, h: geometry.size.height, safe: safe)
                }
            }
            .sheet(isPresented: $showingInfo) {
                InfoView()
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView().environmentObject(storeManager)
            }
        }
        .ignoresSafeArea()
        .statusBarHidden(true)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                pulseAnim = 1.0
            }
        }
    }
    
    private func currentCategoryColor() -> Color {
        switch audioManager.currentCategory {
            case .classic: return kidBlue
            case .melodic: return kidPurple
            case .industrial: return kidOrange
            case .nature: return kidGreen
            case .github: return kidPink
        }
    }

    // MARK: - IPHONE LANDSCAPE (STORE READY)
    private func iphoneLandscapeStoreReady(w: CGFloat, h: CGFloat, safe: EdgeInsets) -> some View {
        let usableW = w - safe.leading - safe.trailing - 16
        // Subtract vertical spacings (3 * 12) + paddings to prevent overflow
        let usableH = h - safe.top - safe.bottom - 50
        
        let topH = usableH * 0.15
        let mainH = usableH * 0.52
        let hubH = usableH * 0.18
        let footH = usableH * 0.15
        
        return VStack(spacing: 12) {
            // TOP BAR
            HStack(spacing: 15) {
                headerViewStore(h: topH, showStudio: false)
                categoryBar(h: topH * 0.85, w: usableW * 0.4)
                Spacer()
                pumpButton(h: topH * 0.8)
            }
            .padding(.top, safe.top + 4)
            
            // PERFORMANCE ZONE
            HStack(spacing: 16) {
                deckSection(w: usableW * 0.43, h: mainH, isLandscape: true)
                    .tactilePanel(padding: 8)
                
                padsGrid(colW: usableW * 0.43, availableH: mainH)
                    .tactilePanel(padding: 8)
            }
            
            // PRO HUB
            HStack {
                Spacer()
                HStack(spacing: 10) {
                    modeButton(title: "LOOP", active: isLoopMode, color: kidPink, h: hubH) { isLoopMode.toggle() }
                    modeButton(title: "BEATS", active: audioManager.isBeatActive, color: kidGreen, h: hubH) { audioManager.isBeatActive.toggle() }
                    recordButtonStore(h: hubH)
                    grossButton(h: hubH)
                }
                .frame(width: usableW * 0.95)
                Spacer()
            }
            
            // FOOTER
            HStack {
                Text("\(Int(audioManager.bpm)) BPM").font(.system(size: footH * 0.5, weight: .black, design: .monospaced)).foregroundColor(kidBlue).lineLimit(1)
                Spacer()
                frequencyVisualizer(count: 40, height: footH * 0.8)
                Spacer()
                Button(action: { audioManager.playRecording() }) {
                    HStack(spacing: 6) {
                        Text("PLAY MIX").font(.system(size: footH * 0.4, weight: .bold, design: .rounded))
                        Image(systemName: "play.fill")
                    }
                    .foregroundColor(.white.opacity(0.4))
                }
            }
            .padding(.bottom, safe.bottom > 0 ? safe.bottom + 8 : 16)
        }
        .padding(.horizontal, safe.leading > 0 ? safe.leading : 12)
    }

    // MARK: - IPHONE PORTRAIT
    private func iphonePortrait(w: CGFloat, h: CGFloat, safe: EdgeInsets) -> some View {
        let usableW = w - 16
        // Subtract all vertical spacings and paddings so content fits
        let usableH = h - safe.top - safe.bottom - 90
        
        return VStack(spacing: 12) {
            headerViewStore(h: usableH * 0.06)
            
            VStack(spacing: 12) {
                deckSection(w: usableW - 16, h: usableH * 0.22, isLandscape: false)
                categoryBar(h: usableH * 0.05, w: usableW)
            }
            .tactilePanel(padding: 8)
            
            HStack(spacing: 10) {
                modeButton(title: "LOOP", active: isLoopMode, color: kidPink, h: usableH * 0.07) { isLoopMode.toggle() }
                modeButton(title: "DRUMS", active: audioManager.isBeatActive, color: kidGreen, h: usableH * 0.07) { audioManager.isBeatActive.toggle() }
                Button(action: { audioManager.toggleRecording() }) {
                    Circle().fill(audioManager.isRecording ? .red : .white.opacity(0.1))
                        .frame(height: usableH * 0.07)
                        .overlay(Circle().stroke(audioManager.isRecording ? .red : .white.opacity(0.3), lineWidth: 2))
                }
                grossButton(h: usableH * 0.07)
            }
            
            VStack(spacing: 10) {
                padsGrid(colW: usableW - 16, availableH: usableH * 0.42)
                frequencyVisualizer(count: 20, height: 20)
            }
            .tactilePanel(padding: 8)
            .layoutPriority(1)
            
            HStack {
                Text("\(Int(audioManager.bpm)) BPM").font(.system(size: 14, weight: .black, design: .monospaced)).foregroundColor(kidBlue)
                Spacer()
                Button("PLAY MIX") { audioManager.playRecording() }.font(.system(size: 12, weight: .bold)).foregroundColor(.white.opacity(0.4))
            }
            .padding(.bottom, safe.bottom > 0 ? safe.bottom + 20 : 24)
        }
        .padding(.horizontal, 8)
        .padding(.top, safe.top > 0 ? safe.top + 4 : 10)
    }

    // MARK: - COMPONENTS
    
    private func headerViewStore(h: CGFloat, showStudio: Bool = true) -> some View {
        HStack(spacing: 6) {
            Text("TOOTR").font(.system(size: h * 0.7, weight: .black, design: .rounded))
            if showStudio {
                Text("STUDIO").font(.system(size: h * 0.35, weight: .bold, design: .rounded)).foregroundColor(kidYellow)
            }
        }
        .foregroundColor(.white)
        .lineLimit(1)
    }
    
    private func pumpButton(h: CGFloat) -> some View {
        Button(action: { 
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            audioManager.playPumpItUp() 
        }) {
            Text("PUMP IT!")
                .font(.system(size: h * 0.4, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 16).frame(height: h)
                .background(
                    ZStack {
                        Capsule().fill(kidPurple)
                        Capsule().stroke(Color.white.opacity(0.5), lineWidth: 2)
                    }
                )
                .shadow(color: kidPurple.opacity(0.5), radius: 10)
                .scaleEffect(1.0 + (pulseAnim * 0.03))
        }
    }
    
    private func recordButtonStore(h: CGFloat) -> some View {
        Button(action: { audioManager.toggleRecording() }) {
            HStack(spacing: 8) {
                Circle().fill(audioManager.isRecording ? .red : .white.opacity(0.4))
                    .frame(width: h * 0.25, height: h * 0.25)
                    .opacity(audioManager.isRecording ? pulseAnim : 1.0)
                Text(audioManager.isRecording ? "STOP" : "RECORD").font(.system(size: h * 0.3, weight: .black, design: .rounded))
            }
            .frame(maxWidth: .infinity).frame(height: h)
            .background(RoundedRectangle(cornerRadius: h * 0.35).fill(audioManager.isRecording ? Color.red.opacity(0.25) : Color.white.opacity(0.08)))
            .foregroundColor(audioManager.isRecording ? .red : .white)
            .overlay(RoundedRectangle(cornerRadius: h * 0.35).stroke(audioManager.isRecording ? Color.red.opacity(0.7) : Color.white.opacity(0.12), lineWidth: 2))
            .lineLimit(1)
        }
    }
    
    private func deckSection(w: CGFloat, h: CGFloat, isLandscape: Bool) -> some View {
        let pSize = min(w * 0.45, h * 0.95)
        return HStack(spacing: 12) {
            deck(label: "A", sound: audioManager.currentSounds[0], size: pSize, color: kidBlue)
            
            // Functional Pitch Slider
            VStack(spacing: 4) {
                GeometryReader { sliderGeo in
                    let trackH = sliderGeo.size.height
                    ZStack(alignment: .bottom) {
                        Capsule().fill(Color.black.opacity(0.4)).frame(width: 12)
                        Capsule().fill(kidYellow).frame(width: 12, height: trackH * CGFloat((masterPitch - 0.5) / 1.5))
                            .shadow(color: kidYellow.opacity(0.5), radius: 5)
                    }
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let percent = 1.0 - (value.location.y / trackH)
                                masterPitch = Float(0.5 + (max(0, min(1, percent)) * 1.5))
                            }
                    )
                }
                .frame(width: 20, height: h * 0.65)
                
                Text("PITCH").font(.system(size: 8, weight: .black)).foregroundColor(kidYellow.opacity(0.8)).lineLimit(1)
            }
            
            deck(label: "B", sound: audioManager.currentSounds[1], size: pSize, color: kidPink)
        }
    }
    
    private func deck(label: String, sound: String, size: CGFloat, color: Color) -> some View {
        VStack(spacing: 6) {
            ScratchPlatter { delta in audioManager.playSound(name: sound, pitch: Float(1.0 + (delta/150))) }
                .frame(width: size, height: size)
                .overlay(Circle().stroke(color, lineWidth: 4).padding(-1))
            Text(label).font(.system(size: 10, weight: .black)).foregroundColor(color).lineLimit(1)
        }
    }

    private func padsGrid(colW: CGFloat, availableH: CGFloat) -> some View {
        let spacing: CGFloat = 10
        let padSize = min((colW - (3 * spacing)) / 4, (availableH - spacing) / 2)
        
        return VStack(spacing: spacing) {
            ForEach(0..<2) { row in
                HStack(spacing: spacing) {
                    ForEach(0..<4) { col in
                        let index = (row * 4) + col
                        let colors: [Color] = [kidBlue, kidYellow, kidPurple, kidGreen, kidPink, kidOrange, kidBlue, kidYellow]
                        let isLocked = false // TEMPORARILY UNLOCKED FOR SCREENSHOTS
                        SoundPad(
                            name: audioManager.currentSounds[index].replacingOccurrences(of: ".mp3", with: "").replacingOccurrences(of: "gh_", with: ""),
                            color: colors[index],
                            isLooping: audioManager.loopingPads.contains(index),
                            isLocked: isLocked,
                            action: {
                                if isLocked {
                                    showingPaywall = true
                                } else {
                                    if isLoopMode { audioManager.toggleLoop(index: index) }
                                    else { audioManager.playSound(name: audioManager.currentSounds[index], pitch: masterPitch) }
                                }
                            }
                        )
                        .frame(width: padSize, height: padSize)
                    }
                }
            }
        }
    }

    private func modeButton(title: String, active: Bool, color: Color, h: CGFloat, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title).font(.system(size: h * 0.3, weight: .black, design: .rounded))
                .frame(maxWidth: .infinity).frame(height: h)
                .background(RoundedRectangle(cornerRadius: h * 0.35).fill(active ? color : Color.white.opacity(0.1)))
                .foregroundColor(.white)
                .overlay(RoundedRectangle(cornerRadius: h * 0.35).stroke(Color.white.opacity(active ? 0.6 : 0.1), lineWidth: 2))
                .shadow(color: active ? color.opacity(0.4) : .clear, radius: 10)
                .lineLimit(1).minimumScaleFactor(0.5)
        }
    }

    private func grossButton(h: CGFloat) -> some View {
        Button(action: { audioManager.isGrossModeEnabled.toggle() }) {
            Image(systemName: "flame.fill").font(.system(size: h * 0.45))
                .frame(width: h * 1.4, height: h)
                .background(RoundedRectangle(cornerRadius: h * 0.35).fill(audioManager.isGrossModeEnabled ? kidOrange : Color.white.opacity(0.1)))
                .foregroundColor(.white)
                .shadow(color: audioManager.isGrossModeEnabled ? kidOrange.opacity(0.4) : .clear, radius: 10)
        }
    }

    private func categoryBar(h: CGFloat, w: CGFloat) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(SoundCategory.allCases, id: \.self) { cat in
                    Button(action: { audioManager.currentCategory = cat }) {
                        Text(cat.rawValue.uppercased())
                            .font(.system(size: h * 0.35, weight: .black, design: .rounded))
                            .padding(.horizontal, 16).padding(.vertical, h * 0.15)
                            .background(audioManager.currentCategory == cat ? kidBlue : Color.white.opacity(0.1))
                            .clipShape(Capsule())
                            .foregroundColor(.white)
                            .lineLimit(1)
                    }
                }
            }
        }
        .frame(width: w, height: h)
    }

    private func frequencyVisualizer(count: Int, height: CGFloat) -> some View {
        HStack(alignment: .center, spacing: 3) {
            ForEach(0..<count, id: \.self) { i in
                RoundedRectangle(cornerRadius: 1).fill(kidYellow.opacity(0.6))
                    .frame(width: 4, height: height * (0.3 + (sin(Double(i) * 0.4 + pulseAnim * 6) * 0.7)))
            }
        }
        .frame(height: height)
    }
}

struct InfoView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        ZStack {
            Color(white: 0.05).ignoresSafeArea()
            VStack(spacing: 20) {
                Text("TOOTR KIDS DJ").font(.system(size: 32, weight: .black, design: .rounded)).foregroundColor(.white).lineLimit(1)
                Spacer()
                Button("Let's Jam!") { dismiss() }.buttonStyle(.borderedProminent).tint(Color.blue).controlSize(.large)
            }.padding(40)
        }
    }
}
