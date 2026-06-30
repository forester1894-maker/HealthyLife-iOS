import Foundation

enum Gender: String, Codable, CaseIterable, Identifiable {
    case male, female
    var id: String { rawValue }
    var labelRu: String { self == .male ? "Мужской" : "Женский" }
}

enum MenopauseStatus: String, Codable, CaseIterable, Identifiable {
    case none, perimenopause, postmenopause
    var id: String { rawValue }
    var labelRu: String {
        switch self {
        case .none: return "Нет / не актуально"
        case .perimenopause: return "Перименопауза"
        case .postmenopause: return "Постменопауза"
        }
    }
    var shortHintRu: String {
        switch self {
        case .none: return ""
        case .perimenopause: return "Нерегулярные циклы, приливы"
        case .postmenopause: return "12 месяцев и более без менструации"
        }
    }
}

enum SymptomSeverity: String, Codable, CaseIterable, Identifiable {
    case mild, moderate, severe
    var id: String { rawValue }
    var labelRu: String {
        switch self {
        case .mild: return "Лёгкие / редкие"
        case .moderate: return "Умеренные"
        case .severe: return "Выраженные (обострение)"
        }
    }
}

enum DiabetesType: String, Codable, CaseIterable, Identifiable {
    case none, type2, type1, prediabetes
    var id: String { rawValue }
    var labelRu: String {
        switch self {
        case .none: return "Нет"
        case .type2: return "Сахарный диабет 2 типа"
        case .type1: return "Сахарный диабет 1 типа"
        case .prediabetes: return "Предиабет / нарушение толерантности"
        }
    }
}

enum CalorieMode: String, Codable, CaseIterable, Identifiable {
    case therapeutic, moderateDeficit, strongDeficit, riskyDeficit
    var id: String { rawValue }
    var labelRu: String {
        switch self {
        case .therapeutic: return "Лечебный / нормальный"
        case .moderateDeficit: return "Усиленный безопасный"
        case .strongDeficit: return "Сильный дефицит"
        case .riskyDeficit: return "Опасный (не рекомендуется)"
        }
    }
    var descriptionRu: String {
        switch self {
        case .therapeutic: return "Поддержание веса или лёгкий дефицит ~250 ккал."
        case .moderateDeficit: return "Дефицит ~500 ккал (≈0,5 кг/нед)."
        case .strongDeficit: return "Дефицит ~750 ккал. Только по согласованию с врачом."
        case .riskyDeficit: return "Дефицит >1000 ккал. Высокий риск."
        }
    }
    var deficitKcal: Int {
        switch self {
        case .therapeutic: return 250
        case .moderateDeficit: return 500
        case .strongDeficit: return 750
        case .riskyDeficit: return 1000
        }
    }
    var isRecommended: Bool { self == .therapeutic || self == .moderateDeficit }
}

struct Comorbidities: Codable, Equatable {
    var hasDiabetes = false
    var diabetesType: DiabetesType = .none
    var onInsulin = false
    var hasHypertension = false
    var avgSystolic = ""
    var avgDiastolic = ""
    var hasGout = false
    var hasGerd = false
    var hasCkd = false
    var ckdStage = ""
    var hasDyslipidemia = false
    var hasObesityComorbid = false
}

struct UserProfile: Codable, Equatable {
    var diseaseId: String
    var age: Int
    var gender: Gender
    var weightKg: Float
    var heightCm: Int
    var preferredFoodIds: Set<String> = []
    var symptomSeverity: SymptomSeverity = .mild
    var comorbidities = Comorbidities()
    var calorieMode: CalorieMode = .therapeutic
    var isBreastfeeding = false
    var menopauseStatus: MenopauseStatus = .none
    var allergenIds: Set<String> = []
    var surveyCompleted = true

    var bmi: Float {
        let h = Float(heightCm) / 100
        return weightKg / (h * h)
    }

    func isInMenopause() -> Bool {
        gender == .female && menopauseStatus != .none
    }

    func activeDiseaseIds() -> Set<String> {
        var ids: Set<String> = [diseaseId]
        let c = comorbidities
        if c.hasDiabetes && c.diabetesType != .none { ids.insert("type2_diabetes") }
        if c.hasHypertension { ids.insert("hypertension") }
        if c.hasGout { ids.insert("gout") }
        if c.hasGerd { ids.insert("gerd") }
        if c.hasCkd { ids.insert("ckd") }
        if c.hasDyslipidemia { ids.insert("dyslipidemia") }
        if c.hasObesityComorbid { ids.insert("obesity") }
        return ids
    }
}

struct SurveyDraft {
    var step = 0
    var diseaseId = ""
    var age = ""
    var gender: Gender = .female
    var weightKg = ""
    var targetWeightKg = ""
    var heightCm = ""
    var comorbidities = Comorbidities()
    var calorieMode: CalorieMode = .therapeutic
    var preferredFoodIds: Set<String> = []
    var symptomSeverity: SymptomSeverity = .mild
    var isBreastfeeding = false
    var menopauseStatus: MenopauseStatus = .none
    var allergenIds: Set<String> = []
}

struct CaloriePreview: Identifiable {
    let id = UUID()
    let maintenanceKcal: Int
    let mode: CalorieMode
    let targetKcal: Int
    let allowed: Bool
    let warning: String?
}

struct Disease: Identifiable {
    let id: String
    let nameRu: String
    let shortDescription: String
}

struct DayMeal: Identifiable {
    let id = UUID()
    let mealType: String
    let time: String
    let dishName: String
    let calories: Int
    let proteinG: Int
    let carbsG: Int
    let fatG: Int
}

struct DayPlan: Identifiable {
    let id = UUID()
    let dayName: String
    let dayIndex: Int
    let meals: [DayMeal]
    var dailyCalories: Int { meals.reduce(0) { $0 + $1.calories } }
}

struct WeeklyPlan {
    let targetKcal: Int
    let mealsPerDay: Int
    let waterGlasses: Int
    let patternName: String
    let days: [DayPlan]
    let shoppingList: [String]
}

enum LicenseStatus {
    case checking, licensed, needsActivation, blocked
}

struct StoredLicense: Codable {
    let installationId: String
    let sessionToken: String
    let code: String
    let expiresAt: String?
    let lastVerifiedAt: Date
}
