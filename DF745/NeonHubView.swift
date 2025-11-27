import SwiftUI

struct NeonHubView: View {
    @EnvironmentObject var statsStore: GameStatsStore
    @State private var showSettings = false
    @State private var selectedGame: GameDestination? = nil
    
    enum GameDestination: Identifiable {
        case tapRush
        case patternTrail
        case riskPath
        
        var id: Int {
            switch self {
            case .tapRush: return 1
            case .patternTrail: return 2
            case .riskPath: return 3
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Choose a challenge to train your focus and speed.")
                            .font(.title3)
                            .foregroundColor(Color("TextPrimary"))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    StreakProgressCard()
                        .environmentObject(statsStore)
                        .padding(.horizontal, 20)
                    
                    VStack(spacing: 16) {
                        GameCard(
                            title: "Neon Tap Rush",
                            description: "Tap the glowing tiles before time runs out. Train lightning-fast reactions.",
                            icon: "bolt.fill",
                            category: "Reaction",
                            accentColor: Color("AccentBlue")
                        )
                        .onTapGesture {
                            selectedGame = .tapRush
                        }
                        
                        GameCard(
                            title: "Pulse Pattern Trail",
                            description: "Watch the sequence, then repeat it. Perfect your pattern recognition.",
                            icon: "hexagon.fill",
                            category: "Sequences",
                            accentColor: Color("AccentCyan")
                        )
                        .onTapGesture {
                            selectedGame = .patternTrail
                        }
                        
                        GameCard(
                            title: "Risk Line Path",
                            description: "Advance for bigger rewards or secure what you have. Master risk & focus.",
                            icon: "arrow.triangle.branch",
                            category: "Risk & Focus",
                            accentColor: Color("HighlightGlow")
                        )
                        .onTapGesture {
                            selectedGame = .riskPath
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 40)
                }
                .padding(.vertical, 20)
            }
            .background(Color("PrimaryBackground").ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showSettings = true
                    }) {
                        Image(systemName: "chart.bar.fill")
                            .foregroundColor(Color("AccentCyan"))
                            .font(.system(size: 18))
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsStatsView()
                    .environmentObject(statsStore)
            }
            .background(
                Group {
                    NavigationLink(
                        destination: NeonTapRushView().environmentObject(statsStore),
                        tag: GameDestination.tapRush,
                        selection: $selectedGame
                    ) {
                        EmptyView()
                    }
                    .hidden()
                    
                    NavigationLink(
                        destination: PulsePatternTrailView().environmentObject(statsStore),
                        tag: GameDestination.patternTrail,
                        selection: $selectedGame
                    ) {
                        EmptyView()
                    }
                    .hidden()
                    
                    NavigationLink(
                        destination: RiskLinePathView().environmentObject(statsStore),
                        tag: GameDestination.riskPath,
                        selection: $selectedGame
                    ) {
                        EmptyView()
                    }
                    .hidden()
                }
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct StreakProgressCard: View {
    @EnvironmentObject var statsStore: GameStatsStore
    @State private var animateProgress = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Streak Level")
                        .font(.subheadline)
                        .foregroundColor(Color("TextSecondary"))
                    
                    Text(statsStore.streakLevel)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Color("TextPrimary"))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Total Sessions")
                        .font(.caption)
                        .foregroundColor(Color("TextSecondary"))
                    
                    Text("\(statsStore.totalSessionsPlayed)")
                        .font(.headline)
                        .foregroundColor(Color("AccentCyan"))
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color("SecondaryBackground"))
                            .frame(height: 12)
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [Color("AccentBlue"), Color("AccentCyan")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: animateProgress ? geometry.size.width * statsStore.progressToNextLevel : 0, height: 12)
                            .shadow(color: Color("HighlightGlow").opacity(0.6), radius: 8)
                    }
                }
                .frame(height: 12)
                
                if statsStore.lastSessionType.isEmpty {
                    Text("Start your first session to build your streak")
                        .font(.caption)
                        .foregroundColor(Color("TextSecondary"))
                } else {
                    Text("Last session: \(statsStore.lastSessionType) • Score: \(statsStore.lastSessionScore)")
                        .font(.caption)
                        .foregroundColor(Color("TextSecondary"))
                }
            }
        }
        .padding(20)
        .background(Color("CardBackground"))
        .cornerRadius(16)
        .shadow(color: Color("HighlightGlow").opacity(0.15), radius: 10)
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                animateProgress = true
            }
        }
    }
}

struct GameCard: View {
    let title: String
    let description: String
    let icon: String
    let category: String
    let accentColor: Color
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: icon)
                    .font(.system(size: 26))
                    .foregroundColor(accentColor)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(Color("TextPrimary"))
                    
                    Spacer()
                    
                    Text(category)
                        .font(.caption)
                        .foregroundColor(accentColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(accentColor.opacity(0.15))
                        .cornerRadius(8)
                }
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(Color("TextSecondary"))
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(2)
                
                HStack {
                    Text("Play")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(accentColor)
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 12))
                        .foregroundColor(accentColor)
                }
                .padding(.top, 4)
            }
        }
        .padding(16)
        .background(Color("CardBackground"))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color("HighlightGlow").opacity(0.3), lineWidth: 1)
        )
        .shadow(color: accentColor.opacity(0.2), radius: 15)
    }
}

