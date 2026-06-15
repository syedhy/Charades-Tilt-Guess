import XCTest
@testable import CharadesTiltGuess

final class TiltGestureDetectorTests: XCTestCase {
    func testUpperLandscapeEdgeForwardAfterConfirmationMarksCorrect() {
        var detector = TiltGestureDetector(sensitivity: .relaxed)

        XCTAssertNil(detector.process(landscapeXAxisTilt: 0.0))
        XCTAssertNil(detector.process(landscapeXAxisTilt: 0.4))
        XCTAssertEqual(detector.process(landscapeXAxisTilt: 0.42), .correct)
    }

    func testUpperLandscapeEdgeBackAfterConfirmationMarksPass() {
        var detector = TiltGestureDetector(sensitivity: .relaxed)

        XCTAssertNil(detector.process(landscapeXAxisTilt: 0.0))
        XCTAssertNil(detector.process(landscapeXAxisTilt: -0.4))
        XCTAssertEqual(detector.process(landscapeXAxisTilt: -0.42), .pass)
    }

    func testDetectorMustReturnToNeutralBeforeNextAction() {
        var detector = TiltGestureDetector(sensitivity: .relaxed)

        XCTAssertNil(detector.process(landscapeXAxisTilt: 0.0))
        XCTAssertNil(detector.process(landscapeXAxisTilt: -0.4))
        XCTAssertEqual(detector.process(landscapeXAxisTilt: -0.42), .pass)
        XCTAssertNil(detector.process(landscapeXAxisTilt: -0.5))
        XCTAssertNil(detector.process(landscapeXAxisTilt: 0.0))
        XCTAssertNil(detector.process(landscapeXAxisTilt: 0.4))
        XCTAssertEqual(detector.process(landscapeXAxisTilt: 0.42), .correct)
    }

    func testSmallMovementDoesNotTrigger() {
        var detector = TiltGestureDetector(sensitivity: .strict)

        XCTAssertNil(detector.process(landscapeXAxisTilt: 0.0))
        XCTAssertNil(detector.process(landscapeXAxisTilt: 0.2))
        XCTAssertNil(detector.process(landscapeXAxisTilt: -0.2))
        XCTAssertNil(detector.process(landscapeXAxisTilt: 0.3))
    }

    func testLandscapeOrientationMapsCurrentTopEdgeToPositiveTilt() {
        XCTAssertEqual(
            LandscapeTiltOrientation.landscapeLeft.topEdgeGravityComponent(x: 0.5),
            0.5
        )
        XCTAssertEqual(
            LandscapeTiltOrientation.landscapeRight.topEdgeGravityComponent(x: -0.5),
            0.5
        )
    }
}
