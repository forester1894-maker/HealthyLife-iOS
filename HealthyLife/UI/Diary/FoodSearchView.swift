import SwiftUI

struct FoodSearchView: View {
    @EnvironmentObject private var appState: AppState
    @State private var query = ""
    @State private var results: [FoodSearchResult] = []
    @State private var mealType = "Перекус"
    @State private var multiplier = 1.0

    private let mealTypes = ["Завтрак", "Обед", "Ужин", "Перекус"]

    var body: some View {
        VStack {
            Picker("Приём", selection: $mealType) {
                ForEach(mealTypes, id: \.self) { Text($0) }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            TextField("Поиск продукта", text: $query)
                .padding(12)
                .background(AppTheme.container)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal)
                .onChange(of: query) { q in
                    results = searchFoods(q)
                }

            List(results) { food in
                Button {
                    addFood(food)
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(food.name).font(.subheadline.bold())
                        Text("\(Int(food.calories)) ккал · \(food.servingDescription)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Добавить еду")
        .onAppear { results = searchFoods("") }
    }

    private func searchFoods(_ q: String) -> [FoodSearchResult] {
        let items = q.isEmpty ? FoodDatabase.shared.popular : FoodDatabase.shared.search(q)
        return items.prefix(40).map { item in
            FoodSearchResult(
                foodId: item.id, name: item.name, brandName: nil,
                calories: Double(item.calories), protein: item.protein,
                carbs: item.carbs, fat: item.fat,
                sodiumMg: 0, sugarG: 0, saturatedFatG: 0,
                servingDescription: "100 г"
            )
        }
    }

    private func addFood(_ food: FoodSearchResult) {
        let entry = FoodDiaryEntry(
            dateIso: todayIso(),
            mealType: mealType,
            foodName: food.name,
            calories: food.calories * multiplier,
            protein: food.protein * multiplier,
            carbs: food.carbs * multiplier,
            fat: food.fat * multiplier,
            portionMultiplier: multiplier,
            foodId: food.foodId,
            servingDescription: food.servingDescription
        )
        appState.addDiaryEntry(entry)
    }

    private func todayIso() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f.string(from: Date())
    }
}
