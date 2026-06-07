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

        XCTAssertFalse(viewModel.canSave)
        XCTAssertNil(viewModel.saveDeck())
        XCTAssertEqual(viewModel.saveErrorMessage, "Give your deck a name first.")
    }

    func testSavesCustomDeckWithTrimmedNameAndSelectedColor() throws {
        let store = makeCustomStore()
        let deckStore = DeckStore(customDeckStore: store)
        let viewModel = DeckEditorViewModel(
            deckStore: deckStore,
            idProvider: { "custom-test-id" },
            dateProvider: { Date(timeIntervalSince1970: 100) }
        )

        viewModel.deckName = "  Family Night  "
        viewModel.selectedColor = .coral

        let savedDeck = try XCTUnwrap(viewModel.saveDeck())

        XCTAssertEqual(savedDeck.id, "custom-test-id")
        XCTAssertEqual(savedDeck.name, "Family Night")
        XCTAssertEqual(savedDeck.type, .custom)
        XCTAssertEqual(savedDeck.color, .coral)
        XCTAssertEqual(savedDeck.cards, [])
        XCTAssertNil(viewModel.saveErrorMessage)
        XCTAssertEqual(try store.loadDecks(), [savedDeck])
    }

    func testRejectsOverLimitDeckName() {
        let viewModel = makeViewModel()
        viewModel.deckName = String(repeating: "A", count: DeckEditorViewModel.maxNameLength + 1)

        XCTAssertFalse(viewModel.canSave)
    }

    private func makeViewModel() -> DeckEditorViewModel {
        DeckEditorViewModel(deckStore: DeckStore(customDeckStore: makeCustomStore()))
    }

    private func makeCustomStore() -> CustomDeckStore {
        CustomDeckStore(fileURL: tempDirectory.appendingPathComponent("CustomDecks.json"))
    }
}
