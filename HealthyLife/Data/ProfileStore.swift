import Foundation

final class ProfileStore {
    private let key = "nutriheal_profile"
    private let defaults = UserDefaults.standard

    func load() -> UserProfile? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(UserProfile.self, from: data)
    }

    func save(_ profile: UserProfile) {
        if let data = try? JSONEncoder().encode(profile) {
            defaults.set(data, forKey: key)
        }
    }

    func clear() {
        defaults.removeObject(forKey: key)
    }
}

final class ConsentStore {
    private let key = "nutriheal_consent"
    private let defaults = UserDefaults.standard

    var isAccepted: Bool { defaults.bool(forKey: key) }

    func accept() {
        defaults.set(true, forKey: key)
    }

    func reset() {
        defaults.removeObject(forKey: key)
    }
}
