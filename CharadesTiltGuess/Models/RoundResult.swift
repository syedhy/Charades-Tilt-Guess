import Foundation

struct RoundResult: Hashable {
    let deck: Deck
    let duration: Int
    let correctWords: [GameWord]
    let passedWords: [GameWord]
    var mode: GameMode = .normal
    var attempts: [RoundAttempt] = []
    var timeUsed: Int = 0
    var wasTimeUp: Bool = false
    var sourceDeckIDs: Set<String> = []

    var finalScore: Int {
        correctWords.count
    }

    var totalAttempted: Int {
        correctWords.count + passedWords.count
    }

    var passCount: Int {
        passedWords.count
    }

    var accuracyPercentage: Int {
        guard totalAttempted > 0 else { return 0 }
        return Int((Double(correctWords.count) / Double(totalAttempted) * 100).rounded())
    }

    var cardsSeen: Int {
        attempts.isEmpty ? totalAttempted : attempts.count
    }

    var bestStreak: Int {
        guard !attempts.isEmpty else { return correctWords.count }

        var current = 0
        var best = 0

        for attempt in attempts {
            if attempt.status == .correct {
                current += 1
                best = max(best, current)
            } else {
                current = 0
            }
        }

        return best
    }

    var longestCorrectStreak: Int {
        bestStreak
    }

    var title: String {

        return wasTimeUp ? "Time up" : "Round complete"
    }

    var subtitle: String {
        return deck.name
    }
}
