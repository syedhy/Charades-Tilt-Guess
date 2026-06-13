import XCTest
@testable import CharadesTiltGuess

final class CharadesTiltGuessTests: XCTestCase {
    func testAppMetadataUsesPlannedName() {
        XCTAssertEqual(AppMetadata.displayName, "Charades: Tilt & Guess")
    }

    @MainActor
    func testRouterPresentsAndFinishesGameFlow() {
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
        XCTAssertEqual(router.activeGame?.deck, deck)

        let result = RoundResult(deck: deck, duration: 60, correctWords: [], passedWords: [])
        router.finishGame(result: result)
        XCTAssertNil(router.activeGame)

        router.handleGameDismissal()
        XCTAssertEqual(router.path.count, 1)
    }
}
