import Foundation

final class WeightStore {
    private let key = "nutriheal_weight_entries"
    private let defaults = UserDefaults.standard

    func load() -> [WeightEntry] {
        guard let data = defaults.data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([WeightEntry].self, from: data)) ?? []
    }

    func save(_ entries: [WeightEntry]) {
        if let data = try? JSONEncoder().encode(entries) {
            defaults.set(data, forKey: key)
        }
    }

    func add(_ entry: WeightEntry) {
        var all = load()
        all.append(entry)
        all.sort { $0.dateIso > $1.dateIso }
        save(all)
    }

    func clear() {
        defaults.removeObject(forKey: key)
    }
}
