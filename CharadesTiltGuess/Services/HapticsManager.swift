import UIKit

final class HapticsManager {
    static let shared = HapticsManager()

    func play(_ status: WordStatus) {
        switch status {
        case .correct:
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred(intensity: 0.9)
        case .passed:
            UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.72)
        }
    }

    func playPreparationReady() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred(intensity: 0.8)
    }

    func playCountdownTick(urgency: Double = 0.45) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: max(0.25, min(urgency, 1.0)))
    }

    func playCountdownStart() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred(intensity: 0.82)
    }

    func playPause() {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.55)
    }

    func playTimeUp() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    func playRoundFinished() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
