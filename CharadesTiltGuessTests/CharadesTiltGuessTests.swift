import XCTest
@testable import CharadesTiltGuess

final class CharadesTiltGuessTests: XCTestCase {
    func testAppMetadataUsesPlannedName() {
        XCTAssertEqual(AppMetadata.displayName, "Charades: Tilt & Guess")
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
}
