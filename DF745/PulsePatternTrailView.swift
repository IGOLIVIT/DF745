import SwiftUI

struct PulsePatternTrailView: View {
    @EnvironmentObject var statsStore: GameStatsStore
    @Environment(\.dismiss) var dismiss
    @State private var gameState: GameState = .ready
    @State private var sequence: [Int] = []
    @State private var userSequence: [Int] = []
    @State private var currentRound = 0
    @State private var isShowingSequence = false
    @State private var highlightedPad: Int? = nil
    @State private var sessionReward = 0
    @State private var shakePad: Int? = nil
    @State private var showSummary = false
    
    let padCount = 6
    let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 3)
    
    enum GameState {
        case ready
        case playing
        case showingSequence
        case userTurn
        case finished
    }
    
    var body: some View {
        ZStack {
            Color("PrimaryBackground")
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                if gameState == .ready {
                    readyView
                } else if gameState != .finished {
                    playingView
                }
            }
            .padding(20)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Pulse Pattern Trail")
                    .font(.headline)
                    .foregroundColor(Color("TextPrimary"))
            }
        }
        .onDisappear {
            if gameState != .finished {
                gameState = .ready
            }
        }
        .sheet(isPresented: $showSummary, onDismiss: {
            gameState = .ready
            currentRound = 0
            sequence = []
            userSequence = []
            sessionReward = 0
        }) {
            SessionSummaryView(
                title: currentRound > statsStore.bestPulsePatternTrailLength ? "New Record!" : "Great Focus!",
                score: currentRound,
                bestScore: max(currentRound, statsStore.bestPulsePatternTrailLength),
                rewardAmount: sessionReward,
                rewardType: "Pattern Fragments",
                gameType: "PulsePatternTrail"
            )
            .environmentObject(statsStore)
        }
    }
    
    var readyView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color("AccentCyan").opacity(0.3), Color("AccentBlue").opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Image(systemName: "hexagon.fill")
                    .font(.system(size: 50))
                    .foregroundColor(Color("AccentCyan"))
            }
            
            VStack(spacing: 12) {
                Text("Test your pattern skills")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(Color("TextPrimary"))
                    .multilineTextAlignment(.center)
                
                Text("Watch the glowing sequence carefully, then repeat it by tapping the pads in the same order. Each round adds one more step.")
                    .font(.subheadline)
                    .foregroundColor(Color("TextSecondary"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            VStack(spacing: 8) {
                HStack {
                    Text("Best Sequence:")
                        .font(.subheadline)
                        .foregroundColor(Color("TextSecondary"))
                    Text("\(statsStore.bestPulsePatternTrailLength)")
                        .font(.headline)
                        .foregroundColor(Color("AccentCyan"))
                }
            }
            .padding(16)
            .background(Color("CardBackground"))
            .cornerRadius(12)
            
            Spacer()
            
            Button(action: startGame) {
                Text("Start Game")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        LinearGradient(
                            colors: [Color("AccentBlue"), Color("AccentCyan")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
            }
            .buttonStyle(ScaleButtonStyle())
        }
    }
    
    var playingView: some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Round")
                            .font(.caption)
                            .foregroundColor(Color("TextSecondary"))
                        Text("\(currentRound)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color("AccentCyan"))
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Status")
                            .font(.caption)
                            .foregroundColor(Color("TextSecondary"))
                        Text(isShowingSequence ? "Watch" : "Your Turn")
                            .font(.headline)
                            .foregroundColor(isShowingSequence ? Color("AccentBlue") : Color("AccentCyan"))
                    }
                }
                .padding(16)
                .background(Color("CardBackground"))
                .cornerRadius(16)
                
                Spacer()
                
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(0..<padCount, id: \.self) { index in
                        PatternPad(
                            index: index,
                            isHighlighted: highlightedPad == index,
                            isShaking: shakePad == index,
                            onTap: { handlePadTap(index) }
                        )
                    }
                }
                .padding(20)
                .background(Color("SecondaryBackground"))
                .cornerRadius(20)
                
                if !isShowingSequence && gameState == .userTurn {
                    Text("Tap the pads in order: \(userSequence.count)/\(sequence.count)")
                        .font(.subheadline)
                        .foregroundColor(Color("TextSecondary"))
                        .padding(.horizontal)
                }
                
                Spacer()
            }
        }
    }
    
    func startGame() {
        gameState = .playing
        currentRound = 0
        sequence = []
        userSequence = []
        sessionReward = 0
        showSummary = false
        highlightedPad = nil
        shakePad = nil
        nextRound()
    }
    
    func nextRound() {
        currentRound += 1
        userSequence = []
        sequence.append(Int.random(in: 0..<padCount))
        gameState = .showingSequence
        isShowingSequence = true
        showSequence()
    }
    
    func showSequence() {
        var index = 0
        highlightedPad = nil
        
        Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { timer in
            if index < sequence.count {
                highlightedPad = sequence[index]
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    highlightedPad = nil
                }
                
                index += 1
            } else {
                timer.invalidate()
                isShowingSequence = false
                gameState = .userTurn
            }
        }
    }
    
    func handlePadTap(_ index: Int) {
        guard gameState == .userTurn && !isShowingSequence else { return }
        
        userSequence.append(index)
        
        if userSequence.last == sequence[userSequence.count - 1] {
            highlightedPad = index
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                highlightedPad = nil
            }
            
            if userSequence.count == sequence.count {
                sessionReward += currentRound * 3
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    nextRound()
                }
            }
        } else {
            shakePad = index
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                shakePad = nil
                endGame()
            }
        }
    }
    
    func endGame() {
        guard gameState != .finished else { return }
        
        gameState = .finished
        highlightedPad = nil
        
        statsStore.recordSession(type: "PulsePatternTrail", score: currentRound, reward: sessionReward)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showSummary = true
        }
    }
}

struct PatternPad: View {
    let index: Int
    let isHighlighted: Bool
    let isShaking: Bool
    let onTap: () -> Void
    @State private var glowOpacity: Double = 0.5
    @State private var shakeOffset: CGFloat = 0
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        isHighlighted ?
                        LinearGradient(
                            colors: [Color("AccentCyan"), Color("AccentBlue")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [Color("CardBackground"), Color("CardBackground")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(isHighlighted ? Color("HighlightGlow") : Color("HighlightGlow").opacity(0.3), lineWidth: 2)
                    )
                    .frame(height: 100)
                    .shadow(color: isHighlighted ? Color("AccentCyan").opacity(glowOpacity) : .clear, radius: 20)
                
                if isHighlighted {
                    Image(systemName: "hexagon.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .offset(x: isShaking ? shakeOffset : 0)
        .onChange(of: isHighlighted) { newValue in
            if newValue {
                withAnimation(.easeInOut(duration: 0.3).repeatForever(autoreverses: true)) {
                    glowOpacity = 1.0
                }
            } else {
                glowOpacity = 0.5
            }
        }
        .onChange(of: isShaking) { newValue in
            if newValue {
                withAnimation(.easeInOut(duration: 0.05).repeatCount(6, autoreverses: true)) {
                    shakeOffset = 10
                }
            } else {
                shakeOffset = 0
            }
        }
    }
}

