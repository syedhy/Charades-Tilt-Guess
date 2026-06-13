import Foundation

struct GameEngine {
    private(set) var session: GameSession

    init(
        deck: Deck,
        duration: Int,
        shuffledWords: [GameWord]? = nil
    ) {
        session = GameSession(
            deck: deck,
            duration: duration,
            words: shuffledWords ?? deck.cards.shuffled(),
            currentIndex: 0,
            correctWords: [],
            passedWords: []
        )
    }

    var currentWord: GameWord? {
        session.currentWord
    }

    mutating func markCurrentWord(_ status: WordStatus) -> RoundResult? {
        guard let word = session.currentWord else {
            return finishRound()
        }

        switch status {
        case .correct:
            session.correctWords.append(word)
        case .passed:
            session.passedWords.append(word)
        }

        session.currentIndex += 1

        guard session.isExhausted else {
            return nil
        }

        return finishRound()
    }

    func finishRound() -> RoundResult {
        RoundResult(
            deck: session.deck,
            duration: session.duration,
            correctWords: session.correctWords,
            passedWords: session.passedWords
        )
    }
}
