import SwiftUI

struct SettingsStatsView: View {
    @EnvironmentObject var statsStore: GameStatsStore
    @Environment(\.dismiss) var dismiss
    @State private var showResetConfirmation = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("PrimaryBackground")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Overall Progress")
                                .font(.headline)
                                .foregroundColor(Color("TextPrimary"))
                            
                            VStack(spacing: 12) {
                                StatRow(
                                    label: "Streak Level",
                                    value: statsStore.streakLevel,
                                    icon: "star.fill",
                                    accentColor: Color("AccentCyan")
                                )
                                
                                StatRow(
                                    label: "Total Sessions",
                                    value: "\(statsStore.totalSessionsPlayed)",
                                    icon: "play.circle.fill",
                                    accentColor: Color("AccentBlue")
                                )
                                
                                Divider()
                                    .background(Color("HighlightGlow").opacity(0.3))
                                
                                StatRow(
                                    label: "Focus Shards",
                                    value: "\(statsStore.totalFocusShards)",
                                    icon: "bolt.fill",
                                    accentColor: Color("AccentBlue")
                                )
                                
                                StatRow(
                                    label: "Pattern Fragments",
                                    value: "\(statsStore.totalPatternFragments)",
                                    icon: "hexagon.fill",
                                    accentColor: Color("AccentCyan")
                                )
                                
                                StatRow(
                                    label: "Energy Orbs",
                                    value: "\(statsStore.totalEnergyOrbs)",
                                    icon: "arrow.triangle.branch",
                                    accentColor: Color("HighlightGlow")
                                )
                            }
                            .padding(16)
                            .background(Color("CardBackground"))
                            .cornerRadius(16)
                        }
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Best Scores")
                                .font(.headline)
                                .foregroundColor(Color("TextPrimary"))
                            
                            VStack(spacing: 12) {
                                GameStatCard(
                                    title: "Neon Tap Rush",
                                    score: statsStore.bestNeonTapRushScore,
                                    icon: "bolt.fill",
                                    accentColor: Color("AccentBlue")
                                )
                                
                                GameStatCard(
                                    title: "Pulse Pattern Trail",
                                    score: statsStore.bestPulsePatternTrailLength,
                                    icon: "hexagon.fill",
                                    accentColor: Color("AccentCyan")
                                )
                                
                                GameStatCard(
                                    title: "Risk Line Path",
                                    score: statsStore.bestRiskLineDepth,
                                    icon: "arrow.triangle.branch",
                                    accentColor: Color("HighlightGlow")
                                )
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Settings")
                                .font(.headline)
                                .foregroundColor(Color("TextPrimary"))
                            
                            Button(action: {
                                showResetConfirmation = true
                            }) {
                                HStack {
                                    Image(systemName: "arrow.counterclockwise.circle.fill")
                                        .font(.system(size: 22))
                                        .foregroundColor(.red)
                                    
                                    Text("Reset All Progress")
                                        .font(.subheadline)
                                        .foregroundColor(.red)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color("TextSecondary"))
                                }
                                .padding(16)
                                .background(Color("CardBackground"))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding(20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Stats & Settings")
                        .font(.headline)
                        .foregroundColor(Color("TextPrimary"))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color("TextSecondary"))
                            .font(.system(size: 22))
                    }
                }
            }
            .confirmationDialog(
                "Reset All Progress?",
                isPresented: $showResetConfirmation,
                titleVisibility: .visible
            ) {
                Button("Reset Everything", role: .destructive) {
                    statsStore.resetAllProgress()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will clear all your stats, rewards, and best scores. This action cannot be undone.")
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct StatRow: View {
    let label: String
    let value: String
    let icon: String
    let accentColor: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(accentColor)
                .frame(width: 30)
            
            Text(label)
                .font(.subheadline)
                .foregroundColor(Color("TextSecondary"))
            
            Spacer()
            
            Text(value)
                .font(.headline)
                .foregroundColor(Color("TextPrimary"))
        }
    }
}

struct GameStatCard: View {
    let title: String
    let score: Int
    let icon: String
    let accentColor: Color
    @State private var animateScore = false
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(accentColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(Color("TextPrimary"))
                
                Text("Best: \(animateScore ? score : 0)")
                    .font(.caption)
                    .foregroundColor(Color("TextSecondary"))
            }
            
            Spacer()
            
            Text("\(animateScore ? score : 0)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(accentColor)
        }
        .padding(16)
        .background(Color("CardBackground"))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(accentColor.opacity(0.2), lineWidth: 1)
        )
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animateScore = true
            }
        }
    }
}

