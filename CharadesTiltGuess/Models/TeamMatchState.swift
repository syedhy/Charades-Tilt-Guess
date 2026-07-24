import Foundation

struct TeamInfo: Identifiable, Hashable, Equatable {
    let id: Int
    var name: String
    var icon: String
    var color: DeckColor
    var score: Int = 0

    static let defaultPresets: [(name: String, icon: String, color: DeckColor)] = [
        ("Tigers", "🐅", .orange),
        ("Lions", "🦁", .yellow),
        ("Rhinos", "🦏", .mint),
        ("Eagles", "🦅", .blue),
        ("Wolves", "🐺", .purple)
    ]
}

final class TeamMatchState: ObservableObject, Identifiable, Hashable, Equatable {
    let id = UUID()

    static func == (lhs: TeamMatchState, rhs: TeamMatchState) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    let sourceDecks: [Deck]
    let numberOfTeams: Int
    let playersPerTeam: Int
    let duration: Int

    @Published var teams: [TeamInfo]
    @Published var currentRound: Int = 1
    @Published var currentTeamIndex: Int = 0
    @Published var currentDeck: Deck?

    // Backward-compatibility properties
    var totalRounds: Int { playersPerTeam }
    var currentTeam: Int { currentTeamIndex + 1 }
    var team1Score: Int { teams.indices.contains(0) ? teams[0].score : 0 }
    var team2Score: Int { teams.indices.contains(1) ? teams[1].score : 0 }

    init(numberOfTeams: Int = 2, playersPerTeam: Int = 4, sourceDecks: [Deck], duration: Int) {
        let clampedTeams = max(2, min(5, numberOfTeams))
        let clampedPlayers = max(1, min(10, playersPerTeam))

        self.numberOfTeams = clampedTeams
        self.playersPerTeam = clampedPlayers
        self.sourceDecks = sourceDecks
        self.duration = duration

        var generatedTeams: [TeamInfo] = []
        for index in 0..<clampedTeams {
            let preset = TeamInfo.defaultPresets[index % TeamInfo.defaultPresets.count]
            generatedTeams.append(
                TeamInfo(
                    id: index + 1,
                    name: preset.name,
                    icon: preset.icon,
                    color: preset.color,
                    score: 0
                )
            )
        }
        self.teams = generatedTeams

        generateDeckForCurrentRound()
    }

    convenience init(sourceDecks: [Deck], totalRounds: Int, duration: Int) {
        self.init(numberOfTeams: 2, playersPerTeam: totalRounds, sourceDecks: sourceDecks, duration: duration)
    }

    var isGameOver: Bool {
        currentRound > playersPerTeam
    }

    var currentTeamInfo: TeamInfo {
        teams.indices.contains(currentTeamIndex) ? teams[currentTeamIndex] : teams[0]
    }

    var leaderboard: [TeamInfo] {
        teams.sorted { $0.score > $1.score }
    }

    var winnerText: String {
        guard let topScore = leaderboard.first?.score else { return "No Winner" }
        let winners = teams.filter { $0.score == topScore }

        if winners.count == 1 {
            return "\(winners[0].icon) \(winners[0].name) Win!"
        } else {
            let names = winners.map { "\($0.icon) \($0.name)" }.joined(separator: " & ")
            return "Tie between \(names)!"
        }
    }

    func recordResult(_ result: RoundResult) {
        let score = result.correctWords.count

        if teams.indices.contains(currentTeamIndex) {
            teams[currentTeamIndex].score += score
        }

        currentTeamIndex += 1
        if currentTeamIndex >= teams.count {
            currentTeamIndex = 0
            currentRound += 1
        }

        if !isGameOver {
            generateDeckForCurrentRound()
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
