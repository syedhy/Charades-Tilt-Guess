import Foundation

struct GameEngine {
    private(set) var session: GameSession
    private let configuration: GameConfiguration
    private let challengeProvider: ChallengeCardProvider

    init(
        deck: Deck,
        duration: Int,
        shuffledWords: [GameWord]? = nil
    ) {
        self.init(
            configuration: .normal(deck: deck, duration: duration),
            orderedWords: shuffledWords
        )
    }

    init(
        configuration: GameConfiguration,
        orderedWords: [GameWord]? = nil,
        challengeProvider: ChallengeCardProvider = ChallengeCardProvider()
    ) {
        self.configuration = configuration
        self.challengeProvider = challengeProvider
        let words = orderedWords ?? configuration.deck.cards.shuffled()
        session = GameSession(
            deck: configuration.deck,
            duration: configuration.displayDuration,
            mode: configuration.mode,
            words: words,
            currentIndex: 0,
            correctWords: [],
            passedWords: [],
            attempts: []
        )
    }

    var currentWord: GameWord? {
        session.currentWord
    }

    var currentChallenge: ChallengeCard? {
        guard configuration.usesChallenges else { return nil }
        return challengeProvider.challenge(forSequence: session.currentIndex + 1)
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

        session.attempts.append(
            RoundAttempt(
                sequence: session.attempts.count + 1,
                word: word,
                status: status,
                challenge: currentChallenge
            )
        )

        session.currentIndex += 1

        if session.isExhausted, configuration.repeatsWhenDeckExhausted {
            session.words = configuration.deck.cards.shuffled()
            session.currentIndex = 0
        }

        guard session.isExhausted else {
            return nil
        }

        return finishRound()
    }

    func finishRound(timeUsed: Int = 0, wasTimeUp: Bool = false) -> RoundResult {
        RoundResult(
            deck: session.deck,
            duration: session.duration,
            correctWords: session.correctWords,
            passedWords: session.passedWords,
            mode: configuration.mode,
            attempts: session.attempts,
            timeUsed: timeUsed,
            wasTimeUp: wasTimeUp
        )
    }
}
