import XCTest
@testable import CharadesTiltGuess

final class CharadesTiltGuessTests: XCTestCase {
    func testAppMetadataUsesPlannedName() {
        XCTAssertEqual(AppMetadata.displayName, "Charades: Tilt & Guess")
    }

    @MainActor
    func testRouterPresentsAndFinishesGameFlow() {
        let router = AppRouter()

        router.startGame(deckName: "Tech")
        XCTAssertEqual(router.activeGame?.deckName, "Tech")

        router.finishGame(deckName: "Tech")
        XCTAssertNil(router.activeGame)

        router.handleGameDismissal()
        XCTAssertEqual(router.path.count, 1)
    }
}
