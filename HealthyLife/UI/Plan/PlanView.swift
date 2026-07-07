import SwiftUI

struct PlanView: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedDay = 0
    @State private var tab = 0

    var body: some View {
        NavigationStack {
            if let plan = appState.weeklyPlan {
                VStack(spacing: 0) {
                    Picker("Раздел", selection: $tab) {
                        Text("Рацион").tag(0)
                        Text("Покупки").tag(1)
                        Text("Активность").tag(2)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .padding(.top, 8)

                    if tab == 0 {
                        rationTab(plan: plan)
                    } else if tab == 1 {
                        shoppingTab(plan: plan)
                    } else {
                        activityTab(plan: plan)
                    }
                }
                .background(AppTheme.background)
                .navigationTitle("План на неделю")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Обновить") { appState.regeneratePlan() }
                    }
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "calendar")
                        .font(.largeTitle)
                        .foregroundStyle(AppTheme.primary)
                    Text("План не готов").font(.headline)
                }
                .navigationTitle("План на неделю")
            }
        }
        .onAppear {
            selectedDay = appState.todayDayIndex()
        }
    }

    private func rationTab(plan: WeeklyPlan) -> some View {
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
                    Text("≈ \(day.dailyCalories) ккал за день").foregroundStyle(.secondary)
                    ForEach(day.meals.indices, id: \.self) { mealIndex in
                        let meal = day.meals[mealIndex]
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(meal.mealType).font(.caption).foregroundStyle(.secondary)
                                    Text(meal.dishName)
                                }
                                Spacer()
                                Text("\(meal.calories) ккал")
                            }
                            if !meal.recipeSteps.isEmpty {
                                DisclosureGroup("Рецепт") {
                                    ForEach(meal.recipeSteps.indices, id: \.self) { i in
                                        Text("\(i + 1). \(meal.recipeSteps[i])").font(.caption)
                                    }
                                }
                            }
                            Button("Заменить блюдо") {
                                appState.swapMeal(dayIndex: selectedDay, mealIndex: mealIndex)
                            }
                            .font(.caption)
                        }
                        .cardStyle()
                    }
                }
                .padding()
            }
        }
    }

    private func shoppingTab(plan: WeeklyPlan) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(plan.shoppingList, id: \.self) { item in
                    Label(item, systemImage: "cart")
                        .font(.subheadline)
                        .cardStyle()
                }
            }
            .padding()
        }
    }

    private func activityTab(plan: WeeklyPlan) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(plan.activitySummary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .cardStyle()
                ForEach(plan.activityPlan) { day in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(day.dayName).font(.headline)
                        if day.allowed {
                            Text("\(day.activityType) · \(day.durationMinutes) мин · \(day.intensity)")
                                .font(.subheadline)
                        } else {
                            Text("Отдых / лёгкая прогулка").foregroundStyle(.secondary)
                        }
                        ForEach(day.notes, id: \.self) { note in
                            Text("• \(note)").font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    .cardStyle()
                }
            }
            .padding()
        }
    }

    private func shortDay(_ name: String) -> String {
        String(name.prefix(2))
    }
}
