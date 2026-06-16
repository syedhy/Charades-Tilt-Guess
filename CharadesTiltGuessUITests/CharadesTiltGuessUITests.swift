import XCTest

final class CharadesTiltGuessUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testHomeScreenShowsAppTitle() throws {
        let app = launchApp()

        XCTAssertTrue(app.staticTexts["Charades: Tilt & Guess"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["modeButton-normal"].waitForExistence(timeout: 5))
    }

    func testHomeScreenScrollsThroughDecks() throws {
        let app = launchApp()

        XCTAssertTrue(app.staticTexts["Charades: Tilt & Guess"].waitForExistence(timeout: 5))

        app.swipeUp()
        app.swipeUp()
        app.swipeDown()
        app.swipeDown()

        XCTAssertTrue(app.staticTexts["Charades: Tilt & Guess"].waitForExistence(timeout: 2))
    }

    func testCanNavigateThroughButtonGameFlow() throws {
        let app = launchApp()

        app.buttons["modeButton-normal"].tap()
        app.buttons["Tech, 24 prompts"].tap()
        XCTAssertTrue(app.staticTexts["Tech"].waitForExistence(timeout: 5))

        XCTAssertTrue(app.staticTexts["Place the device on your forehead"].waitForExistence(timeout: 5))

        app.buttons["Start round"].tap()
        XCTAssertTrue(app.staticTexts["Ready position"].waitForExistence(timeout: 5))
        app.buttons["manualReadyButton"].tap()
        XCTAssertTrue(app.staticTexts["gameWord"].waitForExistence(timeout: 7))

        app.buttons["Correct"].tap()
        Thread.sleep(forTimeInterval: 0.6)

        let pauseButton = app.buttons["Pause round"]
        XCTAssertTrue(pauseButton.waitForExistence(timeout: 5))
        pauseButton.tap()

        XCTAssertTrue(app.buttons["End Round"].waitForExistence(timeout: 5))
        app.buttons["End Round"].tap()
        XCTAssertTrue(app.staticTexts["Round complete"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["finalScore"].waitForExistence(timeout: 5))
    }

    func testSettingsAndDeckEditorAreReachable() throws {
        let app = launchApp()

        app.buttons["Settings"].tap()
        XCTAssertTrue(app.staticTexts["Game defaults"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Round length"].waitForExistence(timeout: 5))

        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.buttons["Add Deck"].tap()
        XCTAssertTrue(app.staticTexts["Custom deck"].waitForExistence(timeout: 5))
    }

    private func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-CharadesTiltGuess.HasSeenOnboarding", "YES"]
        app.launch()
        return app
    }
}
