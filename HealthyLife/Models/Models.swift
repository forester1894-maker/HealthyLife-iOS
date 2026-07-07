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
    let dietPattern: String
}

struct NutritionRegimen: Codable, Equatable {
    var dailyCalories: Int
    var mealsPerDay: Int
    var mealIntervalHours: String
    var waterLiters: String
    var patternName: String
    var macroSummary: String
    var keyRules: [String]
}

struct MealIngredientDetail: Codable, Equatable, Identifiable {
    var id: String { "\(name)-\(grams)" }
    var name: String
    var grams: Double
    var amountLabel: String
    var nutritionKey: String?
    var cookingMethodKey: String?
    var calories: Int = 0

    init(name: String, grams: Double, amountLabel: String? = nil, nutritionKey: String? = nil, cookingMethodKey: String? = nil, calories: Int = 0) {
        self.name = name
        self.grams = grams
        self.amountLabel = amountLabel ?? "\(Int(grams)) г"
        self.nutritionKey = nutritionKey
        self.cookingMethodKey = cookingMethodKey
        self.calories = calories
    }
}

struct DayMeal: Codable, Equatable, Identifiable {
    var mealType: String
    var time: String
    var dishName: String
    var portion: String
    var calories: Int
    var proteinG: Double
    var carbsG: Double
    var fatG: Double
    var sodiumMg: Double
    var sugarG: Double
    var saturatedFatG: Double
    var templateId: String
    var recipeSteps: [String]
    var ingredients: [String]
    var ingredientDetails: [MealIngredientDetail]
    var note: String?

    var id: String { templateId.isEmpty ? "\(mealType)-\(time)-\(dishName)" : templateId }

    init(
        mealType: String, time: String, dishName: String, portion: String = "",
        calories: Int, proteinG: Double = 0, carbsG: Double = 0, fatG: Double = 0,
        sodiumMg: Double = 0, sugarG: Double = 0, saturatedFatG: Double = 0,
        templateId: String = "", recipeSteps: [String] = [], ingredients: [String] = [],
        ingredientDetails: [MealIngredientDetail] = [], note: String? = nil
    ) {
        self.mealType = mealType
        self.time = time
        self.dishName = dishName
        self.portion = portion
        self.calories = calories
        self.proteinG = proteinG
        self.carbsG = carbsG
        self.fatG = fatG
        self.sodiumMg = sodiumMg
        self.sugarG = sugarG
        self.saturatedFatG = saturatedFatG
        self.templateId = templateId
        self.recipeSteps = recipeSteps
        self.ingredients = ingredients
        self.ingredientDetails = ingredientDetails
        self.note = note
    }
}

struct DayPlan: Codable, Equatable, Identifiable {
    var dayName: String
    var dayIndex: Int
    var meals: [DayMeal]
    var dailyCalories: Int

    var id: Int { dayIndex }
}

struct ActivityDay: Codable, Equatable, Identifiable {
    var dayName: String
    var allowed: Bool
    var activityType: String
    var durationMinutes: Int
    var intensity: String
    var notes: [String]

    var id: String { dayName }
}

struct WeeklyPlan: Codable, Equatable {
    var regimen: NutritionRegimen
    var days: [DayPlan]
    var activityPlan: [ActivityDay]
    var activitySummary: String
    var generatedForDisease: String
    var disclaimer: String
    var shoppingList: [String]
    var restrictionSummary: [String]

    var targetKcal: Int { regimen.dailyCalories }
    var mealsPerDay: Int { regimen.mealsPerDay }
    var waterGlasses: Int {
        let match = regimen.waterLiters.firstMatch(of: /\((\d+)/)
        return match.map { Int($0.1) ?? 8 } ?? 8
    }
    var patternName: String { regimen.patternName }
}

struct TherapeuticNutrientRule: Codable, Equatable {
    var nutrient: String
    var target: String
    var rationale: String
    var source: String
}

struct TherapeuticNutritionProfile: Codable, Equatable {
    var sodiumMgMax: Int
    var sodiumSaltGrams: Float
    var addedSugarGMax: Int
    var saturatedFatGMax: Int
    var saturatedFatPercentMax: Int
    var carbsPerMealGMax: Int?
    var proteinGMax: Int?
    var fiberGMin: Int
    var waterGlasses: Int
    var waterLiters: String
    var waterNote: String
    var fatBeneficial: [String]
    var fatLimit: [String]
    var fatAvoid: [String]
    var omega3Guidance: String
    var potassiumGuidance: String?
    var clinicalRules: [TherapeuticNutrientRule]
    var patternName: String
    var evidenceNote: String
}

struct DailyNutrientLimits: Codable, Equatable {
    var maxSodiumMg: Int
    var maxAddedSugarG: Int
    var maxSaturatedFatG: Int
    var maxCarbsPerMealG: Int?
    var maxProteinG: Int?
    var minFiberG: Int
    var waterGlasses: Int
    var waterLiters: String
}

struct DailyProgress: Codable, Equatable {
    var dateIso: String
    var targetKcal: Int
    var consumedKcal: Double
    var proteinG: Double
    var carbsG: Double
    var fatG: Double
    var sodiumMg: Double
    var sugarG: Double
    var saturatedFatG: Double
    var waterGlasses: Int
    var waterTarget: Int
    var sodiumTargetMg: Int
    var sugarTargetG: Int
    var saturatedFatTargetG: Int
    var adherencePercent: Int
}

struct FoodDiaryEntry: Codable, Equatable, Identifiable {
    var id: String
    var dateIso: String
    var mealType: String
    var foodName: String
    var calories: Double
    var protein: Double
    var carbs: Double
    var fat: Double
    var portionMultiplier: Double
    var sodiumMg: Double
    var sugarG: Double
    var saturatedFatG: Double
    var fiberG: Double
    var foodId: String?
    var servingDescription: String?
    var fromPlan: Bool

    init(
        id: String = UUID().uuidString, dateIso: String, mealType: String, foodName: String,
        calories: Double, protein: Double, carbs: Double, fat: Double,
        portionMultiplier: Double = 1.0, sodiumMg: Double = 0, sugarG: Double = 0,
        saturatedFatG: Double = 0, fiberG: Double = 0, foodId: String? = nil,
        servingDescription: String? = nil, fromPlan: Bool = false
    ) {
        self.id = id
        self.dateIso = dateIso
        self.mealType = mealType
        self.foodName = foodName
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.portionMultiplier = portionMultiplier
        self.sodiumMg = sodiumMg
        self.sugarG = sugarG
        self.saturatedFatG = saturatedFatG
        self.fiberG = fiberG
        self.foodId = foodId
        self.servingDescription = servingDescription
        self.fromPlan = fromPlan
    }
}

struct WeightEntry: Codable, Equatable, Identifiable {
    var id: String
    var dateIso: String
    var weightKg: Float
    var note: String?

    init(id: String = UUID().uuidString, dateIso: String, weightKg: Float, note: String? = nil) {
        self.id = id
        self.dateIso = dateIso
        self.weightKg = weightKg
        self.note = note
    }
}

struct ReminderSettings: Codable, Equatable {
    var weightEnabled: Bool = true
    var weightHour: Int = 8
    var weightMinute: Int = 0
    var weightDayOfWeek: Int = 1
    var mealEnabled: Bool = true
    var breakfastHour: Int = 8
    var lunchHour: Int = 13
    var dinnerHour: Int = 19
    var waterEnabled: Bool = true
    var waterIntervalHours: Int = 2
}

struct RestrictionRule: Codable, Equatable, Identifiable {
    var title: String
    var description: String
    var priority: Int
    var id: String { title }
}

struct ChatMessage: Codable, Equatable, Identifiable {
    var id: String
    var role: String
    var content: String
    var timestamp: Date
    var modelBadge: String?

    init(id: String = UUID().uuidString, role: String, content: String, timestamp: Date = Date(), modelBadge: String? = nil) {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
        self.modelBadge = modelBadge
    }
}

struct FoodSearchResult: Identifiable, Equatable {
    let foodId: String
    let name: String
    let brandName: String?
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
    let sodiumMg: Double
    let sugarG: Double
    let saturatedFatG: Double
    let servingDescription: String

    var id: String { foodId }
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
