import SwiftUI

struct TodayView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationStack {
            ScrollView {
                if let profile = appState.profile, let plan = appState.weeklyPlan {
                    let today = plan.days[Calendar.current.component(.weekday, from: Date()) == 1 ? 6 : Calendar.current.component(.weekday, from: Date()) - 2]
                    VStack(alignment: .leading, spacing: 16) {
                        header(profile: profile, plan: plan)
                        waterCard(glasses: plan.waterGlasses)
                        ForEach(today.meals) { meal in
                            mealCard(meal)
                        }
                    }
                    .padding()
                } else {
                    ContentUnavailableView("Нет плана", systemImage: "leaf", description: Text("Пройдите опрос"))
                }
            }
            .background(AppTheme.background)
            .navigationTitle("Сегодня")
        }
    }

    private func header(profile: UserProfile, plan: WeeklyPlan) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if let disease = DiseaseCatalog.byId(profile.diseaseId) {
                Text(disease.nameRu).font(.headline)
            }
            Text("Цель: \(plan.targetKcal) ккал · \(plan.mealsPerDay) приёма пищи")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            if profile.isBreastfeeding {
                Label("Грудное вскармливание (+350 ккал)", systemImage: "heart.fill")
                    .font(.caption)
                    .foregroundStyle(AppTheme.primary)
            }
            if profile.isInMenopause() {
                Label(profile.menopauseStatus.labelRu, systemImage: "figure.dress.line.vertical.figure")
                    .font(.caption)
                    .foregroundStyle(AppTheme.warning)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }

    private func waterCard(glasses: Int) -> some View {
        HStack {
            Image(systemName: "drop.fill").foregroundStyle(.blue)
            Text("Вода: \(glasses) стаканов в день")
            Spacer()
        }
        .cardStyle()
    }

    private func mealCard(_ meal: DayMeal) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(meal.mealType).font(.headline)
                Spacer()
                Text(meal.time).font(.caption).foregroundStyle(.secondary)
            }
            Text(meal.dishName).font(.subheadline)
            Text("\(meal.calories) ккал · Б \(meal.proteinG) · У \(meal.carbsG) · Ж \(meal.fatG)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .cardStyle()
    }
}
