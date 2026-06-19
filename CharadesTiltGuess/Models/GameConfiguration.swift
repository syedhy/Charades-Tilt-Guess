import Foundation

struct GameConfiguration: Hashable, Identifiable {
    let id: UUID
    let mode: GameMode
    let deck: Deck
    let duration: Int?
    let hiddenDuration: Int?
    let isTemporaryDeck: Bool
    let sourceDeckIDs: Set<String>

    init(
        id: UUID = UUID(),
        mode: GameMode,
        deck: Deck,
        duration: Int?,
        hiddenDuration: Int? = nil,
        isTemporaryDeck: Bool = false,
        sourceDeckIDs: Set<String> = []
    ) {
        self.id = id
        self.mode = mode
        self.deck = deck
        self.duration = duration
        self.hiddenDuration = hiddenDuration
        self.isTemporaryDeck = isTemporaryDeck
        self.sourceDeckIDs = sourceDeckIDs
    }

    var activeDuration: Int? {
        hiddenDuration ?? duration
    }

    var usesTimer: Bool {
        activeDuration != nil
    }

    var hidesTimer: Bool {
        mode == .hotPotato
    }

    var repeatsWhenDeckExhausted: Bool {
        switch mode {
        case .normal, .pasteAndPlay, .mixAndMatch, .infinite, .hotPotato, .challengeCards, .wikipedia:
            return false
        }
    }

    var usesChallenges: Bool {
        mode == .challengeCards
    }

    var displayDuration: Int {
        activeDuration ?? 0
    }

    static func normal(deck: Deck, duration: Int) -> GameConfiguration {
        GameConfiguration(mode: .normal, deck: deck, duration: duration)
    }

    static func pasteAndPlay(deck: Deck, duration: Int) -> GameConfiguration {
        GameConfiguration(mode: .pasteAndPlay, deck: deck, duration: duration, isTemporaryDeck: true)
    }

    static func mixAndMatch(
        deck: Deck,
        duration: Int,
        sourceDeckIDs: Set<String>
    ) -> GameConfiguration {
        GameConfiguration(
            mode: .mixAndMatch,
            deck: deck,
            duration: duration,
            isTemporaryDeck: true,
            sourceDeckIDs: sourceDeckIDs
        )
    }

    static func infinite(deck: Deck) -> GameConfiguration {
        GameConfiguration(mode: .infinite, deck: deck, duration: nil)
    }

    static func hotPotato(deck: Deck, hiddenDuration: Int) -> GameConfiguration {
        GameConfiguration(mode: .hotPotato, deck: deck, duration: nil, hiddenDuration: hiddenDuration)
    }

    static func challengeCards(deck: Deck, duration: Int) -> GameConfiguration {
        GameConfiguration(mode: .challengeCards, deck: deck, duration: duration)
    }

    static func wikipedia(deck: Deck, duration: Int) -> GameConfiguration {
        GameConfiguration(mode: .wikipedia, deck: deck, duration: duration, isTemporaryDeck: true)
    }
}

struct RoundAttempt: Hashable, Identifiable {
    let id: String
    let sequence: Int
    let word: GameWord
    let status: WordStatus
    let challenge: ChallengeCard?

    init(sequence: Int, word: GameWord, status: WordStatus, challenge: ChallengeCard?) {
        self.sequence = sequence
        self.word = word
        self.status = status
        self.challenge = challenge
        self.id = "\(sequence)-\(word.id)-\(status.rawValue)"
    }
}
