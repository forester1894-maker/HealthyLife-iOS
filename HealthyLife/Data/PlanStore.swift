import Foundation

final class PlanStore {
    private let key = "nutriheal_weekly_plan"
    private let defaults = UserDefaults.standard

    func load() -> WeeklyPlan? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(WeeklyPlan.self, from: data)
    }

    func save(_ plan: WeeklyPlan) {
        if let data = try? JSONEncoder().encode(plan) {
            defaults.set(data, forKey: key)
        }
    }

    func clear() {
        defaults.removeObject(forKey: key)
    }
}
