import Foundation

struct FoodItem: Identifiable, Codable {
    let id: String
    let name: String
    let calories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
    let category: String?
}

final class FoodDatabase {
    static let shared = FoodDatabase()

    private(set) var all: [FoodItem] = []
    private(set) var popular: [FoodItem] = []

    private init() {
        load()
    }

    private func load() {
        guard let url = Bundle.main.url(forResource: "foods", withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return }

        struct Root: Decodable {
            let foods: [Entry]
        }
        struct Entry: Decodable {
            let id: String
            let n: String
            let k: Int
            let p: Double
            let c: Double
            let f: Double
        }

        if let root = try? JSONDecoder().decode(Root.self, from: data) {
            all = root.foods.map {
                FoodItem(id: $0.id, name: $0.n, calories: $0.k, protein: $0.p, carbs: $0.c, fat: $0.f, category: nil)
            }
        }
        popular = Array(all.prefix(50))
    }

    func search(_ query: String) -> [FoodItem] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if q.isEmpty { return Array(all.prefix(100)) }
        return all.filter { $0.name.localizedCaseInsensitiveContains(q) }.prefix(80).map { $0 }
    }
}
