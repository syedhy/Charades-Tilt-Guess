import Foundation

struct SettingsStore {
    private let userDefaults: UserDefaults
    private let key: String

    init(
        userDefaults: UserDefaults = .standard,
        key: String = "CharadesTiltGuess.GameSettings"
    ) {
        self.userDefaults = userDefaults
        self.key = key
    }

    func loadSettings() -> GameSettings {
        guard let data = userDefaults.data(forKey: key) else {
            return .default
        }

        do {
            return try JSONDecoder().decode(GameSettings.self, from: data).normalized
        } catch {
            return .default
        }
    }

    func saveSettings(_ settings: GameSettings) {
        guard let data = try? JSONEncoder().encode(settings.normalized) else { return }
        userDefaults.set(data, forKey: key)
    }
}
