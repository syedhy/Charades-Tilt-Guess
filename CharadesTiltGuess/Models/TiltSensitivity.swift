import Foundation

enum TiltSensitivity: String, Codable, CaseIterable, Hashable, Identifiable {
    case relaxed
    case normal
    case strict

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .relaxed:
            "High Sensitivity"
        case .normal:
            "Medium Sensitivity"
        case .strict:
            "Low Sensitivity"
        }
    }

    var threshold: Double {
        switch self {
        case .relaxed:
            0.24
        case .normal:
            0.36
        case .strict:
            0.58
        }
    }

    var neutralThreshold: Double {
        threshold * 0.42
    }

    var backwardThreshold: Double {
        threshold * 0.65
    }

    var confirmationSamples: Int {
        switch self {
        case .relaxed, .normal:
            2
        case .strict:
            3
        }
    }
}
