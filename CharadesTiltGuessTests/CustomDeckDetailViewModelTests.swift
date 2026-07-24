import Foundation
import XCTest
@testable import CharadesTiltGuess

@MainActor
final class CustomDeckDetailViewModelTests: XCTestCase {
    private var tempDirectory: URL!

    override func setUpWithError() throws {
        try super.setUpWithError()
        tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("CustomDeckDetailViewModelTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        if let tempDirectory {
            try? FileManager.default.removeItem(at: tempDirectory)
        }
        tempDirectory = nil
        try super.tearDownWithError()
    }

    func testAddCardTrimsTextAndRejectsDuplicates() {
        var nextID = 1
        let viewModel = makeViewModel(wordIDProvider: {
            defer { nextID += 1 }
            return "word-\(nextID)"
        })

        XCTAssertTrue(viewModel.addCard(text: "  Pizza  "))
        XCTAssertEqual(viewModel.draftCards.first, GameWord(id: "word-1", text: "Pizza"))

        XCTAssertTrue(viewModel.addCard(text: "Burger"))
        XCTAssertEqual(viewModel.draftCards.map(\.text), ["Burger", "Pizza"])

        XCTAssertFalse(viewModel.addCard(text: "pizza"))
        XCTAssertEqual(viewModel.cardErrorMessage, "That card is already in this deck.")
    }

    func testImportCardsSplitsNewlinesAndSkipsProblemLines() {
        var nextID = 10
        let viewModel = makeViewModel(
            cards: [GameWord(id: "existing", text: "Existing Card")],
            wordIDProvider: {
                defer { nextID += 1 }
                return "word-\(nextID)"
            }
        )

        let longLine = String(repeating: "A", count: CustomDeckDetailViewModel.maxCardTextLength + 1)
        let pastedText = """
        Apple

          Football
        apple
        \(longLine)
        Shah Rukh Khan
        """

        viewModel.refreshImportPreview(from: pastedText)

        XCTAssertEqual(viewModel.importPreview.cards, ["Apple", "Football", "Shah Rukh Khan"])
        XCTAssertEqual(viewModel.importPreview.blankLineCount, 1)
        XCTAssertEqual(viewModel.importPreview.duplicateCount, 1)
        XCTAssertEqual(viewModel.importPreview.tooLongLines, [longLine])

        XCTAssertEqual(viewModel.importCards(from: pastedText), 3)
        XCTAssertEqual(
            viewModel.draftCards,
            [
                GameWord(id: "word-10", text: "Apple"),
                GameWord(id: "word-11", text: "Football"),
                GameWord(id: "word-12", text: "Shah Rukh Khan"),
                GameWord(id: "existing", text: "Existing Card")
            ]
        )
    }

    func testAddCardRejectsCardsBeyondCustomDeckLimit() {
        let viewModel = makeViewModel(cards: makeCards(count: CustomDeckDetailViewModel.maxCustomDeckCardCount))

        XCTAssertFalse(viewModel.addCard(text: "One Too Many"))
        XCTAssertEqual(viewModel.cardErrorMessage, "Custom decks can have up to \(CustomDeckDetailViewModel.maxCustomDeckCardCount) cards.")
        XCTAssertEqual(viewModel.draftCards.count, CustomDeckDetailViewModel.maxCustomDeckCardCount)
    }

    func testAddCardRejectsOverLongCards() {
        let viewModel = makeViewModel()
        let longCard = String(repeating: "A", count: CustomDeckDetailViewModel.maxCardTextLength + 1)

        XCTAssertFalse(viewModel.addCard(text: longCard))
        XCTAssertEqual(viewModel.cardErrorMessage, "Keep cards under \(CustomDeckDetailViewModel.maxCardTextLength) characters.")
    }

    func testImportCardsOnlyUsesRemainingCustomDeckSlots() {
        var nextID = 1
        let existingCards = makeCards(count: CustomDeckDetailViewModel.maxCustomDeckCardCount - 1)
        let viewModel = makeViewModel(cards: existingCards) {
            defer { nextID += 1 }
            return "new-\(nextID)"
        }

        let pastedText = """
        Apple
        River
        Mountain
        """

        viewModel.refreshImportPreview(from: pastedText)

        XCTAssertEqual(viewModel.importPreview.cards, ["Apple"])
        XCTAssertEqual(viewModel.importPreview.overDeckLimitCount, 2)
        XCTAssertEqual(
            viewModel.importPreview.summaryMessages.last,
            "2 cards were skipped because custom decks are limited to \(CustomDeckDetailViewModel.maxCustomDeckCardCount) cards."
        )

        XCTAssertEqual(viewModel.importCards(from: pastedText), 1)
        XCTAssertEqual(viewModel.draftCards.first, GameWord(id: "new-1", text: "Apple"))
        XCTAssertEqual(viewModel.draftCards.count, CustomDeckDetailViewModel.maxCustomDeckCardCount)
    }

    func testSaveDraftRejectsDeckBeyondCustomDeckLimit() {
        let tooManyCards = makeCards(count: CustomDeckDetailViewModel.maxCustomDeckCardCount + 1)
        let viewModel = makeViewModel(cards: tooManyCards)

        XCTAssertNil(viewModel.saveDraft())
        XCTAssertEqual(viewModel.saveErrorMessage, "Custom decks can have up to \(CustomDeckDetailViewModel.maxCustomDeckCardCount) cards.")
    }

    func testSaveDraftPersistsEditedDeck() throws {
        let store = makeCustomStore()
        let deckStore = DeckStore(customDeckStore: store)
        let initialDeck = makeDeck()
        try store.saveDecks([initialDeck])
        let viewModel = CustomDeckDetailViewModel(
            deck: initialDeck,
            deckStore: deckStore,
            wordIDProvider: { "word-new" },
            dateProvider: { Date(timeIntervalSince1970: 200) }
        )

        viewModel.draftName = "  Games Night  "
        viewModel.draftColor = .purple
        XCTAssertTrue(viewModel.addCard(text: "Mario Kart"))

        let savedDeck = try XCTUnwrap(viewModel.saveDraft())

        XCTAssertEqual(savedDeck.name, "Games Night")
        XCTAssertEqual(savedDeck.color, .purple)
        XCTAssertEqual(savedDeck.cards, [GameWord(id: "word-new", text: "Mario Kart")])
        XCTAssertEqual(savedDeck.updatedDate, Date(timeIntervalSince1970: 200))
        XCTAssertEqual(try store.loadDecks(), [savedDeck])
    }

    func testDeleteDeckRemovesItFromStorage() throws {
        let store = makeCustomStore()
        let initialDeck = makeDeck()
        try store.saveDecks([initialDeck])
        let viewModel = CustomDeckDetailViewModel(
            deck: initialDeck,
            deckStore: DeckStore(customDeckStore: store)
        )

        XCTAssertTrue(viewModel.deleteDeck())
        XCTAssertEqual(try store.loadDecks(), [])
    }

    func testEmojiDeckRequiresEmojiAndMeaning() {
        let emojiDeck = Deck(
            id: "emoji-custom-test",
            name: "Emoji Test",
            description: nil,
            cards: [],
            type: .custom,
            color: .yellow,
            symbolName: "face.smiling.fill",
            isEmoji: true,
            createdDate: Date(),
            updatedDate: Date()
        )
        let viewModel = CustomDeckDetailViewModel(deck: emojiDeck)

        XCTAssertFalse(viewModel.addCard(text: "No Emoji Here", meaning: "Batman"))
        XCTAssertEqual(viewModel.cardErrorMessage, "Emoji cards must contain at least one emoji.")

        XCTAssertFalse(viewModel.addCard(text: "🦇👨", meaning: nil))
        XCTAssertEqual(viewModel.cardErrorMessage, "Emoji cards require a meaning/answer.")

        XCTAssertTrue(viewModel.addCard(text: "🦇👨", meaning: "Batman"))
        XCTAssertEqual(viewModel.draftCards.first?.meaning, "Batman")
    }

    private func makeViewModel(
        cards: [GameWord] = [],
        wordIDProvider: @escaping () -> String = { "word-test" }
    ) -> CustomDeckDetailViewModel {
        CustomDeckDetailViewModel(deck: makeDeck(cards: cards), wordIDProvider: wordIDProvider)
    }

    private func makeCustomStore() -> CustomDeckStore {
        CustomDeckStore(fileURL: tempDirectory.appendingPathComponent("CustomDecks.json"))
    }

    private func makeDeck(cards: [GameWord] = []) -> Deck {
        Deck(
            id: "custom-games",
            name: "Games",
            description: nil,
            cards: cards,
            type: .custom,
            color: .mint,
            symbolName: "rectangle.stack",
            createdDate: Date(timeIntervalSince1970: 100),
            updatedDate: Date(timeIntervalSince1970: 100)
        )
    }

    private func makeCards(count: Int) -> [GameWord] {
        (1...count).map { index in
            GameWord(id: "word-\(index)", text: "Card \(index)")
        }
    }
}
