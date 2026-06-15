import XCTest
@testable import CharadesTiltGuess

final class TiltGestureDetectorTests: XCTestCase {
    func testTiltDownAfterConfirmationMarksCorrect() {
        var detector = TiltGestureDetector(sensitivity: .relaxed)

        XCTAssertNil(detector.process(pitch: 0.0))
        XCTAssertNil(detector.process(pitch: -0.4))
        XCTAssertEqual(detector.process(pitch: -0.42), .correct)
    }

    func testTiltUpAfterConfirmationMarksPass() {
        var detector = TiltGestureDetector(sensitivity: .relaxed)

        XCTAssertNil(detector.process(pitch: 0.0))
        XCTAssertNil(detector.process(pitch: 0.4))
        XCTAssertEqual(detector.process(pitch: 0.42), .pass)
    }

    func testDetectorMustReturnToNeutralBeforeNextAction() {
        var detector = TiltGestureDetector(sensitivity: .relaxed)

        XCTAssertNil(detector.process(pitch: 0.0))
        XCTAssertNil(detector.process(pitch: 0.4))
        XCTAssertEqual(detector.process(pitch: 0.42), .pass)
        XCTAssertNil(detector.process(pitch: 0.5))
        XCTAssertNil(detector.process(pitch: 0.0))
        XCTAssertNil(detector.process(pitch: -0.4))
        XCTAssertEqual(detector.process(pitch: -0.42), .correct)
    }

    func testSmallMovementDoesNotTrigger() {
        var detector = TiltGestureDetector(sensitivity: .strict)

        XCTAssertNil(detector.process(pitch: 0.0))
        XCTAssertNil(detector.process(pitch: 0.2))
        XCTAssertNil(detector.process(pitch: -0.2))
        XCTAssertNil(detector.process(pitch: 0.3))
    }
}
