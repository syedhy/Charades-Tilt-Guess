import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published private(set) var settings: GameSettings

    private let store: SettingsStore

    init(store: SettingsStore = SettingsStore()) {
        self.store = store
        self.settings = store.loadSettings()
    }

    func setDefaultDuration(_ duration: Int) {
        settings.defaultDuration = duration
        persist()
    }

    func setSoundsEnabled(_ isEnabled: Bool) {
        settings.soundsEnabled = isEnabled
        persist()
    }

    func setHapticsEnabled(_ isEnabled: Bool) {
        settings.hapticsEnabled = isEnabled
        persist()
    }

    func setMotionControlsEnabled(_ isEnabled: Bool) {
        settings.motionControlsEnabled = isEnabled
        if !isEnabled {
            settings.swipeControlsEnabled = true
        }
        persist()
    }

    func setSwipeControlsEnabled(_ isEnabled: Bool) {
        settings.swipeControlsEnabled = isEnabled
        persist()
    }

    func setTiltSensitivity(_ sensitivity: TiltSensitivity) {
        settings.tiltSensitivity = sensitivity
        persist()
    }

    private func persist() {
        settings = settings.normalized
        store.saveSettings(settings)
    }
}
