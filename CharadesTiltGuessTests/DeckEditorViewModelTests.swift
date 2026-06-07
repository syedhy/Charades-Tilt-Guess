import Foundation
import XCTest
@testable import CharadesTiltGuess

@MainActor
final class DeckEditorViewModelTests: XCTestCase {
    private var tempDirectory: URL!

    override func setUpWithError() throws {
        try super.setUpWithError()
        tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("DeckEditorViewModelTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        if let tempDirectory {
            try? FileManager.default.removeItem(at: tempDirectory)
        }
        tempDirectory = nil
        try super.tearDownWithError()
    }

    func testCannotSaveBlankDeckName() {
        let viewModel = makeViewModel()
        viewModel.deckName = "   "
        XCTAssertTrue(viewModel.addCard(text: "Pizza"))

        XCTAssertFalse(viewModel.canSave)
        XCTAssertNil(viewModel.saveDeck())
        XCTAssertEqual(viewModel.saveErrorMessage, "Give your deck a name first.")
    }

    func testCannotSaveWithoutCards() {
        let viewModel = makeViewModel()
        viewModel.deckName = "Family Night"

        XCTAssertFalse(viewModel.canSave)
        XCTAssertNil(viewModel.saveDeck())
        XCTAssertEqual(viewModel.saveErrorMessage, "Add at least one card first.")
    }

    func testSavesCustomDeckWithTrimmedNameAndSelectedColor() throws {
        let store = makeCustomStore()
        let deckStore = DeckStore(customDeckStore: store)
        let viewModel = DeckEditorViewModel(
            deckStore: deckStore,
            idProvider: { "custom-test-id" },
            wordIDProvider: { "word-test-id" },
            dateProvider: { Date(timeIntervalSince1970: 100) }
        )

        viewModel.deckName = "  Family Night  "
        viewModel.selectedColor = .coral
        XCTAssertTrue(viewModel.addCard(text: "  Pizza  "))

        let savedDeck = try XCTUnwrap(viewModel.saveDeck())

        XCTAssertEqual(savedDeck.id, "custom-test-id")
        XCTAssertEqual(savedDeck.name, "Family Night")
        XCTAssertEqual(savedDeck.type, .custom)
        XCTAssertEqual(savedDeck.color, .coral)
        XCTAssertEqual(savedDeck.cards, [GameWord(id: "word-test-id", text: "Pizza")])
        XCTAssertNil(viewModel.saveErrorMessage)
        XCTAssertEqual(try store.loadDecks(), [savedDeck])
    }

    func testRejectsOverLimitDeckName() {
        let viewModel = makeViewModel()
        viewModel.deckName = String(repeating: "A", count: DeckEditorViewModel.maxNameLength + 1)

        XCTAssertFalse(viewModel.canSave)
    }

    func testAddCardTrimsTextAndUpdatesCount() {
        var nextWordID = 0
        let viewModel = DeckEditorViewModel(
            deckStore: DeckStore(customDeckStore: makeCustomStore()),
            wordIDProvider: {
                nextWordID += 1
                return "word-\(nextWordID)"
            }
        )

        XCTAssertTrue(viewModel.addCard(text: "  Spider-Man  "))
        XCTAssertEqual(viewModel.cards, [GameWord(id: "word-1", text: "Spider-Man")])
        XCTAssertEqual(viewModel.cardCountText, "1 prompt")
        XCTAssertNil(viewModel.cardErrorMessage)
    }

    func testRejectsBlankDuplicateAndOverLimitCards() {
        let viewModel = makeViewModel()

        XCTAssertFalse(viewModel.addCard(text: "  "))
        XCTAssertEqual(viewModel.cardErrorMessage, "Type a card first.")

        XCTAssertTrue(viewModel.addCard(text: "Football"))
        XCTAssertFalse(viewModel.addCard(text: " football "))
        XCTAssertEqual(viewModel.cardErrorMessage, "That card is already in this deck.")

        XCTAssertFalse(viewModel.addCard(text: String(repeating: "A", count: DeckEditorViewModel.maxCardTextLength + 1)))
        XCTAssertEqual(viewModel.cardErrorMessage, "Keep cards under \(DeckEditorViewModel.maxCardTextLength) characters.")
    }

    func testDeleteCardRemovesOnlyMatchingCard() {
        var nextWordID = 0
        let viewModel = DeckEditorViewModel(
            deckStore: DeckStore(customDeckStore: makeCustomStore()),
            wordIDProvider: {
                nextWordID += 1
                return "word-\(nextWordID)"
            }
        )

        XCTAssertTrue(viewModel.addCard(text: "Pizza"))
        XCTAssertTrue(viewModel.addCard(text: "Football"))

        viewModel.deleteCard(id: "word-1")

        XCTAssertEqual(viewModel.cards, [GameWord(id: "word-2", text: "Football")])
        XCTAssertEqual(viewModel.cardCountText, "1 prompt")
    }

    private func makeViewModel() -> DeckEditorViewModel {
        DeckEditorViewModel(deckStore: DeckStore(customDeckStore: makeCustomStore()))
    }

    private func makeCustomStore() -> CustomDeckStore {
        CustomDeckStore(fileURL: tempDirectory.appendingPathComponent("CustomDecks.json"))
    }
}
