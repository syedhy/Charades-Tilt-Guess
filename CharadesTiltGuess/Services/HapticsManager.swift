import UIKit

final class HapticsManager {
    static let shared = HapticsManager()

    func play(_ status: WordStatus) {
        switch status {
        case .correct:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .passed:
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        }
    }

    func playRoundFinished() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
