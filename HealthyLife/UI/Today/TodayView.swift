import SwiftUI

struct TodayView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationStack {
            ScrollView {
                if let profile = appState.profile, let plan = appState.weeklyPlan {
                    let dayIndex = appState.todayDayIndex()
                    let today = plan.days[dayIndex]
                    VStack(alignment: .leading, spacing: 16) {
                        if let notice = appState.licenseExpiryNotice {
                            Text(notice)
                                .font(.subheadline)
                                .foregroundStyle(AppTheme.warning)
                                .cardStyle()
                        }
                        if let progress = appState.dailyProgress {
                            progressCard(progress)
                        }
                        header(profile: profile, plan: plan)
                        waterCard(target: plan.waterGlasses)
                        ForEach(today.meals) { meal in
                            mealCard(meal)
                        }
                        MedicalDisclaimerBanner()
                    }
                    .padding()
                } else {
                    emptyState
                }
            }
            .background(AppTheme.background)
            .navigationTitle("Сегодня")
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "leaf")
                .font(.largeTitle)
                .foregroundStyle(AppTheme.primary)
            Text("Нет плана").font(.headline)
            Text("Пройдите опрос").foregroundStyle(.secondary)
        }
        .padding()
    }

    private func progressCard(_ p: DailyProgress) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Прогресс дня").font(.headline)
                Spacer()
                Text("\(p.adherencePercent)%").font(.title3.bold()).foregroundStyle(AppTheme.primary)
            }
            ProgressView(value: min(p.consumedKcal, Double(p.targetKcal)), total: Double(p.targetKcal))
                .tint(AppTheme.primary)
            Text("\(Int(p.consumedKcal)) / \(p.targetKcal) ккал")
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack {
                Label("\(p.waterGlasses)/\(p.waterTarget)", systemImage: "drop.fill")
                Spacer()
                Text("Б \(Int(p.proteinG)) · У \(Int(p.carbsG)) · Ж \(Int(p.fatG))")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .cardStyle()
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

    private func waterCard(target: Int) -> some View {
        HStack {
            Image(systemName: "drop.fill").foregroundStyle(.blue)
            Text("Вода: \(appState.waterGlassesToday) / \(target) стаканов")
            Spacer()
            Button("+1 стакан") { appState.addWaterGlass() }
                .font(.caption.bold())
        }
        .cardStyle()
    }

    private func mealCard(_ meal: DayMeal) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(meal.mealType).font(.headline)
                Spacer()
                Text(meal.time).font(.caption).foregroundStyle(.secondary)
            }
            Text(meal.dishName).font(.subheadline)
            Text("\(meal.calories) ккал · Б \(Int(meal.proteinG)) · У \(Int(meal.carbsG)) · Ж \(Int(meal.fatG))")
                .font(.caption)
                .foregroundStyle(.secondary)
            if !meal.ingredients.isEmpty {
                Text(meal.ingredients.prefix(4).joined(separator: ", "))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Button("Отметить съеденным") {
                appState.markMealEaten(meal)
            }
            .font(.caption.bold())
            .buttonStyle(.bordered)
            .tint(AppTheme.primary)
        }
        .cardStyle()
    }
}
