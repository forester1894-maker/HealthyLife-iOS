import Foundation

enum DailyProgressCalculator {
    static func calculate(
        profile: UserProfile,
        plan: WeeklyPlan?,
        entries: [FoodDiaryEntry],
        waterGlasses: Int,
        dateIso: String = DateHelpers.todayIso
    ) -> DailyProgress {
        let limits = TherapeuticNutritionEngine.limitsFor(profile)
        let target = plan?.regimen.dailyCalories ?? NutritionCalculator.targetCalories(profile: profile)
        let consumed = entries.reduce(0.0) { $0 + $1.calories }
        let protein = entries.reduce(0.0) { $0 + $1.protein }
        let carbs = entries.reduce(0.0) { $0 + $1.carbs }
        let fat = entries.reduce(0.0) { $0 + $1.fat }
        let sodium = entries.reduce(0.0) { $0 + $1.sodiumMg }
        let sugar = entries.reduce(0.0) { $0 + $1.sugarG }
        let satFat = entries.reduce(0.0) { $0 + $1.saturatedFatG }

        let kcalAdherence = target > 0
            ? max(0, min(100, 100 - Int(abs(consumed - Double(target)) / Double(target) * 100)))
            : 0
        let nutrientScores = [
            nutrientScore(value: sodium, limit: Double(limits.maxSodiumMg)),
            nutrientScore(value: sugar, limit: Double(limits.maxAddedSugarG)),
            nutrientScore(value: satFat, limit: Double(limits.maxSaturatedFatG)),
            nutrientScore(value: Double(waterGlasses), limit: Double(limits.waterGlasses), higherIsBetter: true)
        ]
        let adherence = max(0, min(100, (kcalAdherence + nutrientScores.reduce(0, +) / nutrientScores.count) / 2))

        return DailyProgress(
            dateIso: dateIso, targetKcal: target, consumedKcal: consumed,
            proteinG: protein, carbsG: carbs, fatG: fat,
            sodiumMg: sodium, sugarG: sugar, saturatedFatG: satFat,
            waterGlasses: waterGlasses, waterTarget: limits.waterGlasses,
            sodiumTargetMg: limits.maxSodiumMg, sugarTargetG: limits.maxAddedSugarG,
            saturatedFatTargetG: limits.maxSaturatedFatG, adherencePercent: adherence
        )
    }

    private static func nutrientScore(value: Double, limit: Double, higherIsBetter: Bool = false) -> Int {
        if limit <= 0 { return 100 }
        let ratio = value / limit
        if higherIsBetter {
            if ratio >= 1.0 { return 100 }
            return max(0, min(100, Int(ratio * 100)))
        }
        if ratio <= 0.7 { return 100 }
        if ratio <= 1.0 { return max(0, Int(100 - (ratio - 0.7) / 0.3 * 30)) }
        return max(0, min(70, Int(70 - (ratio - 1.0) * 50)))
    }
}

enum DateHelpers {
    static var todayIso: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f.string(from: Date())
    }

    static func todayDayIndex() -> Int {
        let weekday = Calendar.current.component(.weekday, from: Date())
        return weekday == 1 ? 6 : weekday - 2
    }
}
