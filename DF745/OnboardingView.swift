import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var statsStore: GameStatsStore
    @State private var currentPage = 0
    @State private var floatingOffset1: CGFloat = 0
    @State private var floatingOffset2: CGFloat = 0
    @State private var glowOpacity: Double = 0.5
    
    let pages = [
        OnboardingPage(
            title: "Sharpen Your Reactions",
            description: "Train your reflexes with fast-paced neon challenges that demand split-second decisions.",
            illustration: AnyView(ReactionIllustration())
        ),
        OnboardingPage(
            title: "Trust Your Streak",
            description: "Build momentum through consistent performance and watch your focus level rise.",
            illustration: AnyView(StreakIllustration())
        ),
        OnboardingPage(
            title: "Master Quick Choices",
            description: "Balance risk and reward as you make instant decisions under pressure.",
            illustration: AnyView(ChoiceIllustration())
        )
    ]
    
    var body: some View {
        ZStack {
            Color("PrimaryBackground")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                
                VStack(spacing: 16) {
                    if currentPage < pages.count - 1 {
                        HStack(spacing: 16) {
                            Button(action: {
                                statsStore.hasCompletedOnboarding = true
                            }) {
                                Text("Skip")
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
                            
                            Button(action: {
                                withAnimation {
                                    currentPage += 1
                                }
                            }) {
                                Text("Next")
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
                        .padding(.horizontal, 24)
                    } else {
                        Button(action: {
                            statsStore.hasCompletedOnboarding = true
                        }) {
                            Text("Start Playing")
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
                        .padding(.horizontal, 24)
                    }
                }
                .padding(.bottom, 32)
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
            floatingOffset1 = 20
        }
        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
            floatingOffset2 = -15
        }
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            glowOpacity = 1.0
        }
    }
}

struct OnboardingPage {
    let title: String
    let description: String
    let illustration: AnyView
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    @State private var isVisible = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            page.illustration
                .frame(height: 280)
                .opacity(isVisible ? 1 : 0)
                .offset(y: isVisible ? 0 : 30)
            
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color("TextPrimary"))
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.body)
                    .foregroundColor(Color("TextSecondary"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 20)
            
            Spacer()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                isVisible = true
            }
        }
    }
}

struct ReactionIllustration: View {
    @State private var pulseScale: CGFloat = 1.0
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color("AccentBlue").opacity(0.3), Color("AccentCyan").opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 180, height: 180)
                .scaleEffect(pulseScale)
            
            ForEach(0..<6) { index in
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color("AccentCyan"))
                    .frame(width: 40, height: 40)
                    .offset(x: 70)
                    .rotationEffect(.degrees(Double(index) * 60 + rotationAngle))
            }
            
            Circle()
                .fill(Color("HighlightGlow"))
                .frame(width: 60, height: 60)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                pulseScale = 1.2
            }
            withAnimation(.linear(duration: 8.0).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
        }
    }
}

struct StreakIllustration: View {
    @State private var barHeights: [CGFloat] = [0.3, 0.5, 0.7, 0.9, 1.0]
    @State private var glowOpacity: Double = 0.5
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [Color("SecondaryBackground"), Color("CardBackground")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 280, height: 200)
            
            HStack(spacing: 16) {
                ForEach(0..<5) { index in
                    VStack {
                        Spacer()
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(
                                    colors: [Color("AccentBlue"), Color("AccentCyan")],
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                            .frame(width: 32, height: 120 * barHeights[index])
                            .shadow(color: Color("HighlightGlow").opacity(glowOpacity), radius: 10)
                    }
                    .frame(height: 120)
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                barHeights = [0.4, 0.6, 0.8, 0.95, 0.7]
            }
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                glowOpacity = 1.0
            }
        }
    }
}

struct ChoiceIllustration: View {
    @State private var selectedPath: Int? = nil
    @State private var glowOpacity: Double = 0.5
    @State private var animationTimer: Timer? = nil
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                ForEach(0..<3) { row in
                    HStack(spacing: 20) {
                        ForEach(0..<3) { col in
                            let index = row * 3 + col
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedPath == index ? Color("AccentCyan") : Color("CardBackground"))
                                .frame(width: 60, height: 60)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color("HighlightGlow"), lineWidth: 2)
                                )
                                .shadow(
                                    color: selectedPath == index ? Color("AccentCyan").opacity(glowOpacity) : .clear,
                                    radius: 15
                                )
                        }
                    }
                }
            }
        }
        .onAppear {
            startPathAnimation()
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                glowOpacity = 1.0
            }
        }
        .onDisappear {
            animationTimer?.invalidate()
            animationTimer = nil
        }
    }
    
    private func startPathAnimation() {
        animationTimer?.invalidate()
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                selectedPath = Int.random(in: 0..<9)
            }
        }
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}


