import Foundation
import SwiftUI
import Combine

class GameStatsStore: ObservableObject {
    let objectWillChange = PassthroughSubject<Void, Never>()
    
    @AppStorage("totalSessionsPlayed") var totalSessionsPlayed: Int = 0 {
        didSet { objectWillChange.send() }
    }
    @AppStorage("totalFocusShards") var totalFocusShards: Int = 0 {
        didSet { objectWillChange.send() }
    }
    @AppStorage("totalPatternFragments") var totalPatternFragments: Int = 0 {
        didSet { objectWillChange.send() }
    }
    @AppStorage("totalEnergyOrbs") var totalEnergyOrbs: Int = 0 {
        didSet { objectWillChange.send() }
    }
    
    @AppStorage("bestNeonTapRushScore") var bestNeonTapRushScore: Int = 0 {
        didSet { objectWillChange.send() }
    }
    @AppStorage("bestPulsePatternTrailLength") var bestPulsePatternTrailLength: Int = 0 {
        didSet { objectWillChange.send() }
    }
    @AppStorage("bestRiskLineDepth") var bestRiskLineDepth: Int = 0 {
        didSet { objectWillChange.send() }
    }
    
    @AppStorage("lastSessionScore") var lastSessionScore: Int = 0 {
        didSet { objectWillChange.send() }
    }
    @AppStorage("lastSessionType") var lastSessionType: String = "" {
        didSet { objectWillChange.send() }
    }
    
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false {
        didSet { objectWillChange.send() }
    }
    
    var streakLevel: String {
        let total = totalFocusShards + totalPatternFragments + totalEnergyOrbs
        if total < 10 {
            return "Beginner"
        } else if total < 50 {
            return "Focused"
        } else if total < 150 {
            return "Sharp"
        } else if total < 300 {
            return "Elite"
        } else {
            return "Master"
        }
    }
    
    var progressToNextLevel: Double {
        let total = totalFocusShards + totalPatternFragments + totalEnergyOrbs
        if total < 10 {
            return Double(total) / 10.0
        } else if total < 50 {
            return Double(total - 10) / 40.0
        } else if total < 150 {
            return Double(total - 50) / 100.0
        } else if total < 300 {
            return Double(total - 150) / 150.0
        } else {
            return 1.0
        }
    }
    
    func recordSession(type: String, score: Int, reward: Int) {
        totalSessionsPlayed += 1
        lastSessionScore = score
        lastSessionType = type
        
        switch type {
        case "NeonTapRush":
            totalFocusShards += reward
            if score > bestNeonTapRushScore {
                bestNeonTapRushScore = score
            }
        case "PulsePatternTrail":
            totalPatternFragments += reward
            if score > bestPulsePatternTrailLength {
                bestPulsePatternTrailLength = score
            }
        case "RiskLinePath":
            totalEnergyOrbs += reward
            if score > bestRiskLineDepth {
                bestRiskLineDepth = score
            }
        default:
            break
        }
    }
    
    func resetAllProgress() {
        totalSessionsPlayed = 0
        totalFocusShards = 0
        totalPatternFragments = 0
        totalEnergyOrbs = 0
        bestNeonTapRushScore = 0
        bestPulsePatternTrailLength = 0
        bestRiskLineDepth = 0
        lastSessionScore = 0
        lastSessionType = ""
    }
}

