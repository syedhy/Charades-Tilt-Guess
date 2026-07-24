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

        let expected = [
            ParsedCard(text: "Pizza", meaning: nil),
            ParsedCard(text: "Burger", meaning: nil),
            ParsedCard(text: "Ice Cream", meaning: nil),
            ParsedCard(text: "Football", meaning: nil),
            ParsedCard(text: "Spider-Man", meaning: nil)
        ]
        XCTAssertEqual(preview.cards, expected)
    }

    func testSkipsDuplicatesAcrossFormats() {
        let service = ClipboardImportService()
        let preview = service.previewCards(from: "Pizza, pizza\n1. PIZZA\nBurger")

        let expected = [
            ParsedCard(text: "Pizza", meaning: nil),
            ParsedCard(text: "Burger", meaning: nil)
        ]
        XCTAssertEqual(preview.cards, expected)
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

        XCTAssertEqual(preview.cards, [ParsedCard(text: "Pizza", meaning: nil)])
        XCTAssertEqual(preview.tooLongLines, [longCard])
        XCTAssertTrue(preview.summaryMessages.contains("1 card is over 30 characters."))
    }

    func testNormalModeDoesNotExtractMeanings() {
        let service = ClipboardImportService()
        let preview = service.previewCards(
            from: """
            Pizza - A cheesy Italian dish
            Burger: A delicious sandwich
            Spider-Man
            """,
            isEmoji: false
        )

        let expected = [
            ParsedCard(text: "Pizza - A cheesy Italian dish", meaning: nil),
            ParsedCard(text: "Burger: A delicious sandwich", meaning: nil),
            ParsedCard(text: "Spider-Man", meaning: nil)
        ]
        XCTAssertEqual(preview.cards, expected)
    }

    func testEmojiValidationAndMeaningRequired() {
        let service = ClipboardImportService()
        let preview = service.previewCards(
            from: """
            🍿 🎬 - Movie
            🚀 🌕 - Moonshot
            NoEmoji - Text
            🍕
            """,
            isEmoji: true
        )

        let expected = [
            ParsedCard(text: "🍿 🎬", meaning: "Movie"),
            ParsedCard(text: "🚀 🌕", meaning: "Moonshot")
        ]
        XCTAssertEqual(preview.cards, expected)
        XCTAssertEqual(preview.invalidEmojiCardsCount, 1) // "NoEmoji" has no emoji
        XCTAssertEqual(preview.missingMeaningCardsCount, 1) // "🍕" has no meaning
    }
}
