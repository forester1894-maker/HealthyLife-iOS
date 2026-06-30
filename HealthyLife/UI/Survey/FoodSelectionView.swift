import SwiftUI

struct FoodSelectionView: View {
    @Binding var draft: SurveyDraft
    let onComplete: (UserProfile) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""
    @State private var foods: [FoodItem] = FoodDatabase.shared.popular

    var body: some View {
        VStack {
            TextField("Поиск продуктов", text: $query)
                .padding(12)
                .background(AppTheme.container)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding()
                .onChange(of: query) { newValue in
                    foods = FoodDatabase.shared.search(newValue)
                }

            List(filteredFoods) { food in
                Button {
                    toggle(food.id)
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(food.name).font(.subheadline)
                            Text("\(food.calories) ккал / 100 г").font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        if draft.preferredFoodIds.contains(food.id) {
                            Image(systemName: "heart.fill").foregroundStyle(AppTheme.primary)
                        }
                    }
                }
            }

            Button("Сформировать план") {
                onComplete(buildProfile())
                dismiss()
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding()
            .disabled(draft.preferredFoodIds.count < 3)
        }
        .navigationTitle("Любимые продукты")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var filteredFoods: [FoodItem] {
        foods.filter { food in
            query.isEmpty || food.name.localizedCaseInsensitiveContains(query)
        }
    }

    private func toggle(_ id: String) {
        if draft.preferredFoodIds.contains(id) {
            draft.preferredFoodIds.remove(id)
        } else {
            draft.preferredFoodIds.insert(id)
        }
    }

    private func buildProfile() -> UserProfile {
        UserProfile(
            diseaseId: draft.diseaseId,
            age: Int(draft.age) ?? 30,
            gender: draft.gender,
            weightKg: Float(draft.weightKg) ?? 70,
            heightCm: Int(draft.heightCm) ?? 170,
            preferredFoodIds: draft.preferredFoodIds,
            symptomSeverity: draft.symptomSeverity,
            comorbidities: draft.comorbidities,
            calorieMode: draft.calorieMode,
            isBreastfeeding: draft.isBreastfeeding,
            menopauseStatus: draft.menopauseStatus,
            allergenIds: draft.allergenIds,
            surveyCompleted: true
        )
    }
}
