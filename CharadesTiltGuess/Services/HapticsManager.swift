import UIKit

final class HapticsManager {
    static let shared = HapticsManager()

    func play(_ status: WordStatus) {
        switch status {
        case .correct:
            let impact = UIImpactFeedbackGenerator(style: .rigid)
            impact.prepare()
            impact.impactOccurred(intensity: 1.0)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .passed:
            let impact = UIImpactFeedbackGenerator(style: .heavy)
            impact.prepare()
            impact.impactOccurred(intensity: 0.95)
        }
    }

    func playPreparationReady() {
        let impact = UIImpactFeedbackGenerator(style: .heavy)
        impact.prepare()
        impact.impactOccurred(intensity: 0.92)
    }

    func playCountdownTick(urgency: Double = 0.45) {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.prepare()
        impact.impactOccurred(intensity: max(0.55, min(urgency + 0.22, 1.0)))
    }

    func playCountdownStart() {
        let impact = UIImpactFeedbackGenerator(style: .rigid)
        impact.prepare()
        impact.impactOccurred(intensity: 1.0)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    func playPause() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.prepare()
        impact.impactOccurred(intensity: 0.78)
    }

    func playNeutralReturn() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.prepare()
        impact.impactOccurred(intensity: 0.78)
    }

    func playTimeUp() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    func playRoundFinished() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
