import SwiftUI

struct RestrictionsView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let plan = appState.weeklyPlan, !plan.restrictionSummary.isEmpty {
                    ForEach(plan.restrictionSummary, id: \.self) { line in
                        Label(line, systemImage: "exclamationmark.triangle.fill")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.warning)
                            .cardStyle()
                    }
                }

                if let therapeutic = appState.therapeuticProfile {
                    nutrientsCard(therapeutic)
                }

                if let profile = appState.profile, !profile.allergenIds.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Аллергены").font(.headline)
                        ForEach(Array(profile.allergenIds), id: \.self) { id in
                            if let allergen = AllergenCatalog.byId(id) {
                                Text("• \(allergen.nameRu)")
                            }
                        }
                    }
                    .cardStyle()
                }

                MedicalDisclaimerBanner()
            }
            .padding()
        }
        .background(AppTheme.background)
        .navigationTitle("Ограничения")
    }

    private func nutrientsCard(_ t: TherapeuticNutritionProfile) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Нутриентные лимиты").font(.headline)
            LabeledContent("Соль", value: "до \(t.sodiumSaltGrams) г/день")
            LabeledContent("Сахар", value: "до \(t.addedSugarGMax) г")
            LabeledContent("Насыщ. жиры", value: "до \(t.saturatedFatGMax) г")
            LabeledContent("Клетчатка", value: "от \(t.fiberGMin) г")
            LabeledContent("Вода", value: t.waterLiters)
        }
        .cardStyle()
    }
}
