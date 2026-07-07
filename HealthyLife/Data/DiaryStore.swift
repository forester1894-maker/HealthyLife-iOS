import Foundation

final class DiaryStore {
    private let key = "nutriheal_diary_entries"
    private let waterKey = "nutriheal_water_glasses"
    private let defaults = UserDefaults.standard

    func loadEntries() -> [FoodDiaryEntry] {
        guard let data = defaults.data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([FoodDiaryEntry].self, from: data)) ?? []
    }

    func saveEntries(_ entries: [FoodDiaryEntry]) {
        if let data = try? JSONEncoder().encode(entries) {
            defaults.set(data, forKey: key)
        }
    }

    func entries(for dateIso: String) -> [FoodDiaryEntry] {
        loadEntries().filter { $0.dateIso == dateIso }
    }

    func add(_ entry: FoodDiaryEntry) {
        var all = loadEntries()
        all.append(entry)
        saveEntries(all)
    }

    func remove(id: String) {
        saveEntries(loadEntries().filter { $0.id != id })
    }

    func waterGlasses(for dateIso: String) -> Int {
        defaults.integer(forKey: "\(waterKey)_\(dateIso)")
    }

    func setWaterGlasses(_ count: Int, for dateIso: String) {
        defaults.set(count, forKey: "\(waterKey)_\(dateIso)")
    }

    func clear() {
        defaults.removeObject(forKey: key)
    }
}
