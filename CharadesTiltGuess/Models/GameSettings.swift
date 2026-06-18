import Foundation

struct GameSettings: Codable, Hashable {
    var defaultDuration: Int
    var soundsEnabled: Bool
    var hapticsEnabled: Bool
    var motionControlsEnabled: Bool
    var swipeControlsEnabled: Bool
    var tiltSensitivity: TiltSensitivity

    static let availableDurations = [30, 60, 90, 120]

    static let `default` = GameSettings(
        defaultDuration: 60,
        soundsEnabled: true,
        hapticsEnabled: true,
        motionControlsEnabled: true,
        swipeControlsEnabled: true,
        tiltSensitivity: .normal
    )

    var normalized: GameSettings {
        GameSettings(
            defaultDuration: Self.availableDurations.contains(defaultDuration) ? defaultDuration : Self.default.defaultDuration,
            soundsEnabled: soundsEnabled,
            hapticsEnabled: hapticsEnabled,
            motionControlsEnabled: motionControlsEnabled,
            swipeControlsEnabled: motionControlsEnabled ? swipeControlsEnabled : true,
            tiltSensitivity: tiltSensitivity
        )
    }

    var effectiveSwipeControlsEnabled: Bool {
        !motionControlsEnabled || swipeControlsEnabled
    }

    enum CodingKeys: String, CodingKey {
        case defaultDuration
        case soundsEnabled
        case hapticsEnabled
        case motionControlsEnabled
        case swipeControlsEnabled
        case tiltSensitivity
    }

    init(
        defaultDuration: Int,
        soundsEnabled: Bool = Self.default.soundsEnabled,
        hapticsEnabled: Bool,
        motionControlsEnabled: Bool = Self.default.motionControlsEnabled,
        swipeControlsEnabled: Bool = Self.default.swipeControlsEnabled,
        tiltSensitivity: TiltSensitivity
    ) {
        self.defaultDuration = defaultDuration
        self.soundsEnabled = soundsEnabled
        self.hapticsEnabled = hapticsEnabled
        self.motionControlsEnabled = motionControlsEnabled
        self.swipeControlsEnabled = swipeControlsEnabled
        self.tiltSensitivity = tiltSensitivity
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        defaultDuration = try container.decodeIfPresent(Int.self, forKey: .defaultDuration) ?? Self.default.defaultDuration
        soundsEnabled = try container.decodeIfPresent(Bool.self, forKey: .soundsEnabled) ?? Self.default.soundsEnabled
        hapticsEnabled = try container.decodeIfPresent(Bool.self, forKey: .hapticsEnabled) ?? Self.default.hapticsEnabled
        motionControlsEnabled = try container.decodeIfPresent(Bool.self, forKey: .motionControlsEnabled) ?? Self.default.motionControlsEnabled
        swipeControlsEnabled = try container.decodeIfPresent(Bool.self, forKey: .swipeControlsEnabled) ?? Self.default.swipeControlsEnabled
        tiltSensitivity = try container.decodeIfPresent(TiltSensitivity.self, forKey: .tiltSensitivity) ?? Self.default.tiltSensitivity
    }
}
