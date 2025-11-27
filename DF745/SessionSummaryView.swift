import SwiftUI

struct SessionSummaryView: View {
    @EnvironmentObject var statsStore: GameStatsStore
    @Environment(\.dismiss) var dismiss
    
    let title: String
    let score: Int
    let bestScore: Int
    let rewardAmount: Int
    let rewardType: String
    let gameType: String
    
    @State private var animateReward = false
    @State private var showContent = false
    @State private var glowOpacity: Double = 0.5
    
    var body: some View {
        ZStack {
            Color("PrimaryBackground")
                .ignoresSafeArea()
            
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
                        .frame(width: 140, height: 140)
                        .shadow(color: Color("AccentCyan").opacity(glowOpacity), radius: 30)
                    
                    Image(systemName: score >= bestScore ? "star.fill" : "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(Color("AccentCyan"))
                }
                .scaleEffect(showContent ? 1.0 : 0.5)
                .opacity(showContent ? 1 : 0)
                
                VStack(spacing: 12) {
                    Text(title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color("TextPrimary"))
                    
                    if score >= bestScore && bestScore > 0 {
                        Text("You set a new best score!")
                            .font(.subheadline)
                            .foregroundColor(Color("AccentCyan"))
                    }
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Your Score")
                                .font(.caption)
                                .foregroundColor(Color("TextSecondary"))
                            Text("\(score)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(Color("TextPrimary"))
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Best Score")
                                .font(.caption)
                                .foregroundColor(Color("TextSecondary"))
                            Text("\(bestScore)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(Color("AccentCyan"))
                        }
                    }
                    .padding(20)
                    .background(Color("CardBackground"))
                    .cornerRadius(16)
                    
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "sparkles")
                                .font(.system(size: 24))
                                .foregroundColor(Color("HighlightGlow"))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Rewards Earned")
                                    .font(.caption)
                                    .foregroundColor(Color("TextSecondary"))
                                Text("\(animateReward ? rewardAmount : 0) \(rewardType)")
                                    .font(.headline)
                                    .foregroundColor(Color("HighlightGlow"))
                            }
                            
                            Spacer()
                        }
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color("SecondaryBackground"))
                                    .frame(height: 8)
                                
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color("AccentBlue"), Color("AccentCyan")],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: animateReward ? geometry.size.width : 0, height: 8)
                            }
                        }
                        .frame(height: 8)
                    }
                    .padding(20)
                    .background(Color("CardBackground"))
                    .cornerRadius(16)
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 30)
                
                Spacer()
                
                VStack(spacing: 12) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Play Again")
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
                    
                    Button(action: {
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            dismiss()
                        }
                    }) {
                        Text("Back to Games")
                            .font(.subheadline)
                            .foregroundColor(Color("TextSecondary"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color("SecondaryBackground"))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color("HighlightGlow"), lineWidth: 1)
                            )
                            .cornerRadius(12)
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
                .opacity(showContent ? 1 : 0)
            }
            .padding(20)
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                showContent = true
            }
            
            withAnimation(.easeOut(duration: 1.0).delay(0.3)) {
                animateReward = true
            }
            
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                glowOpacity = 1.0
            }
        }
    }
}

