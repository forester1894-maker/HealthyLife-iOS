import SwiftUI

struct DiaryView: View {
    @EnvironmentObject private var appState: AppState
    @AppStorage("diary_notes") private var notes = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if let profile = appState.profile {
                        statsCard(profile: profile)
                    }
                    Text("Заметки дня").font(.headline)
                    TextEditor(text: $notes)
                        .frame(minHeight: 160)
                        .padding(8)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
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
}
