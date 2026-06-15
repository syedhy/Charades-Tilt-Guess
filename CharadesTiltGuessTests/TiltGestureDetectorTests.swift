import XCTest
@testable import CharadesTiltGuess

final class TiltGestureDetectorTests: XCTestCase {
    func testUpperLandscapeEdgeForwardAfterConfirmationMarksCorrect() {
        let thresholds = TiltGestureThresholds.values(for: .relaxed)
        var detector = TiltGestureDetector(sensitivity: .relaxed)

        XCTAssertNil(detector.process(currentAngle: 0.0))
        XCTAssertNil(detector.process(currentAngle: thresholds.forwardTriggerAngle - 0.01))
        XCTAssertEqual(detector.process(currentAngle: thresholds.forwardTriggerAngle + 0.01), .correct)
    }

    func testUpperLandscapeEdgeBackAfterConfirmationMarksPass() {
        let thresholds = TiltGestureThresholds.values(for: .relaxed)
        var detector = TiltGestureDetector(sensitivity: .relaxed)

        XCTAssertNil(detector.process(currentAngle: 0.0))
        XCTAssertNil(detector.process(currentAngle: thresholds.backwardTriggerAngle + 0.01))
        XCTAssertEqual(detector.process(currentAngle: thresholds.backwardTriggerAngle - 0.01), .pass)
    }

    func testDetectorStaysOnCorrectUntilPhoneReturnsToNeutral() {
        let thresholds = TiltGestureThresholds.values(for: .relaxed)
        var detector = TiltGestureDetector(sensitivity: .relaxed)

        XCTAssertNil(detector.process(currentAngle: 0.0))
        XCTAssertEqual(detector.process(currentAngle: thresholds.forwardTriggerAngle + 0.01), .correct)
        XCTAssertNil(detector.process(currentAngle: thresholds.forwardTriggerAngle + 0.08))
        XCTAssertNil(detector.process(currentAngle: thresholds.backwardTriggerAngle - 0.01))
        XCTAssertEqual(detector.process(currentAngle: thresholds.neutralDeadZoneAngle - 0.01), .neutral)
        XCTAssertEqual(detector.process(currentAngle: thresholds.backwardTriggerAngle - 0.01), .pass)
    }

    func testDetectorStaysOnPassUntilPhoneReturnsToNeutral() {
        let thresholds = TiltGestureThresholds.values(for: .relaxed)
        var detector = TiltGestureDetector(sensitivity: .relaxed)

        XCTAssertNil(detector.process(currentAngle: 0.0))
        XCTAssertEqual(detector.process(currentAngle: thresholds.backwardTriggerAngle - 0.01), .pass)
        XCTAssertNil(detector.process(currentAngle: thresholds.backwardTriggerAngle - 0.08))
        XCTAssertNil(detector.process(currentAngle: thresholds.forwardTriggerAngle + 0.01))
        XCTAssertEqual(detector.process(currentAngle: -(thresholds.neutralDeadZoneAngle - 0.01)), .neutral)
        XCTAssertEqual(detector.process(currentAngle: thresholds.forwardTriggerAngle + 0.01), .correct)
    }

    func testSmallMovementDoesNotTrigger() {
        let thresholds = TiltGestureThresholds.values(for: .strict)
        var detector = TiltGestureDetector(sensitivity: .strict)

        XCTAssertNil(detector.process(currentAngle: 0.0))
        XCTAssertNil(detector.process(currentAngle: thresholds.neutralDeadZoneAngle - 0.01))
        XCTAssertNil(detector.process(currentAngle: -(thresholds.neutralDeadZoneAngle - 0.01)))
    }

    func testNormalSensitivityUsesTunedGestureAngles() {
        XCTAssertEqual(TiltGestureThresholds.forwardTriggerAngle, TiltGestureThresholds.normal.forwardTriggerAngle)
        XCTAssertEqual(TiltGestureThresholds.backwardTriggerAngle, TiltGestureThresholds.normal.backwardTriggerAngle)
        XCTAssertEqual(TiltGestureThresholds.neutralDeadZoneAngle, TiltGestureThresholds.normal.neutralDeadZoneAngle)
    }

    func testOtherSensitivityValuesAreEditableAroundNormal() {
        XCTAssertLessThan(TiltGestureThresholds.relaxed.forwardTriggerAngle, TiltGestureThresholds.normal.forwardTriggerAngle)
        XCTAssertGreaterThan(TiltGestureThresholds.strict.forwardTriggerAngle, TiltGestureThresholds.normal.forwardTriggerAngle)
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
        XCTAssertGreaterThan(orientation.forwardTiltAngle(gravityX: -0.95, gravityZ: 0.3), 0)
        XCTAssertLessThan(orientation.forwardTiltAngle(gravityX: -0.95, gravityZ: -0.3), 0)
    }
}
