import CoreMotion
import Foundation
import UIKit

enum TiltAction: Equatable {
    case correct
    case pass
    case neutral
}

enum LandscapeTiltOrientation {
    case landscapeLeft
    case landscapeRight

    init(interfaceOrientation: UIInterfaceOrientation) {
        if interfaceOrientation == .landscapeLeft {
            self = .landscapeLeft
        } else {
            self = .landscapeRight
        }
    }

    func topEdgeGravityComponent(x: Double) -> Double {
        switch self {
        case .landscapeLeft:
            x
        case .landscapeRight:
            -x
        }
    }

    func forwardTiltAngle(gravityX: Double, gravityZ: Double) -> Double {
        let verticalComponent = abs(topEdgeGravityComponent(x: gravityX))
        return atan2(gravityZ, verticalComponent)
    }

    func isXAxisParallelToGround(gravityY: Double) -> Bool {
        let allowedSideTilt = 0.25
        return abs(gravityY) <= allowedSideTilt
    }
}

enum TiltGestureState {
    case waitingForValidNeutral
    case neutral
    case showingCorrect
    case showingPass
}

struct TiltGestureThresholdValues {
    let forwardTriggerAngle: Double
    let backwardTriggerAngle: Double
    let neutralDeadZoneAngle: Double
}

enum TiltGestureThresholds {
    // Edit these preset degree values to tune each sensitivity. Normal is the
    // real-device tuned baseline that currently feels good in landscape play.
    static let relaxed = values(forwardDegrees: 34, backwardDegrees: -34, neutralDegrees: 20)
    static let normal = values(forwardDegrees: 39, backwardDegrees: -39, neutralDegrees: 18)
    static let strict = values(forwardDegrees: 44, backwardDegrees: -44, neutralDegrees: 16)

    static let forwardTriggerAngle = normal.forwardTriggerAngle
    static let backwardTriggerAngle = normal.backwardTriggerAngle
    static let neutralDeadZoneAngle = normal.neutralDeadZoneAngle

    static func values(for sensitivity: TiltSensitivity) -> TiltGestureThresholdValues {
        switch sensitivity {
        case .relaxed:
            relaxed
        case .normal:
            normal
        case .strict:
            strict
        }
    }

    private static func values(
        forwardDegrees: Double,
        backwardDegrees: Double,
        neutralDegrees: Double
    ) -> TiltGestureThresholdValues {
        TiltGestureThresholdValues(
            forwardTriggerAngle: degreesToRadians(forwardDegrees),
            backwardTriggerAngle: degreesToRadians(backwardDegrees),
            neutralDeadZoneAngle: degreesToRadians(neutralDegrees)
        )
    }

    private static func degreesToRadians(_ degrees: Double) -> Double { degrees * .pi / 180 }
}

struct TiltGestureDetector {
    private let thresholds: TiltGestureThresholdValues
    private var state: TiltGestureState = .waitingForValidNeutral

    init(sensitivity: TiltSensitivity) {
        thresholds = TiltGestureThresholds.values(for: sensitivity)
    }

    mutating func reset() {
        state = .waitingForValidNeutral
    }

    mutating func alignmentLost() {
        if state == .neutral {
            state = .waitingForValidNeutral
        }
    }

    mutating func process(currentAngle: Double) -> TiltAction? {
        let relativeAngle = currentAngle
        let isInNeutralZone = abs(relativeAngle) <= thresholds.neutralDeadZoneAngle

        switch state {
        case .waitingForValidNeutral:
            if isInNeutralZone {
                state = .neutral
            }

            return nil

        case .neutral:
            if relativeAngle >= thresholds.forwardTriggerAngle {
                state = .showingCorrect
                return .correct
            }

            if relativeAngle <= thresholds.backwardTriggerAngle {
                state = .showingPass
                return .pass
            }

            return nil

        case .showingCorrect, .showingPass:
            if isInNeutralZone {
                state = .neutral
                return .neutral
            }

            return nil
        }
    }
}

@MainActor
final class MotionManager {
    private let manager: CMMotionManager
    private var detector: TiltGestureDetector
    private var onAction: ((TiltAction) -> Void)?
    private var orientation: LandscapeTiltOrientation = .landscapeRight

    init(
        sensitivity: TiltSensitivity,
        manager: CMMotionManager = CMMotionManager()
    ) {
        self.manager = manager
        self.detector = TiltGestureDetector(sensitivity: sensitivity)
    }

    var isAvailable: Bool {
        manager.isDeviceMotionAvailable
    }

    var isRunning: Bool {
        manager.isDeviceMotionActive
    }

    func start(onAction: @escaping (TiltAction) -> Void) {
        guard isAvailable, !isRunning else { return }

        self.onAction = onAction
        self.orientation = LandscapeTiltOrientation(interfaceOrientation: Self.currentInterfaceOrientation)
        detector.reset()
        manager.deviceMotionUpdateInterval = 1.0 / 30.0
        manager.startDeviceMotionUpdates(using: .xArbitraryZVertical, to: .main) { [weak self] motion, _ in
            guard let self, let motion else { return }

            let angle = self.orientation.forwardTiltAngle(
                gravityX: motion.gravity.x,
                gravityZ: motion.gravity.z
            )

            guard self.orientation.isXAxisParallelToGround(gravityY: motion.gravity.y) else {
                self.detector.alignmentLost()
                return
            }

            #if DEBUG
            // For device tuning, temporarily log roll/pitch/yaw and `angle` here while holding the phone in landscape.
            #endif

            if let action = self.detector.process(currentAngle: angle) {
                self.onAction?(action)
            }
        }
    }

    func stop() {
        guard isRunning else { return }

        manager.stopDeviceMotionUpdates()
        onAction = nil
        detector.reset()
    }

    private static var currentInterfaceOrientation: UIInterfaceOrientation {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?
            .interfaceOrientation ?? .landscapeRight
    }
}
