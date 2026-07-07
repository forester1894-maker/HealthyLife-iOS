import SwiftUI

struct SurveyView: View {
    @EnvironmentObject private var appState: AppState
    @State private var draft = SurveyDraft()
    @State private var showFoodSelection = false

    private let totalSteps = 5

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ProgressView(value: Double(draft.step + 1), total: Double(totalSteps))
                    .tint(AppTheme.primary)
                    .padding()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        stepContent
                    }
                    .padding()
                }

                HStack {
                    if draft.step > 0 {
                        Button("Назад") { draft.step -= 1 }
                            .buttonStyle(.bordered)
                    }
                    Spacer()
                    Button(draft.step == totalSteps - 1 ? "Далее" : "Продолжить") {
                        if draft.step == totalSteps - 1 {
                            showFoodSelection = true
                        } else {
                            draft.step += 1
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .frame(maxWidth: 200)
                    .disabled(!canProceed)
                }
                .padding()
            }
            .navigationTitle("Опрос")
            .navigationDestination(isPresented: $showFoodSelection) {
                FoodSelectionView(draft: $draft) { profile in
                    appState.completeSurvey(profile)
                }
            }
        }
    }

    @ViewBuilder
    private var stepContent: some View {
        switch draft.step {
        case 0: diseaseStep
        case 1: bodyStep
        case 2: comorbidityStep
        case 3: calorieStep
        case 4: extraStep
        default: EmptyView()
        }
    }

    private var diseaseStep: some View {
        Group {
            Text("Основное заболевание").font(.headline)
            ForEach(DiseaseCatalog.all) { disease in
                Button {
                    draft.diseaseId = disease.id
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(disease.nameRu).font(.subheadline.bold())
                            Text(disease.shortDescription).font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        if draft.diseaseId == disease.id {
                            Image(systemName: "checkmark.circle.fill").foregroundStyle(AppTheme.primary)
                        }
                    }
                    .cardStyle()
                }
                .buttonStyle(.plain)
            }
            severityPicker
        }
    }

    private var bodyStep: some View {
        Group {
            Text("Параметры тела").font(.headline)
            field("Возраст", text: $draft.age, keyboard: .numberPad)
            Picker("Пол", selection: $draft.gender) {
                ForEach(Gender.allCases) { g in Text(g.labelRu).tag(g) }
            }
            .pickerStyle(.segmented)
            field("Вес, кг", text: $draft.weightKg, keyboard: .decimalPad)
            field("Рост, см", text: $draft.heightCm, keyboard: .numberPad)
            if let w = Float(draft.weightKg), let h = Int(draft.heightCm), h > 0 {
                let bmi = w / pow(Float(h) / 100, 2)
                Text("ИМТ: \(String(format: "%.1f", bmi)) — \(NutritionCalculator.bmiCategory(bmi: bmi))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var comorbidityStep: some View {
        Group {
            Text("Сопутствующие состояния").font(.headline)
            Toggle("Сахарный диабет", isOn: $draft.comorbidities.hasDiabetes)
            if draft.comorbidities.hasDiabetes {
                Picker("Тип", selection: $draft.comorbidities.diabetesType) {
                    ForEach(DiabetesType.allCases.filter { $0 != .none }) { t in
                        Text(t.labelRu).tag(t)
                    }
                }
                Toggle("На инсулине", isOn: $draft.comorbidities.onInsulin)
            }
            Toggle("Гипертония", isOn: $draft.comorbidities.hasHypertension)
            Toggle("Подагра", isOn: $draft.comorbidities.hasGout)
            Toggle("ГЭРБ", isOn: $draft.comorbidities.hasGerd)
            Toggle("ХБП", isOn: $draft.comorbidities.hasCkd)
            Toggle("Дислипидемия", isOn: $draft.comorbidities.hasDyslipidemia)
            Toggle("Ожирение", isOn: $draft.comorbidities.hasObesityComorbid)
        }
    }

    private var calorieStep: some View {
        Group {
            Text("Режим калорий").font(.headline)
            Text("Поддержание: \(previews.first?.maintenanceKcal ?? 0) ккал")
                .font(.caption)
                .foregroundStyle(.secondary)
            ForEach(previews) { preview in
                Button {
                    if preview.allowed { draft.calorieMode = preview.mode }
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(preview.mode.labelRu).font(.subheadline.bold())
                            Text("≈ \(preview.targetKcal) ккал/день").font(.caption)
                            if let w = preview.warning {
                                Text(w).font(.caption2).foregroundStyle(AppTheme.warning)
                            }
                        }
                        Spacer()
                        if draft.calorieMode == preview.mode {
                            Image(systemName: "checkmark.circle.fill").foregroundStyle(AppTheme.primary)
                        }
                    }
                    .opacity(preview.allowed ? 1 : 0.5)
                    .cardStyle()
                }
                .buttonStyle(.plain)
                .disabled(!preview.allowed)
            }
        }
    }

    private var extraStep: some View {
        Group {
            Text("Дополнительно").font(.headline)
            if draft.gender == .female {
                Toggle("Грудное вскармливание", isOn: $draft.isBreastfeeding)
                Picker("Менопауза", selection: $draft.menopauseStatus) {
                    ForEach(MenopauseStatus.allCases) { s in Text(s.labelRu).tag(s) }
                }
            }
            NavigationLink("Аллергены (\(draft.allergenIds.count))") {
                AllergenPickerView(selected: $draft.allergenIds)
            }
        }
    }

    private var severityPicker: some View {
        VStack(alignment: .leading) {
            Text("Тяжесть симптомов").font(.subheadline.bold())
            Picker("Тяжесть", selection: $draft.symptomSeverity) {
                ForEach(SymptomSeverity.allCases) { s in Text(s.labelRu).tag(s) }
            }
            .pickerStyle(.menu)
        }
    }

    private var previews: [CaloriePreview] {
        NutritionCalculator.caloriePreviews(draft: draft)
    }

    private var canProceed: Bool {
        switch draft.step {
        case 0: return !draft.diseaseId.isEmpty
        case 1: return Int(draft.age) != nil && Float(draft.weightKg) != nil && Int(draft.heightCm) != nil
        default: return true
        }
    }

    private func field(_ title: String, text: Binding<String>, keyboard: UIKeyboardType) -> some View {
        VStack(alignment: .leading) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            TextField(title, text: text)
                .keyboardType(keyboard)
                .padding(12)
                .background(AppTheme.container)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}
