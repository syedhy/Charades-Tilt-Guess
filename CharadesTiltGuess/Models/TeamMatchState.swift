import Foundation

final class TeamMatchState: ObservableObject, Identifiable, Hashable, Equatable {
    let id = UUID()

    static func == (lhs: TeamMatchState, rhs: TeamMatchState) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    let sourceDecks: [Deck]
    let totalRounds: Int
    let duration: Int

    @Published var currentRound: Int = 1
    @Published var currentTeam: Int = 1

    @Published var team1Score: Int = 0
    @Published var team2Score: Int = 0

    @Published var currentDeck: Deck?

    init(sourceDecks: [Deck], totalRounds: Int, duration: Int) {
        self.sourceDecks = sourceDecks
        self.totalRounds = totalRounds
        self.duration = duration
        generateDeckForCurrentRound()
    }

    var isGameOver: Bool {
        currentRound > totalRounds
    }

    var winnerText: String {
        if team1Score > team2Score {
            return "Team 1 Wins!"
        } else if team2Score > team1Score {
            return "Team 2 Wins!"
        } else {
            return "It's a Tie!"
        }
    }

    func recordResult(_ result: RoundResult) {
        let score = result.correctWords.count

        if currentTeam == 1 {
            team1Score += score
            currentTeam = 2
            shuffleCurrentDeck()
        } else {
            team2Score += score
            currentTeam = 1
            currentRound += 1
            if !isGameOver {
                generateDeckForCurrentRound()
            }
        }
    }

    private func generateDeckForCurrentRound() {
        var allCards = sourceDecks.flatMap { $0.cards }
        allCards.shuffle()

        // Remove duplicates by text, ignoring casing
        var uniqueCards: [GameWord] = []
        var seenTexts = Set<String>()
        for card in allCards {
            let normalized = card.text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            if !seenTexts.contains(normalized) {
                seenTexts.insert(normalized)
                uniqueCards.append(card)
            }
        }

        let selectedCards = Array(uniqueCards.prefix(50))

        currentDeck = Deck(
            id: "teamMatch-\(UUID().uuidString)",
            name: "Team Match Deck",
            cards: selectedCards,
            type: .default,
            color: sourceDecks.first?.color ?? .purple,
            symbolName: "person.2.fill"
        )
    }

    private func shuffleCurrentDeck() {
        guard let oldDeck = currentDeck else { return }
        var shuffledCards = oldDeck.cards
        shuffledCards.shuffle()

        currentDeck = Deck(
            id: "teamMatch-\(UUID().uuidString)",
            name: "Team Match Deck",
            cards: shuffledCards,
            type: .default,
            color: oldDeck.color,
            symbolName: oldDeck.symbolName
        )
    }
}
