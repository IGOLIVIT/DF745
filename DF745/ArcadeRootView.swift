import SwiftUI

struct ArcadeRootView: View {
    @StateObject private var statsStore = GameStatsStore()
    
    var body: some View {
        Group {
            if !statsStore.hasCompletedOnboarding {
                OnboardingView()
                    .environmentObject(statsStore)
            } else {
                NeonHubView()
                    .environmentObject(statsStore)
            }
        }
    }
}

#Preview {
    ArcadeRootView()
}


