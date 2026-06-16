import XCTest
@testable import CharadesTiltGuess

final class CardRotationStoreTests: XCTestCase {
    private var userDefaults: UserDefaults!
    private var suiteName: String!

    override func setUpWithError() throws {
        try super.setUpWithError()
        suiteName = "CardRotationStoreTests-\(UUID().uuidString)"
        userDefaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        userDefaults.removePersistentDomain(forName: suiteName)
    }

    override func tearDownWithError() throws {
        if let suiteName {
            userDefaults?.removePersistentDomain(forName: suiteName)
        }

        userDefaults = nil
        suiteName = nil
        try super.tearDownWithError()
    }

    func testOrdersUnseenCardsBeforeSeenCards() {
        let deck = makeDeck()
        let store = CardRotationStore(userDefaults: userDefaults)

        store.recordSeenCards([deck.cards[0], deck.cards[1]], for: deck)

        let ordered = store.orderedCards(for: deck)
        XCTAssertEqual(Set(ordered.prefix(2).map(\.id)), Set(["three", "four"]))
    }

    func testResetsCycleAfterEveryCardHasBeenSeen() {
        let deck = makeDeck()
        let store = CardRotationStore(userDefaults: userDefaults)

        store.recordSeenCards(deck.cards, for: deck)

        XCTAssertEqual(store.loadState().seenWordIDsByDeckID[deck.id], [])
        XCTAssertEqual(Set(store.orderedCards(for: deck)), Set(deck.cards))
    }

    private func makeDeck() -> Deck {
        Deck(
            id: "rotation-deck",
            name: "Rotation",
            cards: [
                GameWord(id: "one", text: "One"),
                GameWord(id: "two", text: "Two"),
                GameWord(id: "three", text: "Three"),
                GameWord(id: "four", text: "Four")
            ],
            type: .default,
            color: .mint,
            symbolName: "rectangle.stack"
        )
    }
}
