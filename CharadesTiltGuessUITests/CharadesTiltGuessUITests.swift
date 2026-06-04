import XCTest

final class CharadesTiltGuessUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testHomeScreenShowsAppTitle() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.staticTexts["Charades: Tilt & Guess"].waitForExistence(timeout: 5))
    }

    func testHomeScreenScrollsThroughDecks() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.staticTexts["Charades: Tilt & Guess"].waitForExistence(timeout: 5))

        app.swipeUp()
        app.swipeUp()
        app.swipeDown()
        app.swipeDown()

        XCTAssertTrue(app.staticTexts["Charades: Tilt & Guess"].waitForExistence(timeout: 2))
    }
}
