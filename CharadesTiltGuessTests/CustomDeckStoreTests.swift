import Foundation
import XCTest
@testable import CharadesTiltGuess

final class CustomDeckStoreTests: XCTestCase {
    private var tempDirectory: URL!

    override func setUpWithError() throws {
        try super.setUpWithError()
        tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("CharadesTiltGuessTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        if let tempDirectory {
            try? FileManager.default.removeItem(at: tempDirectory)
        }
        tempDirectory = nil
        try super.tearDownWithError()
    }

    func testMissingCustomDeckFileLoadsEmptyDeckList() throws {
        let store = makeStore()

        XCTAssertEqual(try store.loadDecks(), [])
    }

    func testSavesAndLoadsCustomDecks() throws {
        let store = makeStore()
        let deck = makeCustomDeck(id: "my-deck", name: "Family Night")

        try store.saveDecks([deck])

        XCTAssertEqual(try store.loadDecks(), [deck])
    }

    func testUpsertAddsAndReplacesDeck() throws {
        let store = makeStore()
        let firstDeck = makeCustomDeck(id: "my-deck", name: "Original")
        let updatedDeck = makeCustomDeck(id: "my-deck", name: "Updated")

        try store.upsert(firstDeck)
        try store.upsert(updatedDeck)

        XCTAssertEqual(try store.loadDecks(), [updatedDeck])
    }

    func testDeleteRemovesDeck() throws {
        let store = makeStore()
        let deck = makeCustomDeck(id: "delete-me", name: "Delete Me")

        try store.saveDecks([deck])
        try store.deleteDeck(id: deck.id)

        XCTAssertEqual(try store.loadDecks(), [])
    }

    func testRejectsDefaultDecksInCustomStorage() throws {
        let store = makeStore()
        let deck = Deck(
            id: "default-tech",
            name: "Tech",
            cards: [GameWord(id: "word-1", text: "Phone")],
            type: .default,
            color: .mint,
            symbolName: "laptopcomputer"
        )

        XCTAssertThrowsError(try store.saveDecks([deck])) { error in
            XCTAssertEqual(error as? CustomDeckStoreError, .invalidDeckType("default-tech"))
        }
    }

    func testRejectsBlankDeckName() throws {
        let store = makeStore()
        let deck = makeCustomDeck(id: "blank-name", name: "  ")

        XCTAssertThrowsError(try store.saveDecks([deck])) { error in
            XCTAssertEqual(error as? CustomDeckStoreError, .emptyDeckName("blank-name"))
        }
    }

    func testRejectsDuplicateDeckIDs() throws {
        let store = makeStore()
        let deck = makeCustomDeck(id: "duplicate", name: "One")

        XCTAssertThrowsError(try store.saveDecks([deck, deck])) { error in
            XCTAssertEqual(error as? CustomDeckStoreError, .duplicateDeckID("duplicate"))
        }
    }

    func testMalformedStorageFileThrowsInvalidData() throws {
        let fileURL = tempDirectory.appendingPathComponent("CustomDecks.json")
        try Data("not-json".utf8).write(to: fileURL)
        let store = CustomDeckStore(fileURL: fileURL)

        XCTAssertThrowsError(try store.loadDecks()) { error in
            XCTAssertEqual(error as? CustomDeckStoreError, .invalidData)
        }
    }

    private func makeStore() -> CustomDeckStore {
        CustomDeckStore(fileURL: tempDirectory.appendingPathComponent("CustomDecks.json"))
    }

    private func makeCustomDeck(id: String, name: String) -> Deck {
        Deck(
            id: id,
            name: name,
            description: "A custom test deck",
            cards: [
                GameWord(id: "word-1", text: "Pizza"),
                GameWord(id: "word-2", text: "Football")
            ],
            type: .custom,
            color: .yellow,
            symbolName: "rectangle.stack",
            createdDate: Date(timeIntervalSince1970: 1),
            updatedDate: Date(timeIntervalSince1970: 2)
        )
    }
}
