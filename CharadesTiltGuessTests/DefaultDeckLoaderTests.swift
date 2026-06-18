import Foundation
import XCTest
@testable import CharadesTiltGuess

final class DefaultDeckLoaderTests: XCTestCase {
    func testLoadsBundledDefaultDecks() throws {
        let decks = try DefaultDeckLoader().load()

        XCTAssertEqual(decks.count, 16)
        XCTAssertEqual(decks.first?.name, "Tech")
        XCTAssertTrue(decks.allSatisfy { $0.type == .default })
        XCTAssertTrue(decks.allSatisfy { $0.cards.count >= 20 })
    }

    func testMissingResourceThrowsHelpfulError() {
        let loader = DefaultDeckLoader(
            bundle: Bundle(for: Self.self),
            resourceName: "DefinitelyMissingDecks"
        )

        XCTAssertThrowsError(try loader.load()) { error in
            XCTAssertEqual(
                error as? DefaultDeckLoaderError,
                .resourceNotFound("DefinitelyMissingDecks")
            )
        }
    }

    func testRejectsDuplicateDeckIDs() throws {
        let deck = makeDeck(id: "duplicate")
        let data = try JSONEncoder().encode([deck, deck])

        XCTAssertThrowsError(try DefaultDeckLoader().load(from: data)) { error in
            XCTAssertEqual(error as? DefaultDeckLoaderError, .duplicateDeckID("duplicate"))
        }
    }

    func testRejectsEmptyDeck() throws {
        let data = try JSONEncoder().encode([makeDeck(id: "empty", cards: [])])

        XCTAssertThrowsError(try DefaultDeckLoader().load(from: data)) { error in
            XCTAssertEqual(error as? DefaultDeckLoaderError, .emptyDeck("empty"))
        }
    }

    func testRejectsDuplicateWordIDs() throws {
        let word = GameWord(id: "same-word", text: "Phone")
        let data = try JSONEncoder().encode([
            makeDeck(id: "duplicate-words", cards: [word, word])
        ])

        XCTAssertThrowsError(try DefaultDeckLoader().load(from: data)) { error in
            XCTAssertEqual(
                error as? DefaultDeckLoaderError,
                .duplicateWordID(deckID: "duplicate-words", wordID: "same-word")
            )
        }
    }

    func testRejectsMalformedJSON() {
        let data = Data("not-json".utf8)

        XCTAssertThrowsError(try DefaultDeckLoader().load(from: data)) { error in
            XCTAssertEqual(error as? DefaultDeckLoaderError, .invalidData)
        }
    }

    private func makeDeck(
        id: String,
        cards: [GameWord] = [GameWord(id: "word-1", text: "Phone")]
    ) -> Deck {
        Deck(
            id: id,
            name: "Test Deck",
            cards: cards,
            type: .default,
            color: .mint,
            symbolName: "rectangle.stack"
        )
    }
}
