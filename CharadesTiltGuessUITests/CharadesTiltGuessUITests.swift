import XCTest

final class CharadesTiltGuessUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testHomeScreenShowsAppTitle() throws {
        let app = launchApp()

        XCTAssertTrue(app.staticTexts["Charades"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["modeButton-normal"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["modeButton-mixAndMatch"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["modeButton-pasteAndPlay"].exists)
    }

    func testHomeScreenScrollsThroughDecks() throws {
        let app = launchApp()

        XCTAssertTrue(app.staticTexts["Charades"].waitForExistence(timeout: 5))

        app.swipeUp()
        app.swipeUp()
        app.swipeDown()
        app.swipeDown()

        XCTAssertTrue(app.staticTexts["Charades"].waitForExistence(timeout: 2))
    }

    func testMixAndMatchStartsWithEveryDeckSelected() throws {
        let app = launchApp()
        let modeButton = app.buttons["modeButton-mixAndMatch"]

        XCTAssertTrue(modeButton.waitForExistence(timeout: 5))
        if !modeButton.isHittable {
            app.swipeUp()
        }
        modeButton.tap()

        XCTAssertTrue(app.staticTexts["Choose your decks"].waitForExistence(timeout: 5))

        let toggleAllButton = app.buttons["mixAndMatchSelectAllButton"]
        let startButton = app.buttons["mixAndMatchStartButton"]
        XCTAssertTrue(toggleAllButton.waitForExistence(timeout: 5))
        XCTAssertTrue(startButton.waitForExistence(timeout: 5))
        XCTAssertTrue(startButton.isEnabled)

        toggleAllButton.tap()
        XCTAssertFalse(startButton.isEnabled)

        toggleAllButton.tap()
        XCTAssertTrue(startButton.isEnabled)
    }

    func testCanNavigateThroughButtonGameFlow() throws {
        let app = launchApp()

        app.buttons["modeButton-normal"].tap()
        app.buttons["Tech, 24 prompts"].tap()
        XCTAssertTrue(app.staticTexts["Tech"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["24 cards"].waitForExistence(timeout: 5))

        app.buttons["playDeckButton"].tap()
        XCTAssertTrue(app.staticTexts["Ready position"].waitForExistence(timeout: 5))
        app.buttons["manualReadyButton"].tap()
        XCTAssertTrue(app.staticTexts["gameWord"].waitForExistence(timeout: 7))

        swipeDown(in: app)
        Thread.sleep(forTimeInterval: 0.6)

        let pauseButton = app.buttons["Pause round"]
        XCTAssertTrue(pauseButton.waitForExistence(timeout: 5))
        pauseButton.tap()

        XCTAssertTrue(app.buttons["pauseEndRoundButton"].waitForExistence(timeout: 5))
        app.buttons["pauseEndRoundButton"].tap()
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

    func testSettingsCanReplayOnboardingWithoutSystemNavGap() throws {
        let app = launchApp()

        app.buttons["Settings"].tap()
        XCTAssertTrue(app.staticTexts["Game defaults"].waitForExistence(timeout: 5))

        let replayButton = app.buttons["Replay how to play"]
        if !replayButton.waitForExistence(timeout: 1) {
            app.swipeUp()
        }

        XCTAssertTrue(replayButton.waitForExistence(timeout: 5))
        replayButton.tap()

        XCTAssertTrue(app.staticTexts["Charades"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Step 1 of 4"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Back"].exists || app.buttons["onboardingDismissButton"].exists)
    }

    func testCustomDeckSelectionShowsCardsAndAddOptions() throws {
        let app = launchApp()
        let deckName = "UITest \(Int(Date().timeIntervalSince1970) % 10000)"

        app.buttons["Add Deck"].tap()
        XCTAssertTrue(app.staticTexts["Custom deck"].waitForExistence(timeout: 5))

        let nameField = app.textFields["deckNameField"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 5))
        nameField.tap()
        nameField.typeText(deckName)

        app.buttons["createCustomDeckButton"].tap()
        XCTAssertTrue(app.staticTexts[deckName].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["0 cards"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["addCardManuallyButton"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["pasteCardsFromClipboardButton"].waitForExistence(timeout: 5))

        app.buttons["addCardManuallyButton"].tap()
        XCTAssertTrue(app.staticTexts["Add Card"].waitForExistence(timeout: 5))
    }

    private func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-CharadesTiltGuess.HasSeenOnboarding", "YES"]
        app.launch()
        return app
    }

    private func swipeDown(in app: XCUIApplication) {
        let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.42))
        let end = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.82))
        start.press(forDuration: 0.05, thenDragTo: end)
    }
}
