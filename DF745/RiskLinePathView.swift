import SwiftUI

struct RiskLinePathView: View {
    @EnvironmentObject var statsStore: GameStatsStore
    @Environment(\.dismiss) var dismiss
    @State private var gameState: GameState = .ready
    @State private var currentPosition = 0
    @State private var maxPosition = 10
    @State private var accumulatedOrbs = 0
    @State private var riskLevel: Double = 0.1
    @State private var sessionReward = 0
    @State private var burstHappened = false
    @State private var showSummary = false
    
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
                } else if gameState != .finished {
                    playingView
                }
            }
            .padding(20)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Risk Line Path")
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
            currentPosition = 0
            accumulatedOrbs = 0
            sessionReward = 0
        }) {
            SessionSummaryView(
                title: burstHappened ? "Risk Taken!" : "Secured!",
                score: currentPosition,
                bestScore: max(currentPosition, statsStore.bestRiskLineDepth),
                rewardAmount: sessionReward,
                rewardType: "Energy Orbs",
                gameType: "RiskLinePath"
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
                            colors: [Color("HighlightGlow").opacity(0.3), Color("AccentBlue").opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Image(systemName: "arrow.triangle.branch")
                    .font(.system(size: 50))
                    .foregroundColor(Color("HighlightGlow"))
            }
            
            VStack(spacing: 12) {
                Text("Balance risk and reward")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(Color("TextPrimary"))
                    .multilineTextAlignment(.center)
                
                Text("Move along the path to collect Energy Orbs. Each step increases your potential reward but also the risk of a burst. Secure at any time to keep what you've earned.")
                    .font(.subheadline)
                    .foregroundColor(Color("TextSecondary"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            VStack(spacing: 8) {
                HStack {
                    Text("Best Depth:")
                        .font(.subheadline)
                        .foregroundColor(Color("TextSecondary"))
                    Text("\(statsStore.bestRiskLineDepth)")
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
            VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Position")
                        .font(.caption)
                        .foregroundColor(Color("TextSecondary"))
                    Text("\(currentPosition)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color("AccentCyan"))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Potential Orbs")
                        .font(.caption)
                        .foregroundColor(Color("TextSecondary"))
                    Text("\(accumulatedOrbs)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color("HighlightGlow"))
                }
            }
            .padding(20)
            .background(Color("CardBackground"))
            .cornerRadius(16)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Risk Level")
                    .font(.subheadline)
                    .foregroundColor(Color("TextSecondary"))
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color("SecondaryBackground"))
                            .frame(height: 12)
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: riskLevel < 0.5 ? [Color("AccentBlue"), Color("AccentCyan")] : [.orange, .red],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * riskLevel, height: 12)
                    }
                }
                .frame(height: 12)
                
                Text(String(format: "%.0f%% chance of burst", riskLevel * 100))
                    .font(.caption)
                    .foregroundColor(riskLevel > 0.5 ? .red : Color("TextSecondary"))
            }
            .padding(20)
            .background(Color("CardBackground"))
            .cornerRadius(16)
            
            Spacer()
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(0..<maxPosition, id: \.self) { index in
                        PathNode(
                            position: index + 1,
                            isCurrent: currentPosition == index,
                            isPassed: currentPosition > index,
                            reward: (index + 1) * 2,
                            riskLevel: Double(index + 1) * 0.08
                        )
                    }
                }
                .padding(.vertical, 8)
            }
            .frame(maxHeight: 300)
            .background(Color("SecondaryBackground"))
            .cornerRadius(16)
            
            Spacer()
            
            HStack(spacing: 16) {
                Button(action: secureReward) {
                    VStack(spacing: 4) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 20))
                        Text("Secure")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(Color("TextSecondary"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 70)
                    .background(Color("SecondaryBackground"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color("HighlightGlow"), lineWidth: 1)
                    )
                    .cornerRadius(12)
                }
                .buttonStyle(ScaleButtonStyle())
                .disabled(currentPosition == 0)
                
                Button(action: advance) {
                    VStack(spacing: 4) {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 20))
                        Text("Advance")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 70)
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
                .disabled(currentPosition >= maxPosition)
            }
            }
        }
    }
    
    func startGame() {
        gameState = .playing
        currentPosition = 0
        accumulatedOrbs = 0
        sessionReward = 0
        riskLevel = 0.08
        burstHappened = false
        showSummary = false
    }
    
    func advance() {
        guard currentPosition < maxPosition else { return }
        
        currentPosition += 1
        let baseReward = currentPosition * 2
        accumulatedOrbs += baseReward
        riskLevel = min(0.95, Double(currentPosition) * 0.08)
        
        let randomValue = Double.random(in: 0...1)
        
        if randomValue < riskLevel {
            burstHappened = true
            sessionReward = max(1, accumulatedOrbs / 3)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                endGame()
            }
        }
    }
    
    func secureReward() {
        guard currentPosition > 0 else { return }
        sessionReward = accumulatedOrbs
        burstHappened = false
        endGame()
    }
    
    func endGame() {
        guard gameState != .finished else { return }
        
        gameState = .finished
        
        statsStore.recordSession(type: "RiskLinePath", score: currentPosition, reward: sessionReward)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showSummary = true
        }
    }
}

struct PathNode: View {
    let position: Int
    let isCurrent: Bool
    let isPassed: Bool
    let reward: Int
    let riskLevel: Double
    @State private var glowOpacity: Double = 0.5
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        isPassed ?
                        LinearGradient(
                            colors: [Color("AccentBlue"), Color("AccentCyan")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        isCurrent ?
                        LinearGradient(
                            colors: [Color("HighlightGlow"), Color("AccentCyan")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [Color("CardBackground"), Color("CardBackground")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                    .overlay(
                        Circle()
                            .stroke(Color("HighlightGlow"), lineWidth: 2)
                    )
                    .shadow(color: isCurrent ? Color("AccentCyan").opacity(glowOpacity) : .clear, radius: 15)
                
                Text("\(position)")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("+\(reward) Orbs")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("TextPrimary"))
                    
                    Spacer()
                    
                    Text(String(format: "%.0f%% risk", riskLevel * 100))
                        .font(.caption)
                        .foregroundColor(riskLevel > 0.5 ? .red : Color("TextSecondary"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color("SecondaryBackground"))
                        .cornerRadius(6)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .background(isCurrent ? Color("CardBackground") : Color.clear)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isCurrent ? Color("HighlightGlow").opacity(0.5) : Color.clear, lineWidth: 1)
        )
        .onAppear {
            if isCurrent {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    glowOpacity = 1.0
                }
            }
        }
        .onChange(of: isCurrent) { newValue in
            if newValue {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    glowOpacity = 1.0
                }
            }
        }
    }
}

