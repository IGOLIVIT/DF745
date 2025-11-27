import SwiftUI

struct NeonTapRushView: View {
    @EnvironmentObject var statsStore: GameStatsStore
    @Environment(\.dismiss) var dismiss
    @State private var gameState: GameState = .ready
    @State private var score = 0
    @State private var timeRemaining = 30.0
    @State private var activeTileIndex: Int? = nil
    @State private var timer: Timer? = nil
    @State private var tileChangeTimer: Timer? = nil
    @State private var reactionTimeLimit = 1.2
    @State private var lastTileTime: Date? = nil
    @State private var sessionReward = 0
    @State private var showSummary = false
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)
    let tileCount = 9
    
    enum GameState {
        case ready
        case playing
        case finished
    }
    
    var body: some View {
        ZStack {
            Color("PrimaryBackground")
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                if gameState == .ready {
                    readyView
                } else if gameState == .playing {
                    playingView
                }
            }
            .padding(20)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Neon Tap Rush")
                    .font(.headline)
                    .foregroundColor(Color("TextPrimary"))
            }
        }
        .onDisappear {
            timer?.invalidate()
            tileChangeTimer?.invalidate()
            timer = nil
            tileChangeTimer = nil
        }
        .sheet(isPresented: $showSummary, onDismiss: {
            gameState = .ready
            score = 0
            sessionReward = 0
        }) {
            SessionSummaryView(
                title: score > statsStore.bestNeonTapRushScore ? "New Best!" : "Good Run!",
                score: score,
                bestScore: max(score, statsStore.bestNeonTapRushScore),
                rewardAmount: sessionReward,
                rewardType: "Focus Shards",
                gameType: "NeonTapRush"
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
                            colors: [Color("AccentBlue").opacity(0.3), Color("AccentCyan").opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Image(systemName: "bolt.fill")
                    .font(.system(size: 50))
                    .foregroundColor(Color("AccentBlue"))
            }
            
            VStack(spacing: 12) {
                Text("Ready to test your reflexes?")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(Color("TextPrimary"))
                    .multilineTextAlignment(.center)
                
                Text("Tap the glowing tiles as fast as you can. Each successful tap increases your score. Miss or run out of time and the run ends.")
                    .font(.subheadline)
                    .foregroundColor(Color("TextSecondary"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            VStack(spacing: 8) {
                HStack {
                    Text("Best Score:")
                        .font(.subheadline)
                        .foregroundColor(Color("TextSecondary"))
                    Text("\(statsStore.bestNeonTapRushScore)")
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
                        Text("Score")
                            .font(.caption)
                            .foregroundColor(Color("TextSecondary"))
                        Text("\(score)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color("AccentCyan"))
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Time")
                            .font(.caption)
                            .foregroundColor(Color("TextSecondary"))
                        Text(String(format: "%.1f", timeRemaining))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(timeRemaining < 10 ? .red : Color("TextPrimary"))
                    }
                }
                .padding(16)
                .background(Color("CardBackground"))
                .cornerRadius(16)
                
                Spacer()
                
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(0..<tileCount, id: \.self) { index in
                        TileView(
                            isActive: activeTileIndex == index,
                            onTap: { handleTileTap(index) }
                        )
                    }
                }
                .padding(20)
                .background(Color("SecondaryBackground"))
                .cornerRadius(20)
                
                Spacer()
            }
        }
    }
    
    func startGame() {
        gameState = .playing
        score = 0
        timeRemaining = 30.0
        sessionReward = 0
        reactionTimeLimit = 2.0
        showSummary = false
        activeTileIndex = nil
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            timeRemaining -= 0.1
            if timeRemaining <= 0 {
                endGame()
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            activateRandomTile()
        }
    }
    
    func activateRandomTile() {
        lastTileTime = Date()
        activeTileIndex = Int.random(in: 0..<tileCount)
        
        tileChangeTimer?.invalidate()
        tileChangeTimer = Timer.scheduledTimer(withTimeInterval: reactionTimeLimit, repeats: false) { _ in
            if gameState == .playing {
                endGame()
            }
        }
    }
    
    func handleTileTap(_ index: Int) {
        guard gameState == .playing else { return }
        
        if index == activeTileIndex {
            score += 1
            sessionReward += 2
            
            if score % 10 == 0 && reactionTimeLimit > 0.8 {
                reactionTimeLimit -= 0.1
            }
            
            tileChangeTimer?.invalidate()
            activateRandomTile()
        } else {
            endGame()
        }
    }
    
    func endGame() {
        guard gameState == .playing else { return }
        
        gameState = .finished
        timer?.invalidate()
        tileChangeTimer?.invalidate()
        timer = nil
        tileChangeTimer = nil
        activeTileIndex = nil
        
        statsStore.recordSession(type: "NeonTapRush", score: score, reward: sessionReward)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showSummary = true
        }
    }
}

struct TileView: View {
    let isActive: Bool
    let onTap: () -> Void
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        Button(action: onTap) {
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    isActive ?
                    LinearGradient(
                        colors: [Color("AccentBlue"), Color("AccentCyan")],
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
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isActive ? Color("HighlightGlow") : Color("HighlightGlow").opacity(0.2), lineWidth: 2)
                )
                .frame(height: 90)
                .shadow(color: isActive ? Color("AccentCyan").opacity(0.6) : .clear, radius: 20)
                .scaleEffect(isActive ? scale : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onChange(of: isActive) { newValue in
            if newValue {
                withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                    scale = 1.1
                }
            } else {
                scale = 1.0
            }
        }
    }
}

