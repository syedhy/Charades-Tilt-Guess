import XCTest
@testable import CharadesTiltGuess

final class CharadesTiltGuessTests: XCTestCase {
    func testAppMetadataUsesPlannedName() {
        XCTAssertEqual(AppMetadata.displayName, "Charades: Tilt & Guess")
    }
}
