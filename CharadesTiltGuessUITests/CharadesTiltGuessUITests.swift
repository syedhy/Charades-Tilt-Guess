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

    func testCanNavigateThroughPlaceholderGameFlow() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["Tech, 24 prompts"].tap()
        XCTAssertTrue(app.staticTexts["Tech setup"].waitForExistence(timeout: 5))

        app.buttons["Start placeholder round"].tap()
        XCTAssertTrue(app.staticTexts["Game placeholder"].waitForExistence(timeout: 5))

        app.buttons["End placeholder round"].tap()
        XCTAssertTrue(app.staticTexts["Results placeholder"].waitForExistence(timeout: 5))
    }

    func testSettingsAndDeckEditorAreReachable() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["Settings"].tap()
        XCTAssertTrue(app.staticTexts["Settings placeholder"].waitForExistence(timeout: 5))

        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.buttons["Create deck"].tap()
        XCTAssertTrue(app.staticTexts["Custom deck"].waitForExistence(timeout: 5))
    }
}
