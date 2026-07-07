import Foundation

final class ReminderStore {
    private let key = "nutriheal_reminders"
    private let defaults = UserDefaults.standard

    func load() -> ReminderSettings {
        guard let data = defaults.data(forKey: key),
              let settings = try? JSONDecoder().decode(ReminderSettings.self, from: data) else {
            return ReminderSettings()
        }
        return settings
    }

    func save(_ settings: ReminderSettings) {
        if let data = try? JSONEncoder().encode(settings) {
            defaults.set(data, forKey: key)
        }
    }
}
