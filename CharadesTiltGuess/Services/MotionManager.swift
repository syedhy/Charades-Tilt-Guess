import CoreMotion
import Foundation
import UIKit

enum TiltAction: Equatable {
    case correct
    case pass
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
}

struct TiltGestureDetector {
    private let sensitivity: TiltSensitivity
    private var baselineTilt: Double?
    private var isArmed = true
    private var pendingAction: TiltAction?
    private var pendingCount = 0

    init(sensitivity: TiltSensitivity) {
        self.sensitivity = sensitivity
    }

    mutating func reset() {
        baselineTilt = nil
        isArmed = true
        pendingAction = nil
        pendingCount = 0
    }

    mutating func process(landscapeXAxisTilt: Double) -> TiltAction? {
        guard let baselineTilt else {
            self.baselineTilt = landscapeXAxisTilt
            return nil
        }

        let delta = landscapeXAxisTilt - baselineTilt

        if abs(delta) <= sensitivity.neutralThreshold {
            isArmed = true
            pendingAction = nil
            pendingCount = 0
            return nil
        }

        guard isArmed else { return nil }

        let action: TiltAction?
        if delta >= sensitivity.threshold {
            action = .correct
        } else if delta <= -sensitivity.threshold {
            action = .pass
        } else {
            action = nil
        }

        guard let action else {
            pendingAction = nil
            pendingCount = 0
            return nil
        }

        if pendingAction == action {
            pendingCount += 1
        } else {
            pendingAction = action
            pendingCount = 1
        }

        guard pendingCount >= sensitivity.confirmationSamples else { return nil }

        isArmed = false
        pendingAction = nil
        pendingCount = 0
        return action
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
            guard let self, let gravityX = motion?.gravity.x else { return }

            let tilt = self.orientation.topEdgeGravityComponent(x: gravityX)
            if let action = self.detector.process(landscapeXAxisTilt: tilt) {
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
