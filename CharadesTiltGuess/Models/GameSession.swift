import Foundation

struct GameSession: Hashable {
    let deck: Deck
    let duration: Int
    let words: [GameWord]
    var currentIndex: Int
    var correctWords: [GameWord]
    var passedWords: [GameWord]

    var currentWord: GameWord? {
        guard currentIndex < words.count else { return nil }
        return words[currentIndex]
    }

    var score: Int {
        correctWords.count
    }

    var totalAttempted: Int {
        correctWords.count + passedWords.count
    }

    var isExhausted: Bool {
        currentWord == nil
    }
}
