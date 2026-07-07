import SwiftUI

struct DiseaseListView: View {
    var body: some View {
        List(DiseaseCatalog.all) { disease in
            NavigationLink(value: disease.id) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(disease.nameRu).font(.subheadline.bold())
                    Text(disease.shortDescription).font(.caption).foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Заболевания")
        .navigationDestination(for: String.self) { id in
            DiseaseDetailView(diseaseId: id)
        }
    }
}

struct DiseaseDetailView: View {
    let diseaseId: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let disease = DiseaseCatalog.byId(diseaseId) {
                    Text(disease.nameRu).font(.title2.bold())
                    Text(disease.shortDescription).foregroundStyle(.secondary)
                    Text(disease.dietPattern)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.primary)
                        .cardStyle()
                }

                if let info = DiseaseDetailData.info(for: diseaseId) {
                    section("Цели", info.keyGoals)
                    section("Рекомендуется", info.recommendedFoods)
                    section("Ограничить", info.limitFoods)
                    section("Образ жизни", info.lifestyleTips)
                    Text(info.macroGuidance).font(.footnote).foregroundStyle(.secondary)
                } else {
                    Text("Подробные рекомендации для этого заболевания — в вашем персональном плане.")
                        .foregroundStyle(.secondary)
                }

                MedicalDisclaimerBanner()
            }
            .padding()
        }
        .background(AppTheme.background)
        .navigationTitle("Справка")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func section(_ title: String, _ items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            ForEach(items, id: \.self) { item in
                Label(item, systemImage: "circle.fill")
                    .font(.caption)
                    .labelStyle(.titleAndIcon)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.primary, AppTheme.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }
}
