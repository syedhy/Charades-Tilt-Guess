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

    func testCanNavigateThroughButtonGameFlow() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["Tech, 24 prompts"].tap()
        XCTAssertTrue(app.staticTexts["Tech"].waitForExistence(timeout: 5))

        app.buttons["Play deck"].tap()
        XCTAssertTrue(app.staticTexts["Place the device on your forehead"].waitForExistence(timeout: 5))

        app.buttons["Start round"].tap()
        XCTAssertTrue(app.staticTexts["gameWord"].waitForExistence(timeout: 5))

        app.buttons["Correct"].tap()
        Thread.sleep(forTimeInterval: 0.6)

        let pauseButton = app.buttons["Pause round"]
        XCTAssertTrue(pauseButton.waitForExistence(timeout: 5))
        pauseButton.tap()

        XCTAssertTrue(app.buttons["End round"].waitForExistence(timeout: 5))
        app.buttons["End round"].tap()
        XCTAssertTrue(app.staticTexts["Round complete"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["finalScore"].waitForExistence(timeout: 5))
    }

    func testSettingsAndDeckEditorAreReachable() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["Settings"].tap()
        XCTAssertTrue(app.staticTexts["Game defaults"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Round length"].waitForExistence(timeout: 5))

        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.buttons["Create deck"].tap()
        XCTAssertTrue(app.staticTexts["Custom deck"].waitForExistence(timeout: 5))
    }
}
