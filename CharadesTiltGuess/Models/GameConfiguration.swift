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
        false
    }

    var repeatsWhenDeckExhausted: Bool {
        switch mode {
        case .normal, .emoji, .pasteAndPlay, .mixAndMatch, .infinite, .wikipedia, .teamVsTeam:
            return false
        }
    }

    var usesChallenges: Bool {
        false
    }

    var displayDuration: Int {
        activeDuration ?? 0
    }

    static func normal(deck: Deck, duration: Int) -> GameConfiguration {
        GameConfiguration(mode: .normal, deck: deck, duration: duration)
    }

    static func emoji(deck: Deck, duration: Int) -> GameConfiguration {
        GameConfiguration(mode: .emoji, deck: deck, duration: duration)
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

    static func wikipedia(deck: Deck, duration: Int) -> GameConfiguration {
        GameConfiguration(mode: .wikipedia, deck: deck, duration: duration, isTemporaryDeck: true)
    }

    static func teamVsTeam(deck: Deck, duration: Int) -> GameConfiguration {
        GameConfiguration(mode: .teamVsTeam, deck: deck, duration: duration)
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
