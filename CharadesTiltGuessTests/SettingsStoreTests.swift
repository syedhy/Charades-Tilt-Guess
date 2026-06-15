import Foundation
import XCTest
@testable import CharadesTiltGuess

final class SettingsStoreTests: XCTestCase {
    private var userDefaults: UserDefaults!
    private var suiteName: String!

    override func setUpWithError() throws {
        try super.setUpWithError()
        suiteName = "SettingsStoreTests-\(UUID().uuidString)"
        userDefaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        userDefaults.removePersistentDomain(forName: suiteName)
    }

    override func tearDownWithError() throws {
        if let suiteName {
            userDefaults?.removePersistentDomain(forName: suiteName)
        }

        userDefaults = nil
        suiteName = nil
        try super.tearDownWithError()
    }

    func testLoadsDefaultSettingsWhenNothingIsSaved() {
        let store = SettingsStore(userDefaults: userDefaults)

        XCTAssertEqual(store.loadSettings(), .default)
    }

    func testSavesAndLoadsSettings() {
        let store = SettingsStore(userDefaults: userDefaults)
        let settings = GameSettings(
            defaultDuration: 90,
            hapticsEnabled: false,
            tiltSensitivity: .strict
        )

        store.saveSettings(settings)

        XCTAssertEqual(store.loadSettings(), settings)
    }

    func testInvalidDurationFallsBackToDefaultDuration() {
        let store = SettingsStore(userDefaults: userDefaults)
        let settings = GameSettings(
            defaultDuration: 45,
            hapticsEnabled: false,
            tiltSensitivity: .relaxed
        )

        store.saveSettings(settings)

        XCTAssertEqual(store.loadSettings().defaultDuration, GameSettings.default.defaultDuration)
        XCTAssertFalse(store.loadSettings().hapticsEnabled)
        XCTAssertEqual(store.loadSettings().tiltSensitivity, .relaxed)
    }
}
