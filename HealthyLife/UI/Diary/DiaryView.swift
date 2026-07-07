import SwiftUI

struct DiaryView: View {
    @EnvironmentObject private var appState: AppState

    private var todayEntries: [FoodDiaryEntry] {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        let iso = f.string(from: Date())
        return appState.diaryEntries.filter { $0.dateIso == iso }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if let profile = appState.profile {
                        statsCard(profile: profile)
                    }
                    if let progress = appState.dailyProgress {
                        progressSummary(progress)
                    }

                    HStack {
                        Text("Записи за сегодня").font(.headline)
                        Spacer()
                        NavigationLink("Добавить") {
                            FoodSearchView()
                        }
                        .font(.subheadline.bold())
                    }

                    if todayEntries.isEmpty {
                        Text("Пока нет записей. Отметьте приём пищи на вкладке «Сегодня» или добавьте продукт.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .cardStyle()
                    } else {
                        ForEach(todayEntries) { entry in
                            entryRow(entry)
                        }
                    }
                }
                .padding()
            }
            .background(AppTheme.background)
            .navigationTitle("Дневник")
        }
    }

    private func statsCard(profile: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Ваши показатели").font(.headline)
            LabeledContent("ИМТ", value: String(format: "%.1f", profile.bmi))
            LabeledContent("Вес", value: "\(String(format: "%.1f", profile.weightKg)) кг")
            LabeledContent("Рост", value: "\(profile.heightCm) см")
            if let target = appState.weeklyPlan?.targetKcal {
                LabeledContent("Калории", value: "\(target) ккал/день")
            }
        }
        .cardStyle()
    }

    private func progressSummary(_ p: DailyProgress) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Итого за день").font(.headline)
            Text("\(Int(p.consumedKcal)) ккал · соблюдение \(p.adherencePercent)%")
                .foregroundStyle(.secondary)
        }
        .cardStyle()
    }

    private func entryRow(_ entry: FoodDiaryEntry) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.mealType).font(.caption).foregroundStyle(.secondary)
                Text(entry.foodName).font(.subheadline.bold())
                Text("\(Int(entry.calories)) ккал")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if entry.fromPlan {
                Image(systemName: "calendar").foregroundStyle(AppTheme.primary)
            }
            Button(role: .destructive) {
                appState.removeDiaryEntry(id: entry.id)
            } label: {
                Image(systemName: "trash")
            }
        }
        .cardStyle()
    }
}
