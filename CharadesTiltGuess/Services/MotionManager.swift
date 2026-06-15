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
        // Landscape gameplay holds the phone upright. Forward/back gestures rotate around
        // the screen's landscape X axis, so gravity.z is the signal to compare to neutral.
        let verticalComponent = abs(topEdgeGravityComponent(x: gravityX))
        return atan2(-gravityZ, verticalComponent)
    }
}

enum TiltGestureState {
    case neutral
    case showingCorrect
    case showingPass
}

enum TiltGestureThresholds {
    // Tune these three values after real-device testing in landscape gameplay.
    static let forwardTriggerAngle = degreesToRadians(16)
    static let backwardTriggerAngle = degreesToRadians(-16)
    static let neutralDeadZoneAngle = degreesToRadians(7)

    private static func degreesToRadians(_ degrees: Double) -> Double {
        degrees * .pi / 180
    }
}

struct TiltGestureDetector {
    private var neutralAngle: Double?
    private var state: TiltGestureState = .neutral

    init(sensitivity: TiltSensitivity) {
        // Gesture thresholds live in TiltGestureThresholds so real-device tuning is one edit.
    }

    mutating func reset() {
        neutralAngle = nil
        state = .neutral
    }

    mutating func process(currentAngle: Double) -> TiltAction? {
        guard let neutralAngle else {
            self.neutralAngle = currentAngle
            return nil
        }

        let relativeAngle = currentAngle - neutralAngle

        // State machine:
        // - neutral waits for the phone to rotate far enough forward/back.
        // - showingCorrect/showingPass keep the feedback screen visible.
        // - only returning to the neutral dead zone arms the next gesture.
        switch state {
        case .neutral:
            if relativeAngle >= TiltGestureThresholds.forwardTriggerAngle {
                state = .showingCorrect
                return .correct
            }

            if relativeAngle <= TiltGestureThresholds.backwardTriggerAngle {
                state = .showingPass
                return .pass
            }

            return nil

        case .showingCorrect, .showingPass:
            if abs(relativeAngle) <= TiltGestureThresholds.neutralDeadZoneAngle {
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
