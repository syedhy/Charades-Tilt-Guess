import XCTest
@testable import CharadesTiltGuess

final class CharadesTiltGuessTests: XCTestCase {
    func testAppMetadataUsesPlannedName() {
        XCTAssertEqual(AppMetadata.displayName, "Charades: Tilt & Guess")
    }

    func testHomeModesUseMixAndMatchInsteadOfDuplicatePasteAndPlay() {
        XCTAssertTrue(GameMode.homeModes.contains(.mixAndMatch))
        XCTAssertFalse(GameMode.homeModes.contains(.pasteAndPlay))
    }

    @MainActor
    func testRouterPresentsAndFinishesGameFlow() async {
        let router = AppRouter()
        let deck = Deck(
            id: "test-tech",
            name: "Tech",
            cards: [GameWord(id: "test-word", text: "Phone")],
            type: .default,
            color: .mint,
            symbolName: "laptopcomputer"
        )

        router.startGame(deck: deck, duration: 60)
        XCTAssertEqual(router.activeGame?.configuration.deck, deck)

        let result = RoundResult(deck: deck, duration: 60, correctWords: [], passedWords: [])
        router.finishGame(result: result)
        XCTAssertEqual(router.path.count, 0)

        try? await Task.sleep(for: .milliseconds(420))
        XCTAssertNil(router.activeGame)
        XCTAssertEqual(router.path.count, 1)
    }

    @MainActor
    func testTeamMatchAlternatesTeamsAndEndsAfterBothTeamsPlayEveryRound() {
        let deck = Deck(
            id: "team-deck",
            name: "Team Deck",
            cards: (1...3).map { GameWord(id: "word-\($0)", text: "Word \($0)") },
            type: .default,
            color: .mint,
            symbolName: "person.2.fill"
        )
        let customTeams = [
            TeamInfo(id: 1, name: "Tigers", icon: "🐅", color: .orange),
            TeamInfo(id: 2, name: "Lions", icon: "🦁", color: .yellow)
        ]
        let state = TeamMatchState(
            numberOfTeams: 2,
            playersPerTeam: 1,
            sourceDecks: [deck],
            duration: 60,
            customTeams: customTeams
        )

        state.recordResult(
            RoundResult(
                deck: deck,
                duration: 60,
                correctWords: Array(deck.cards.prefix(2)),
                passedWords: [],
                mode: .teamVsTeam
            )
        )

        XCTAssertEqual(state.team1Score, 2)
        XCTAssertEqual(state.currentTeam, 2)
        XCTAssertFalse(state.isGameOver)

        state.recordResult(
            RoundResult(
                deck: deck,
                duration: 60,
                correctWords: Array(deck.cards.prefix(1)),
                passedWords: [],
                mode: .teamVsTeam
            )
        )

        XCTAssertEqual(state.team2Score, 1)
        XCTAssertEqual(state.currentRound, 2)
        XCTAssertTrue(state.isGameOver)
        XCTAssertEqual(state.winnerText, "🐅 Tigers Win!")
    }
}
