import Foundation
import XCTest
import UIKit
@testable import CharadesTiltGuess

final class DefaultDeckLoaderTests: XCTestCase {
    func testLoadsBundledDefaultDecks() throws {
        let decks = try DefaultDeckLoader().load()

        XCTAssertEqual(decks.count, 17)
        XCTAssertEqual(decks.first?.name, "Tech")
        XCTAssertTrue(decks.allSatisfy { $0.type == .default })
        XCTAssertTrue(decks.allSatisfy { $0.cards.count >= 20 })
        XCTAssertEqual(
            Set(decks.filter { $0.id.hasPrefix("picture-") }.map(\.id)),
            ["picture-animals", "picture-food", "picture-tools"]
        )
    }

    func testPictureDecksHaveValidImages() throws {
        let decks = try DefaultDeckLoader().load()
        let pictureDecks = decks.filter { $0.id.hasPrefix("picture-") }
        
        XCTAssertEqual(pictureDecks.count, 3)
        
        for deck in pictureDecks {
            for card in deck.cards {
                let imageName = try XCTUnwrap(card.imageName, "Missing imageName for \(card.text)")
                XCTAssertFalse(imageName.isEmpty)
                
                let image = UIImage(named: imageName)
                XCTAssertNotNil(image, "Asset not found: \(imageName)")
            }
        }
        
        let standardDecks = decks.filter { !$0.id.hasPrefix("picture-") }
        for deck in standardDecks {
            for card in deck.cards {
                XCTAssertNil(card.imageName, "Standard card should not have image: \(card.text)")
            }
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

    func testMixAndMatchBuildsFreshFiftyCardDeckFromAllDeckTypes() throws {
        let defaultDeck = makeDeck(
            id: "default",
            cards: (0..<35).map { GameWord(id: "default-\($0)", text: "Default \($0)") }
        )
        let customDeck = Deck(
            id: "custom",
            name: "Custom Deck",
            cards: (0..<35).map { GameWord(id: "custom-\($0)", text: "Custom \($0)") }
                + [GameWord(id: "duplicate", text: "  default 0  ")],
            type: .custom,
            color: .pink,
            symbolName: "star"
        )
        var firstGenerator = SeededRandomNumberGenerator(seed: 1)
        var secondGenerator = SeededRandomNumberGenerator(seed: 2)

        let first = try XCTUnwrap(
            MixAndMatchDeckFactory().makeDeck(
                from: [defaultDeck, customDeck],
                using: &firstGenerator
            )
        )
        let second = try XCTUnwrap(
            MixAndMatchDeckFactory().makeDeck(
                from: [defaultDeck, customDeck],
                using: &secondGenerator
            )
        )

        XCTAssertEqual(first.cards.count, 50)
        XCTAssertEqual(Set(first.cards.map { $0.text.lowercased() }).count, 50)
        XCTAssertTrue(first.cards.contains { $0.id.hasPrefix("default-") })
        XCTAssertTrue(first.cards.contains { $0.id.hasPrefix("custom-") })
        XCTAssertNotEqual(first.cards.map(\.id), second.cards.map(\.id))
        XCTAssertEqual(first.name, "Mix & Match")
        XCTAssertEqual(first.type, .custom)
    }

    func testMixAndMatchRemovesEquivalentWordsBeforeShuffling() throws {
        let firstDeck = makeDeck(
            id: "first",
            cards: [GameWord(id: "first-cafe", text: "Café")]
        )
        let secondDeck = makeDeck(
            id: "second",
            cards: [GameWord(id: "second-cafe", text: "  cafe  ")]
        )
        var generator = SeededRandomNumberGenerator(seed: 1)

        let deck = try XCTUnwrap(
            MixAndMatchDeckFactory().makeDeck(
                from: [firstDeck, secondDeck],
                using: &generator
            )
        )

        XCTAssertEqual(deck.cards.count, 1)
        XCTAssertEqual(
            MixAndMatchDeckFactory().availableCardCount(from: [firstDeck, secondDeck]),
            1
        )
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

private struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1
        return state
    }
}
