import Foundation

struct GameSettings: Codable, Hashable {
    var defaultDuration: Int
    var hapticsEnabled: Bool
    var tiltSensitivity: TiltSensitivity

    static let availableDurations = [30, 60, 90, 120]

    static let `default` = GameSettings(
        defaultDuration: 60,
        hapticsEnabled: true,
        tiltSensitivity: .normal
    )

    var normalized: GameSettings {
        GameSettings(
            defaultDuration: Self.availableDurations.contains(defaultDuration) ? defaultDuration : Self.default.defaultDuration,
            hapticsEnabled: hapticsEnabled,
            tiltSensitivity: tiltSensitivity
        )
    }
}
