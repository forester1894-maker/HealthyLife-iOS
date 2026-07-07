import Foundation

enum WeeklyPlanGenerator {
    private static let dayNames = ["Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота", "Воскресенье"]

    static func generate(for profile: UserProfile, shuffleSeed: Int? = nil) -> WeeklyPlan {
        guard let disease = DiseaseCatalog.byId(profile.diseaseId) else {
            fatalError("Заболевание не найдено")
        }
        let targetKcal = NutritionCalculator.targetCalories(profile: profile)
        let mealsPerDay = NutritionCalculator.mealsPerDay(profile: profile)
        let activeIds = profile.activeDiseaseIds()
        let therapeutic = TherapeuticNutritionEngine.profileFor(profile)

        let regimen = buildRegimen(profile: profile, pattern: disease.dietPattern,
                                   kcal: targetKcal, meals: mealsPerDay, therapeutic: therapeutic)
        let days = dayNames.enumerated().map { index, name in
            buildDayPlan(dayIndex: index, dayName: name, profile: profile,
                         targetKcal: targetKcal, mealsPerDay: mealsPerDay, shuffleSeed: shuffleSeed)
        }
        let activity = ActivityPlanGenerator.generate(profile: profile)
        let restrictions = ComorbidityRulesEngine.summaryLines(profile: profile)

        let comorbidNames = activeIds.filter { $0 != profile.diseaseId }
            .compactMap { DiseaseCatalog.byId($0)?.nameRu }
        var title = disease.nameRu
        if !comorbidNames.isEmpty {
            title += " + " + comorbidNames.joined(separator: ", ")
        }

        var plan = WeeklyPlan(
            regimen: regimen, days: days,
            activityPlan: activity.days, activitySummary: activity.summary,
            generatedForDisease: title,
            disclaimer: "План носит рекомендательный характер. Согласуйте рацион и нагрузку с лечащим врачом.",
            shoppingList: [], restrictionSummary: restrictions
        )
        plan.shoppingList = ShoppingListGenerator.generate(plan: plan)
        return plan
    }

    static func swapMeal(plan: WeeklyPlan, profile: UserProfile, dayIndex: Int, mealIndex: Int) -> WeeklyPlan {
        guard dayIndex < plan.days.count else { return plan }
        let day = plan.days[dayIndex]
        guard mealIndex < day.meals.count else { return plan }
        let meal = day.meals[mealIndex]
        guard let alt = MealTemplateCatalog.nextAlternative(
            mealType: meal.mealType, profile: profile, currentTemplateId: meal.templateId
        ) else { return plan }

        var newMeals = day.meals
        newMeals[mealIndex] = MealTemplateCatalog.toDayMeal(alt)
        let scaled = MealNutritionScaler.scaleMealsToTarget(newMeals, target: plan.regimen.dailyCalories)
        var newDays = plan.days
        newDays[dayIndex] = DayPlan(dayName: day.dayName, dayIndex: day.dayIndex,
                                    meals: scaled, dailyCalories: scaled.reduce(0) { $0 + $1.calories })
        var updated = plan
        updated.days = newDays
        updated.shoppingList = ShoppingListGenerator.generate(plan: updated)
        return updated
    }

    private static func buildRegimen(
        profile: UserProfile, pattern: String, kcal: Int, meals: Int,
        therapeutic: TherapeuticNutritionProfile
    ) -> NutritionRegimen {
        let bmi = NutritionCalculator.bmiCategory(bmi: profile.bmi)
        let maintenance = NutritionCalculator.maintenanceCalories(profile: profile)
        let active = profile.activeDiseaseIds()
        return NutritionRegimen(
            dailyCalories: kcal, mealsPerDay: meals,
            mealIntervalHours: meals >= 5 ? "каждые 2,5–3 часа" : "каждые 3–4 часа",
            waterLiters: "\(therapeutic.waterLiters) (\(therapeutic.waterGlasses) стаканов)",
            patternName: therapeutic.patternName.isEmpty ? pattern : therapeutic.patternName,
            macroSummary: buildMacroSummary(therapeutic: therapeutic, active: active),
            keyRules: buildKeyRules(profile: profile, therapeutic: therapeutic, bmi: bmi,
                                    maintenance: maintenance, kcal: kcal, meals: meals, active: active)
        )
    }

    private static func buildKeyRules(
        profile: UserProfile, therapeutic: TherapeuticNutritionProfile,
        bmi: String, maintenance: Int, kcal: Int, meals: Int, active: Set<String>
    ) -> [String] {
        var rules = [
            "ИМТ: \(String(format: "%.1f", profile.bmi)) (\(bmi))",
            "Поддержание: ~\(maintenance) ккал → цель: \(kcal) ккал (\(profile.calorieMode.labelRu))",
            "Приёмов пищи: \(meals)",
            "Учтено заболеваний: \(active.count)",
            "Натрий: ≤ \(therapeutic.sodiumMgMax) мг/сут (≈\(String(format: "%.1f", therapeutic.sodiumSaltGrams)) г соли)",
            "Добавленный сахар: ≤ \(therapeutic.addedSugarGMax) г/сут",
            "Насыщенные жиры: < \(therapeutic.saturatedFatPercentMax)% ккал (≈\(therapeutic.saturatedFatGMax) г)",
            "Вода: \(therapeutic.waterLiters). \(therapeutic.waterNote)",
            "Омега-3: \(therapeutic.omega3Guidance)"
        ]
        if let carbs = therapeutic.carbsPerMealGMax { rules.append("Углеводы на приём: ≤ \(carbs) г") }
        if let protein = therapeutic.proteinGMax { rules.append("Белок: ≤ \(protein) г/сут") }
        if !therapeutic.fatBeneficial.isEmpty {
            rules.append("Полезные жиры: \(therapeutic.fatBeneficial.prefix(2).joined(separator: "; "))")
        }
        if !therapeutic.fatAvoid.isEmpty {
            rules.append("Исключить: \(therapeutic.fatAvoid.joined(separator: "; "))")
        }
        return rules
    }

    private static func buildMacroSummary(therapeutic: TherapeuticNutritionProfile, active: Set<String>) -> String {
        var parts = ["Натрий ≤\(therapeutic.sodiumMgMax) мг; сахар ≤\(therapeutic.addedSugarGMax) г",
                     "НЖ <\(therapeutic.saturatedFatPercentMax)% ккал"]
        if active.contains("masld") { parts.append("средиземноморский паттерн; без трансжиров и алкоголя") }
        if active.contains("hypertension") { parts.append("DASH; несолёные орехи") }
        if active.contains("type2_diabetes") { parts.append("низкий ГИ") }
        if active.contains("dyslipidemia") { parts.append("омега-3, MUFA") }
        return parts.joined(separator: "; ")
    }

    private static func buildDayPlan(
        dayIndex: Int, dayName: String, profile: UserProfile,
        targetKcal: Int, mealsPerDay: Int, shuffleSeed: Int?
    ) -> DayPlan {
        let mealTypes = mealsPerDay == 5
            ? ["Завтрак", "Перекус", "Обед", "Полдник", "Ужин"]
            : ["Завтрак", "Обед", "Перекус", "Ужин"]
        let selected = mealTypes.map { pickMeal(mealType: $0, profile: profile, dayIndex: dayIndex, shuffleSeed: shuffleSeed) }
        let scaled = MealNutritionScaler.scaleMealsToTarget(selected, target: targetKcal)
        return DayPlan(dayName: dayName, dayIndex: dayIndex, meals: scaled,
                       dailyCalories: scaled.reduce(0) { $0 + $1.calories })
    }

    private static func pickMeal(mealType: String, profile: UserProfile, dayIndex: Int, shuffleSeed: Int?) -> DayMeal {
        let pool = MealTemplateCatalog.eligibleFor(mealType: mealType, profile: profile)
        if pool.isEmpty {
            let fallback = MealTemplateCatalog.all.first { $0.mealType == mealType }!
            return MealTemplateCatalog.toDayMeal(fallback)
        }
        let preferred = pool.filter { t in t.foodTags.contains(where: { profile.preferredFoodIds.contains($0) }) }
        let candidates = preferred.count >= 3 ? preferred : pool
        let baseIndex = dayIndex + mealType.hashValue
        let index: Int
        if let seed = shuffleSeed {
            index = (baseIndex + seed + mealType.count) % candidates.count
        } else {
            index = baseIndex % candidates.count
        }
        return MealTemplateCatalog.toDayMeal(candidates[index])
    }
}

struct ActivityPlanResult {
    let days: [ActivityDay]
    let summary: String
}

enum ActivityPlanGenerator {
    private static let dayNames = ["Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота", "Воскресенье"]

    static func generate(profile: UserProfile) -> ActivityPlanResult {
        let level = resolveActivityLevel(profile: profile)
        let days = dayNames.enumerated().map { index, name in
            buildActivityDay(name: name, index: index, level: level, diseaseId: profile.diseaseId)
        }
        return ActivityPlanResult(days: days, summary: level.summary)
    }

    private enum ActivityLevel {
        case rest, light, moderate
        var summary: String {
            switch self {
            case .rest: return "При выраженных симптомах физическая активность ограничена."
            case .light: return "Рекомендуется лёгкая активность: ходьба 20–30 мин, йога."
            case .moderate: return "Умеренная активность: 150 минут в неделю по рекомендациям ВОЗ."
            }
        }
    }

    private static func resolveActivityLevel(profile: UserProfile) -> ActivityLevel {
        if profile.symptomSeverity == .severe { return .rest }
        let active = profile.activeDiseaseIds()
        if active.contains(where: { ["peptic_ulcer", "gastritis"].contains($0) }) && profile.symptomSeverity == .moderate {
            return .light
        }
        if active.contains(where: { ["ckd", "ibs"].contains($0) }) { return .light }
        if active.contains("gout") && profile.symptomSeverity == .moderate { return .light }
        if active.contains("gerd") { return .moderate }
        return .moderate
    }

    private static func buildActivityDay(name: String, index: Int, level: ActivityLevel, diseaseId: String) -> ActivityDay {
        if level == .rest {
            return ActivityDay(dayName: name, allowed: false, activityType: "Отдых / лёгкая прогулка дома",
                durationMinutes: 10, intensity: "Минимальная",
                notes: ["При обострении — только по согласованию с врачом", "Дыхательная гимнастика 5–10 мин"])
        }
        let isRestDay = index == 6 || (level == .moderate && index == 3)
        if isRestDay {
            return ActivityDay(dayName: name, allowed: true,
                activityType: "Восстановительная прогулка / растяжка",
                durationMinutes: 20, intensity: "Низкая",
                notes: ["День отдыха от интенсивных нагрузок"])
        }
        switch level {
        case .light:
            return ActivityDay(dayName: name, allowed: true,
                activityType: index % 2 == 0 ? "Ходьба" : "Йога / растяжка",
                durationMinutes: 25, intensity: "Низкая", notes: lightNotes(diseaseId: diseaseId))
        case .moderate:
            let activity: String
            switch index % 3 {
            case 0: activity = "Быстрая ходьба"
            case 1: activity = "Плавание / велосипед"
            default: activity = "Силовая с собственным весом"
            }
            return ActivityDay(dayName: name, allowed: true, activityType: activity,
                durationMinutes: 35, intensity: "Умеренная", notes: moderateNotes(diseaseId: diseaseId))
        case .rest:
            fatalError("unreachable")
        }
    }

    private static func lightNotes(diseaseId: String) -> [String] {
        switch diseaseId {
        case "gerd": return ["Не заниматься в течение 2–3 ч после еды"]
        case "peptic_ulcer", "gastritis": return ["Избегать упражнений с давлением на пресс"]
        case "ckd": return ["Контроль пульса, согласование с нефрологом"]
        default: return ["Слушайте тело, при дискомфорте — остановитесь"]
        }
    }

    private static func moderateNotes(diseaseId: String) -> [String] {
        switch diseaseId {
        case "masld", "obesity": return ["Цель: 150 мин/нед умеренной активности (ВОЗ)"]
        case "type2_diabetes": return ["Проверяйте сахар до и после нагрузки при необходимости"]
        case "hypertension": return ["Избегайте задержки дыхания при силовых упражнениях"]
        case "gerd": return ["Тренировка не ранее чем за 3 ч до сна"]
        default: return ["Разминка 5 мин, заминка 5 мин"]
        }
    }
}
