import Foundation

struct RoundResult: Hashable {
    let deck: Deck
    let duration: Int
    let correctWords: [GameWord]
    let passedWords: [GameWord]

    var finalScore: Int {
        correctWords.count
    }

    var totalAttempted: Int {
        correctWords.count + passedWords.count
    }
}
