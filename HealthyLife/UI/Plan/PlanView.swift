import SwiftUI

struct PlanView: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedDay = 0

    var body: some View {
        NavigationStack {
            if let plan = appState.weeklyPlan {
                VStack(spacing: 0) {
                    Picker("День", selection: $selectedDay) {
                        ForEach(plan.days.indices, id: \.self) { i in
                            Text(shortDay(plan.days[i].dayName)).tag(i)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()

                    ScrollView {
                        let day = plan.days[selectedDay]
                        VStack(alignment: .leading, spacing: 12) {
                            Text(day.dayName).font(.title2.bold())
                            Text("≈ \(day.dailyCalories) ккал за день")
                                .foregroundStyle(.secondary)
                            ForEach(day.meals) { meal in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(meal.mealType).font(.caption).foregroundStyle(.secondary)
                                        Text(meal.dishName)
                                    }
                                    Spacer()
                                    Text("\(meal.calories) ккал")
                                }
                                .cardStyle()
                            }
                            shoppingSection(plan.shoppingList)
                        }
                        .padding()
                    }
                }
                .background(AppTheme.background)
                .navigationTitle("План на неделю")
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "calendar")
                        .font(.largeTitle)
                        .foregroundStyle(AppTheme.primary)
                    Text("План не готов")
                        .font(.headline)
                }
                .navigationTitle("План на неделю")
            }
        }
    }

    private func shortDay(_ name: String) -> String {
        String(name.prefix(2))
    }

    private func shoppingSection(_ items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Список покупок").font(.headline)
            ForEach(items, id: \.self) { item in
                Label(item, systemImage: "cart")
                    .font(.subheadline)
            }
        }
        .cardStyle()
    }
}
