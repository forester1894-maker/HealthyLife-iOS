import Foundation

enum TherapeuticNutritionEngine {
    static func profileFor(_ user: UserProfile) -> TherapeuticNutritionProfile {
        let active = user.activeDiseaseIds()
        let protocols = active.compactMap { DiseaseNutrientProtocols.byId[$0] }
        let targetKcal = NutritionCalculator.targetCalories(profile: user)

        let sodium = protocols.compactMap(\.sodiumMgMax).min() ?? 2300
        let sugar = protocols.compactMap(\.addedSugarGMax).min() ?? 30
        let satFatPercent = protocols.compactMap(\.saturatedFatPercentMax).min() ?? 10
        let satFatG = Int((Float(targetKcal) * Float(satFatPercent) / 100 / 9).rounded())
        let carbsMeal = protocols.compactMap(\.carbsPerMealGMax).min()
            ?? (user.comorbidities.onInsulin ? 45 : nil)
        let proteinMax = computeProteinMax(user: user, protocols: protocols)
        let fiber = protocols.compactMap(\.fiberGMin).max() ?? 25

        let waterGlasses = computeWaterGlasses(active: active, protocols: protocols)
        let waterLiters = computeWaterLiters(active: active, protocols: protocols)
        let waterNote = buildWaterNote(active: active, protocols: protocols)

        let fatBeneficial = Array(Set(protocols.flatMap(\.fatBeneficial)))
        let fatLimit = Array(Set(protocols.flatMap(\.fatLimit)))
        let fatAvoid = Array(Set(protocols.flatMap(\.fatAvoid)))
        let omega3 = protocols.compactMap(\.omega3Guidance).joined(separator: " ")
            .ifEmpty(default: "Омега-3: жирная рыба 2 раза в неделю")
        let potassium = protocols.compactMap(\.potassiumGuidance).first

        let rules = buildMergedRules(protocols: protocols, sodium: sodium, sugar: sugar,
                                     satFatG: satFatG, satFatPercent: satFatPercent,
                                     water: waterLiters, active: active)
        let pattern = protocols.map(\.patternName).joined(separator: " + ")
            .ifEmpty(default: "Лечебное питание")
        let evidence = protocols.map(\.evidence).filter { !$0.isEmpty }.joined(separator: "; ")

        var profile = TherapeuticNutritionProfile(
            sodiumMgMax: sodium, sodiumSaltGrams: Float(sodium) / 400,
            addedSugarGMax: sugar, saturatedFatGMax: satFatG, saturatedFatPercentMax: satFatPercent,
            carbsPerMealGMax: carbsMeal, proteinGMax: proteinMax, fiberGMin: fiber,
            waterGlasses: waterGlasses, waterLiters: waterLiters, waterNote: waterNote,
            fatBeneficial: fatBeneficial.isEmpty ? defaultFatBeneficial() : fatBeneficial,
            fatLimit: fatLimit.isEmpty ? defaultFatLimit() : fatLimit,
            fatAvoid: fatAvoid.isEmpty ? ["Трансжиры"] : fatAvoid,
            omega3Guidance: omega3, potassiumGuidance: potassium,
            clinicalRules: rules, patternName: pattern,
            evidenceNote: evidence.isEmpty ? "Клинические рекомендации; согласуйте с врачом" : evidence
        )

        if user.isBreastfeeding {
            profile = applyBreastfeeding(profile, pattern: pattern)
        }
        if user.isInMenopause() {
            profile = applyMenopauseAdjustments(profile, user: user)
        }
        return profile
    }

    static func limitsFor(_ user: UserProfile) -> DailyNutrientLimits {
        let p = profileFor(user)
        return DailyNutrientLimits(
            maxSodiumMg: p.sodiumMgMax, maxAddedSugarG: p.addedSugarGMax,
            maxSaturatedFatG: p.saturatedFatGMax, maxCarbsPerMealG: p.carbsPerMealGMax,
            maxProteinG: p.proteinGMax, minFiberG: p.fiberGMin,
            waterGlasses: p.waterGlasses, waterLiters: p.waterLiters
        )
    }

    private static func applyBreastfeeding(_ base: TherapeuticNutritionProfile, pattern: String) -> TherapeuticNutritionProfile {
        var p = base
        p.waterGlasses = max(p.waterGlasses, 10)
        p.waterLiters = "2,3–2,7"
        p.waterNote = "При ГВ увеличьте питьевой режим (+~700 мл/сут, CDC). Пейте по жажде."
        p.patternName = pattern.isEmpty ? "Питание при грудном вскармливании" : "\(pattern) + период лактации"
        p.clinicalRules += [
            TherapeuticNutrientRule(nutrient: "Энергия лактации",
                target: "+\(NutritionCalculator.lactationBonusKcal) ккал/сут к норме",
                rationale: "Дополнительные потребности при ГВ", source: "CDC"),
            TherapeuticNutrientRule(nutrient: "Алкоголь", target: "Исключить",
                rationale: "Проникает в грудное молоко", source: "CDC Breastfeeding")
        ]
        p.evidenceNote += "; ГВ: CDC, USDA DGA"
        return p
    }

    private static func applyMenopauseAdjustments(_ base: TherapeuticNutritionProfile, user: UserProfile) -> TherapeuticNutritionProfile {
        let status = user.menopauseStatus
        let proteinMinG = MenopauseNutrition.proteinMinG(status: status, weightKg: user.weightKg)
        let calciumMg = MenopauseNutrition.calciumMg(status: status)
        let statusLabel = status.labelRu.lowercased()

        var menopauseRules = [
            TherapeuticNutrientRule(nutrient: "Белок", target: "≥ \(proteinMinG) г/сут (1,0–1,2 г/кг)",
                rationale: "Сохранение мышечной массы при \(statusLabel)", source: "PROT-AGE; ESPEN"),
            TherapeuticNutrientRule(nutrient: "Кальций", target: "\(calciumMg) мг/сут",
                rationale: "Снижение риска остеопороза", source: "IOM"),
            TherapeuticNutrientRule(nutrient: "Витамин D",
                target: "\(MenopauseNutrition.vitaminDIU) МЕ (\(MenopauseNutrition.vitaminDMcg) мкг)/сут",
                rationale: "Всасывание кальция и здоровье костей", source: "IOM"),
            TherapeuticNutrientRule(nutrient: "Кофеин", target: "≤ \(MenopauseNutrition.caffeineMgMax) мг/сут",
                rationale: "Избыток может усиливать приливы", source: "NAMS; EFSA")
        ]
        if status == .postmenopause {
            menopauseRules.append(TherapeuticNutrientRule(nutrient: "Железо",
                target: "Сниженная потребность (~8 мг/сут)",
                rationale: "После прекращения менструаций", source: "IOM"))
        }

        let suffix = status == .perimenopause ? "перименопауза" : "постменопауза"
        var p = base
        p.fiberGMin = max(p.fiberGMin, 25)
        p.patternName = p.patternName.isEmpty ? "Питание при \(suffix)" : "\(p.patternName) + \(suffix)"
        p.clinicalRules += menopauseRules
        p.evidenceNote += "; менопауза: IOM, NAMS, PROT-AGE"
        return p
    }

    private static func computeProteinMax(user: UserProfile, protocols: [DiseaseNutrientProtocol]) -> Int? {
        if let perKg = protocols.compactMap(\.proteinGPerKgMax).min() {
            return Int((perKg * user.weightKg).rounded())
        }
        if user.activeDiseaseIds().contains("ckd") {
            let stage = Int(user.comorbidities.ckdStage) ?? 3
            if stage >= 4 { return Int((0.6 * user.weightKg).rounded()) }
            if stage == 3 { return Int((0.8 * user.weightKg).rounded()) }
        }
        return nil
    }

    private static func computeWaterGlasses(active: Set<String>, protocols: [DiseaseNutrientProtocol]) -> Int {
        if active.contains("ckd") { return protocols.compactMap(\.waterGlasses).min() ?? 5 }
        if active.contains("hypertension") { return 6 }
        if active.contains("gout") { return 10 }
        return protocols.compactMap(\.waterGlasses).min() ?? 8
    }

    private static func computeWaterLiters(active: Set<String>, protocols: [DiseaseNutrientProtocol]) -> String {
        if active.contains("ckd") { return "1–1,5 л (по нефрологу)" }
        if active.contains("hypertension") && !active.contains("masld") { return "1,5–2 л" }
        if active.contains("hypertension") { return "1,5–2 л (соль важнее объёма воды)" }
        if active.contains("gout") { return "2–2,5 л" }
        return protocols.compactMap(\.waterLiters).first ?? "1,5–2,5 л"
    }

    private static func buildWaterNote(active: Set<String>, protocols: [DiseaseNutrientProtocol]) -> String {
        if active.contains("hypertension") {
            let sodium = protocols.first { $0.diseaseId == "hypertension" }?.sodiumMgMax ?? 1500
            return "При гипертонии главное — натрий ≤\(sodium) мг/сут. Вода умеренная."
        }
        return protocols.compactMap(\.waterNote).first ?? "Равномерно в течение дня, больше при физнагрузке"
    }

    private static func buildMergedRules(
        protocols: [DiseaseNutrientProtocol], sodium: Int, sugar: Int,
        satFatG: Int, satFatPercent: Int, water: String, active: Set<String>
    ) -> [TherapeuticNutrientRule] {
        var global = [
            TherapeuticNutrientRule(nutrient: "Натрий (соль)",
                target: "≤\(sodium) мг/сут (≈\(String(format: "%.1f", Float(sodium) / 400)) г соли)",
                rationale: active.contains("hypertension") ? "DASH: снижение АД" : "Ограничение скрытой соли",
                source: active.contains("hypertension") ? "AHA DASH" : "WHO"),
            TherapeuticNutrientRule(nutrient: "Добавленный сахар", target: "≤\(sugar) г/сут",
                rationale: "Контроль гликемии и стеатоза", source: "WHO/ADA"),
            TherapeuticNutrientRule(nutrient: "Насыщенные жиры",
                target: "<\(satFatPercent)% калорий (≈\(satFatG) г/сут)",
                rationale: active.contains("masld") ? "Ключевой параметр при жировом гепатозе" : "Сердечно-сосудистый риск",
                source: active.contains("masld") ? "EASL MASLD" : "AHA"),
            TherapeuticNutrientRule(nutrient: "Вода", target: water,
                rationale: active.contains("hypertension") ? "Умеренно; не заменяет ограничение соли" : "Поддержание обмена",
                source: "Clinical")
        ]
        if active.contains("masld") {
            global += [
                TherapeuticNutrientRule(nutrient: "Трансжиры", target: "Исключить",
                    rationale: "Прямой вред при МАЖБП", source: "EASL 2024"),
                TherapeuticNutrientRule(nutrient: "Омега-3", target: "2–3 порции рыбы/нед",
                    rationale: "Снижение ТГ и воспаления", source: "EASL/EASD")
            ]
        }
        let fromProtocols = protocols.flatMap(\.rules)
        var seen = Set<String>()
        return (fromProtocols + global).filter { rule in
            let key = rule.nutrient + rule.target
            if seen.contains(key) { return false }
            seen.insert(key)
            return true
        }
    }

    private static func defaultFatBeneficial() -> [String] {
        ["Оливковое масло (MUFA)", "Жирная рыба (омега-3)", "Орехи, семена"]
    }

    private static func defaultFatLimit() -> [String] {
        ["Насыщенные жиры", "Промышленная выпечка"]
    }
}

private extension String {
    func ifEmpty(default defaultValue: String) -> String {
        isEmpty ? defaultValue : self
    }
}
