import SwiftUI

struct PlanReadyView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(AppTheme.primary)

                Text("План готов!")
                    .font(.largeTitle.bold())

                if let plan = appState.weeklyPlan {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(plan.generatedForDisease).font(.headline)
                        Text("≈ \(plan.targetKcal) ккал в день · \(plan.mealsPerDay) приёма пищи")
                            .foregroundStyle(.secondary)
                        Text(plan.patternName)
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.primary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .cardStyle()
                }

                MedicalDisclaimerBanner()

                Button("Перейти к плану") {
                    appState.dismissPlanReady()
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding(24)
        }
        .background(AppTheme.background)
    }
}
