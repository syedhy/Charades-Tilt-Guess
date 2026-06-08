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
        XCTAssertEqual(viewModel.draftCards.last, GameWord(id: "word-1", text: "Pizza"))

        XCTAssertFalse(viewModel.addCard(text: "pizza"))
        XCTAssertEqual(viewModel.cardErrorMessage, "That card is already in this deck.")
    }

    func testImportCardsSplitsNewlinesAndSkipsProblemLines() {
        var nextID = 10
        let viewModel = makeViewModel(wordIDProvider: {
            defer { nextID += 1 }
            return "word-\(nextID)"
        })

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
                GameWord(id: "word-12", text: "Shah Rukh Khan")
            ]
        )
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

    private func makeViewModel(wordIDProvider: @escaping () -> String = { "word-test" }) -> CustomDeckDetailViewModel {
        CustomDeckDetailViewModel(deck: makeDeck(cards: []), wordIDProvider: wordIDProvider)
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
}
