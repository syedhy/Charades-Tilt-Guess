import XCTest
@testable import CharadesTiltGuess

final class TiltGestureDetectorTests: XCTestCase {
    func testUpperLandscapeEdgeForwardAfterConfirmationMarksCorrect() {
        var detector = TiltGestureDetector(sensitivity: .relaxed)

        XCTAssertNil(detector.process(currentAngle: 0.0))
        XCTAssertNil(detector.process(currentAngle: TiltGestureThresholds.forwardTriggerAngle - 0.01))
        XCTAssertEqual(detector.process(currentAngle: TiltGestureThresholds.forwardTriggerAngle + 0.01), .correct)
    }

    func testUpperLandscapeEdgeBackAfterConfirmationMarksPass() {
        var detector = TiltGestureDetector(sensitivity: .relaxed)

        XCTAssertNil(detector.process(currentAngle: 0.0))
        XCTAssertNil(detector.process(currentAngle: TiltGestureThresholds.backwardTriggerAngle + 0.01))
        XCTAssertEqual(detector.process(currentAngle: TiltGestureThresholds.backwardTriggerAngle - 0.01), .pass)
    }

    func testDetectorStaysOnCorrectUntilPhoneReturnsToNeutral() {
        var detector = TiltGestureDetector(sensitivity: .relaxed)

        XCTAssertNil(detector.process(currentAngle: 0.0))
        XCTAssertEqual(detector.process(currentAngle: TiltGestureThresholds.forwardTriggerAngle + 0.01), .correct)
        XCTAssertNil(detector.process(currentAngle: TiltGestureThresholds.forwardTriggerAngle + 0.08))
        XCTAssertNil(detector.process(currentAngle: TiltGestureThresholds.backwardTriggerAngle - 0.01))
        XCTAssertEqual(detector.process(currentAngle: TiltGestureThresholds.neutralDeadZoneAngle - 0.01), .neutral)
        XCTAssertEqual(detector.process(currentAngle: TiltGestureThresholds.backwardTriggerAngle - 0.01), .pass)
    }

    func testDetectorStaysOnPassUntilPhoneReturnsToNeutral() {
        var detector = TiltGestureDetector(sensitivity: .relaxed)

        XCTAssertNil(detector.process(currentAngle: 0.0))
        XCTAssertEqual(detector.process(currentAngle: TiltGestureThresholds.backwardTriggerAngle - 0.01), .pass)
        XCTAssertNil(detector.process(currentAngle: TiltGestureThresholds.backwardTriggerAngle - 0.08))
        XCTAssertNil(detector.process(currentAngle: TiltGestureThresholds.forwardTriggerAngle + 0.01))
        XCTAssertEqual(detector.process(currentAngle: -(TiltGestureThresholds.neutralDeadZoneAngle - 0.01)), .neutral)
        XCTAssertEqual(detector.process(currentAngle: TiltGestureThresholds.forwardTriggerAngle + 0.01), .correct)
    }

    func testSmallMovementDoesNotTrigger() {
        var detector = TiltGestureDetector(sensitivity: .strict)

        XCTAssertNil(detector.process(currentAngle: 0.0))
        XCTAssertNil(detector.process(currentAngle: TiltGestureThresholds.neutralDeadZoneAngle - 0.01))
        XCTAssertNil(detector.process(currentAngle: -(TiltGestureThresholds.neutralDeadZoneAngle - 0.01)))
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

    func testLandscapeForwardTiltUsesGravityZFromVerticalPhonePosition() {
        let orientation = LandscapeTiltOrientation.landscapeRight

        XCTAssertEqual(orientation.forwardTiltAngle(gravityX: -1, gravityZ: 0), 0, accuracy: 0.001)
        XCTAssertGreaterThan(orientation.forwardTiltAngle(gravityX: -0.95, gravityZ: -0.3), 0)
        XCTAssertLessThan(orientation.forwardTiltAngle(gravityX: -0.95, gravityZ: 0.3), 0)
    }
}
