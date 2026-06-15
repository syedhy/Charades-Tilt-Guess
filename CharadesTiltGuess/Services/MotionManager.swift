import CoreMotion
import Foundation

enum TiltAction: Equatable {
    case correct
    case pass
}

struct TiltGestureDetector {
    private let sensitivity: TiltSensitivity
    private var baselinePitch: Double?
    private var isArmed = true
    private var pendingAction: TiltAction?
    private var pendingCount = 0

    init(sensitivity: TiltSensitivity) {
        self.sensitivity = sensitivity
    }

    mutating func reset() {
        baselinePitch = nil
        isArmed = true
        pendingAction = nil
        pendingCount = 0
    }

    mutating func process(pitch: Double) -> TiltAction? {
        guard let baselinePitch else {
            self.baselinePitch = pitch
            return nil
        }

        let delta = pitch - baselinePitch

        if abs(delta) <= sensitivity.neutralThreshold {
            isArmed = true
            pendingAction = nil
            pendingCount = 0
            return nil
        }

        guard isArmed else { return nil }

        let action: TiltAction?
        if delta <= -sensitivity.threshold {
            action = .correct
        } else if delta >= sensitivity.threshold {
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
        detector.reset()
        manager.deviceMotionUpdateInterval = 1.0 / 30.0
        manager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
            guard let self, let pitch = motion?.attitude.pitch else { return }

            if let action = self.detector.process(pitch: pitch) {
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
}
