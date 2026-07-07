import Foundation

enum ComorbidityRulesEngine {
    static func buildRules(profile: UserProfile) -> [RestrictionRule] {
        var rules: [RestrictionRule] = []
        let active = profile.activeDiseaseIds()
        let therapeutic = TherapeuticNutritionEngine.profileFor(profile)

        if let disease = DiseaseCatalog.byId(profile.diseaseId) {
            rules.append(RestrictionRule(title: "Основное: \(disease.nameRu)",
                description: therapeutic.patternName, priority: 1))
        }

        if profile.isBreastfeeding {
            rules.append(RestrictionRule(title: "Грудное вскармливание",
                description: "Дополнительно +\(NutritionCalculator.lactationBonusKcal) ккал/сут, усиленный питьевой режим, без алкоголя.",
                priority: 1))
        }

        if profile.isInMenopause() {
            let proteinMin = MenopauseNutrition.proteinMinG(status: profile.menopauseStatus, weightKg: profile.weightKg)
            let calcium = MenopauseNutrition.calciumMg(status: profile.menopauseStatus)
            rules.append(RestrictionRule(title: profile.menopauseStatus.labelRu,
                description: "Белок ≥ \(proteinMin) г/сут, кальций \(calcium) мг/сут, витамин D \(MenopauseNutrition.vitaminDIU) МЕ/сут.",
                priority: 1))
        }

        if !profile.allergenIds.isEmpty {
            let names = profile.allergenIds.compactMap { AllergenCatalog.byId($0)?.nameRu }
            rules.append(RestrictionRule(title: "Пищевые аллергены",
                description: "Исключены из плана: \(names.joined(separator: ", "))", priority: 2))
        }

        if active.count > 1 {
            rules.append(RestrictionRule(title: "Сочетание \(active.count) состояний",
                description: "Применяются самые строгие лимиты по натрию, сахару и жирам одновременно", priority: 2))
        }

        rules += [
            RestrictionRule(title: "Натрий (соль)",
                description: "≤ \(therapeutic.sodiumMgMax) мг/сут (≈\(String(format: "%.1f", therapeutic.sodiumSaltGrams)) г соли).",
                priority: 3),
            RestrictionRule(title: "Добавленный сахар",
                description: "≤ \(therapeutic.addedSugarGMax) г/сут. Ограничить сладкие напитки, соки, выпечку.", priority: 3),
            RestrictionRule(title: "Насыщенные жиры",
                description: "< \(therapeutic.saturatedFatPercentMax)% калорий (≈\(therapeutic.saturatedFatGMax) г/сут).", priority: 3),
            RestrictionRule(title: "Вода",
                description: "\(therapeutic.waterLiters) (\(therapeutic.waterGlasses) стаканов). \(therapeutic.waterNote)", priority: 3),
            RestrictionRule(title: "Омега-3", description: therapeutic.omega3Guidance, priority: 4)
        ]

        if let potassium = therapeutic.potassiumGuidance {
            rules.append(RestrictionRule(title: "Калий", description: potassium, priority: 4))
        }
        if !therapeutic.fatBeneficial.isEmpty {
            rules.append(RestrictionRule(title: "Полезные жиры",
                description: therapeutic.fatBeneficial.joined(separator: "; "), priority: 4))
        }
        if !therapeutic.fatLimit.isEmpty {
            rules.append(RestrictionRule(title: "Ограничить",
                description: therapeutic.fatLimit.joined(separator: "; "), priority: 4))
        }
        if !therapeutic.fatAvoid.isEmpty {
            rules.append(RestrictionRule(title: "Исключить",
                description: therapeutic.fatAvoid.joined(separator: "; "), priority: 5))
        }
        if let perMeal = therapeutic.carbsPerMealGMax {
            rules.append(RestrictionRule(title: "Углеводы на приём",
                description: "≤ \(perMeal) г; предпочтение низкому ГИ", priority: 4))
        }
        if let max = therapeutic.proteinGMax {
            rules.append(RestrictionRule(title: "Белок",
                description: "≤ \(max) г/сут (почечная диета по стадии ХБП)", priority: 4))
        }

        for rule in therapeutic.clinicalRules {
            rules.append(RestrictionRule(title: rule.nutrient,
                description: "\(rule.target). \(rule.rationale) (\(rule.source))", priority: 5))
        }

        rules.append(RestrictionRule(title: "Источники", description: therapeutic.evidenceNote, priority: 10))

        var seen = Set<String>()
        return rules.filter { r in
            if seen.contains(r.title) { return false }
            seen.insert(r.title)
            return true
        }.sorted { $0.priority < $1.priority }
    }

    static func summaryLines(profile: UserProfile) -> [String] {
        buildRules(profile: profile).filter { $0.priority <= 5 }.map { "\($0.title): \($0.description)" }
    }
}
