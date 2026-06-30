import Foundation

enum NutritionCalculator {
    static let lactationBonusKcal = 350

    static func bmr(weightKg: Float, heightCm: Int, age: Int, gender: Gender) -> Int {
        let h = Float(heightCm)
        let a = Float(age)
        let raw: Float
        switch gender {
        case .male: raw = 10 * weightKg + 6.25 * h - 5 * a + 5
        case .female: raw = 10 * weightKg + 6.25 * h - 5 * a - 161
        }
        return Int(raw.rounded())
    }

    static func bmr(profile: UserProfile) -> Int {
        bmr(weightKg: profile.weightKg, heightCm: profile.heightCm, age: profile.age, gender: profile.gender)
    }

    static func maintenanceCalories(profile: UserProfile) -> Int {
        Int((Float(bmr(profile: profile)) * 1.35).rounded())
    }

    static func lactationBonusKcal(profile: UserProfile) -> Int {
        profile.isBreastfeeding ? lactationBonusKcal : 0
    }

    static func minimumSafeCalories(profile: UserProfile) -> Int {
        var min = profile.gender == .female ? 1200 : 1500
        if profile.comorbidities.hasCkd { min = max(min, 1300) }
        if profile.symptomSeverity == .severe { min = max(min, 1400) }
        if profile.bmi < 18.5 { min = max(min, maintenanceCalories(profile: profile)) }
        if profile.isBreastfeeding {
            min = max(min, maintenanceCalories(profile: profile) + 200)
        }
        if profile.isInMenopause() && profile.menopauseStatus == .postmenopause {
            min = max(min, maintenanceCalories(profile: profile) - 500)
        }
        return min
    }

    static func targetCalories(profile: UserProfile) -> Int {
        let maintenance = maintenanceCalories(profile: profile) + lactationBonusKcal(profile: profile)
        let raw = maintenance - profile.calorieMode.deficitKcal
        return max(raw, minimumSafeCalories(profile: profile))
    }

    static func isCalorieModeAllowed(profile: UserProfile, mode: CalorieMode) -> (Bool, String?) {
        let maintenance = maintenanceCalories(profile: profile) + lactationBonusKcal(profile: profile)
        let target = max(maintenance - mode.deficitKcal, 0)
        let min = minimumSafeCalories(profile: profile)

        if profile.isBreastfeeding {
            if mode == .riskyDeficit || mode == .strongDeficit {
                return (false, "При грудном вскармливании сильный дефицит небезопасен")
            }
            if mode == .moderateDeficit {
                return (true, "При ГВ дефицит — только по согласованию с врачом")
            }
        }

        if profile.isInMenopause() {
            if mode == .riskyDeficit {
                return (false, "При менопаузе резкий дефицит повышает риск потери костной массы")
            }
            if mode == .strongDeficit {
                return (false, "При менопаузе сильный дефицит не рекомендуется")
            }
        }

        if mode == .riskyDeficit {
            if profile.comorbidities.hasCkd { return (false, "При ХБП опасный дефицит не допускается") }
            if profile.comorbidities.diabetesType == .type1 {
                return (false, "При диабете 1 типа опасный дефицит не допускается")
            }
            if profile.symptomSeverity == .severe {
                return (false, "При выраженных симптомах выберите более мягкий режим")
            }
            if profile.bmi < 25 { return (false, "При нормальном/низком ИМТ опасный дефицит не рекомендуется") }
            return (true, "Только под наблюдением врача")
        }

        if target < min {
            return (false, "Цель \(target) ккал ниже безопасного минимума (\(min) ккал)")
        }

        if !mode.isRecommended {
            return (true, "Режим возможен, но требует согласования с врачом")
        }
        return (true, nil)
    }

    static func caloriePreviews(draft: SurveyDraft) -> [CaloriePreview] {
        guard let weight = Float(draft.weightKg),
              let height = Int(draft.heightCm),
              let age = Int(draft.age),
              !draft.diseaseId.isEmpty else { return [] }

        let profile = UserProfile(
            diseaseId: draft.diseaseId,
            age: age,
            gender: draft.gender,
            weightKg: weight,
            heightCm: height,
            preferredFoodIds: draft.preferredFoodIds,
            symptomSeverity: draft.symptomSeverity,
            comorbidities: draft.comorbidities,
            calorieMode: draft.calorieMode,
            isBreastfeeding: draft.isBreastfeeding,
            menopauseStatus: draft.menopauseStatus,
            allergenIds: draft.allergenIds
        )

        let maintenance = Int((Float(bmr(weightKg: weight, heightCm: height, age: age, gender: draft.gender)) * 1.35).rounded())
        let lactation = draft.isBreastfeeding ? lactationBonusKcal : 0

        return CalorieMode.allCases.map { mode in
            let allowed = isCalorieModeAllowed(profile: profile, mode: mode)
            let target = max(maintenance + lactation - mode.deficitKcal, minimumSafeCalories(profile: profile))
            return CaloriePreview(
                maintenanceKcal: maintenance + lactation,
                mode: mode,
                targetKcal: target,
                allowed: allowed.0,
                warning: allowed.1
            )
        }
    }

    static func mealsPerDay(profile: UserProfile) -> Int {
        let ids = profile.activeDiseaseIds()
        if profile.isBreastfeeding || profile.isInMenopause() { return 5 }
        if ids.contains(where: { ["peptic_ulcer", "gastritis", "gerd", "ibs"].contains($0) }) { return 5 }
        return 4
    }

    static func bmiCategory(bmi: Float) -> String {
        switch bmi {
        case ..<18.5: return "Недостаточная масса"
        case ..<25: return "Норма"
        case ..<30: return "Избыточная масса"
        default: return "Ожирение"
        }
    }
}
