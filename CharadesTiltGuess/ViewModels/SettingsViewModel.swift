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

    func setHapticsEnabled(_ isEnabled: Bool) {
        settings.hapticsEnabled = isEnabled
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
