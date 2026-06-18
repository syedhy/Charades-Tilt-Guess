import XCTest
@testable import CharadesTiltGuess

final class ClipboardImportServiceTests: XCTestCase {
    func testParsesNewlinesCommasAndNumberedLists() {
        let service = ClipboardImportService()
        let preview = service.previewCards(
            from: """
            1. Pizza, 2. Burger
            - Ice Cream
            * Football
            3) Spider-Man
            """
        )

        XCTAssertEqual(preview.cards, ["Pizza", "Burger", "Ice Cream", "Football", "Spider-Man"])
    }

    func testSkipsDuplicatesAcrossFormats() {
        let service = ClipboardImportService()
        let preview = service.previewCards(from: "Pizza, pizza\n1. PIZZA\nBurger")

        XCTAssertEqual(preview.cards, ["Pizza", "Burger"])
        XCTAssertEqual(preview.duplicateCount, 2)
    }

    func testReportsBlankLinesAccurately() {
        let service = ClipboardImportService()
        let preview = service.previewCards(from: "Pizza\n\nBurger\n")

        XCTAssertEqual(preview.blankLineCount, 2)
        XCTAssertTrue(preview.summaryMessages.contains("2 blank lines were ignored."))
    }

    func testRejectsCardsLongerThanThirtyCharactersByDefault() {
        let service = ClipboardImportService()
        let longCard = String(repeating: "A", count: 31)
        let preview = service.previewCards(from: "Pizza\n\(longCard)")

        XCTAssertEqual(preview.cards, ["Pizza"])
        XCTAssertEqual(preview.tooLongLines, [longCard])
        XCTAssertTrue(preview.summaryMessages.contains("1 card is over 30 characters."))
    }
}
