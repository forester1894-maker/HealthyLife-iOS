import Foundation

struct IngredientPortion {
    let displayName: String
    let grams: Double
    let nutritionKey: String
}

struct MealTemplate {
    let id: String
    let mealType: String
    let time: String
    let dishName: String
    let calories: Int
    let proteinG: Double
    let carbsG: Double
    let fatG: Double
    let foodTags: Set<String>
    let portions: [IngredientPortion]
    let recipeSteps: [String]
    let excludedDiseases: Set<String>
    let note: String?

    var portion: String { portions.map { "\(Int($0.grams)) г \($0.displayName.lowercased())" }.joined(separator: " + ") }
    var ingredients: [String] { portions.map(\.displayName) }

    init(
        id: String, mealType: String, time: String, dishName: String, calories: Int,
        proteinG: Double = 0, carbsG: Double = 0, fatG: Double = 0,
        foodTags: Set<String>, portions: [IngredientPortion], recipeSteps: [String],
        excludedDiseases: Set<String> = [], note: String? = nil
    ) {
        self.id = id; self.mealType = mealType; self.time = time; self.dishName = dishName
        self.calories = calories; self.proteinG = proteinG; self.carbsG = carbsG; self.fatG = fatG
        self.foodTags = foodTags; self.portions = portions; self.recipeSteps = recipeSteps
        self.excludedDiseases = excludedDiseases; self.note = note
    }
}

enum MealTemplateCatalog {
    private static func ing(_ name: String, _ grams: Double, _ key: String) -> IngredientPortion {
        IngredientPortion(displayName: name, grams: grams, nutritionKey: key)
    }

    private static let coreTemplates: [MealTemplate] = [
        MealTemplate(id: "brk_oat", mealType: "Завтрак", time: "08:00", dishName: "Овсянка на воде с ягодами", calories: 280,
            proteinG: 10, carbsG: 45, fatG: 6, foodTags: ["oatmeal", "berries"],
            portions: [ing("Овсяные хлопья", 50, "kasha_ovsyannaya"), ing("Черника", 80, "chernika")],
            recipeSteps: ["Залить овсянку водой", "Варить 10 мин", "Добавить ягоды"]),
        MealTemplate(id: "brk_buck", mealType: "Завтрак", time: "08:00", dishName: "Гречка с отварным яйцом", calories: 320,
            proteinG: 18, carbsG: 40, fatG: 8, foodTags: ["buckwheat", "eggs"],
            portions: [ing("Гречка отварная", 200, "grechka"), ing("Яйцо вкрутую", 50, "yayco")],
            recipeSteps: ["Отварить гречку", "Сварить яйцо"]),
        MealTemplate(id: "brk_cott", mealType: "Завтрак", time: "08:00", dishName: "Творог 2% с яблоком", calories: 250,
            proteinG: 22, carbsG: 20, fatG: 5, foodTags: ["cottage", "apple"],
            portions: [ing("Творог 2%", 150, "tvorog"), ing("Яблоко", 150, "yabloko")],
            recipeSteps: ["Нарезать яблоко", "Смешать с творогом"]),
        MealTemplate(id: "brk_omelet", mealType: "Завтрак", time: "08:00", dishName: "Омлет из 2 яиц с овощами", calories: 290,
            proteinG: 20, carbsG: 8, fatG: 18, foodTags: ["eggs", "tomato", "cucumber"],
            portions: [ing("Яйцо", 100, "yayco"), ing("Помидор", 80, "pomidor"), ing("Перец", 80, "perets")],
            recipeSteps: ["Взбить яйца", "Обжарить овощи", "Залить яйцами"]),
        MealTemplate(id: "brk_rice", mealType: "Завтрак", time: "08:00", dishName: "Рисовая каша на молоке 1,5%", calories: 300,
            proteinG: 12, carbsG: 48, fatG: 6, foodTags: ["rice", "yogurt"],
            portions: [ing("Рис отварной", 50, "ris"), ing("Молоко 1,5%", 200, "moloko")],
            recipeSteps: ["Варить кашу 20 мин"], excludedDiseases: ["celiac"]),
        MealTemplate(id: "brk_quinoa", mealType: "Завтрак", time: "08:00", dishName: "Киноа с яблоком", calories: 270,
            proteinG: 9, carbsG: 42, fatG: 5, foodTags: ["quinoa", "apple"],
            portions: [ing("Киноа", 120, "kinoa"), ing("Яблоко", 120, "yabloko")],
            recipeSteps: ["Отварить киноа", "Нарезать яблоко"]),
        MealTemplate(id: "brk_yog_ber", mealType: "Завтрак", time: "08:00", dishName: "Йогурт с ягодами", calories: 240,
            proteinG: 14, carbsG: 28, fatG: 4, foodTags: ["yogurt", "berries"],
            portions: [ing("Йогурт без сахара", 180, "yogurt"), ing("Черника", 80, "chernika")],
            recipeSteps: ["Смешать йогурт с ягодами"]),
        MealTemplate(id: "brk_buck_ban", mealType: "Завтрак", time: "08:00", dishName: "Гречка с бананом", calories: 310,
            proteinG: 10, carbsG: 55, fatG: 4, foodTags: ["buckwheat", "banana"],
            portions: [ing("Гречка", 180, "grechka"), ing("Банан", 80, "banan")],
            recipeSteps: ["Отварить гречку", "Добавить банан"]),
        MealTemplate(id: "brk_rice_egg", mealType: "Завтрак", time: "08:00", dishName: "Рис с яйцом всмятку", calories: 300,
            proteinG: 14, carbsG: 42, fatG: 7, foodTags: ["rice", "eggs"],
            portions: [ing("Рис", 150, "ris"), ing("Яйцо", 50, "yayco")],
            recipeSteps: ["Отварить рис", "Сварить яйцо"]),
        MealTemplate(id: "brk_cott_ber", mealType: "Завтрак", time: "08:00", dishName: "Творог 2% с ягодами", calories: 260,
            proteinG: 24, carbsG: 18, fatG: 5, foodTags: ["cottage", "berries"],
            portions: [ing("Творог 2%", 150, "tvorog"), ing("Черника", 100, "chernika")],
            recipeSteps: ["Смешать творог с ягодами"]),

        MealTemplate(id: "snk_kefir", mealType: "Перекус", time: "11:00", dishName: "Кефир 1% + горсть орехов", calories: 200,
            proteinG: 12, carbsG: 10, fatG: 12, foodTags: ["kefir", "nuts"],
            portions: [ing("Кефир 1%", 200, "kefir"), ing("Грецкий орех", 15, "oreh")],
            recipeSteps: ["Подать охлаждённым"], excludedDiseases: ["peptic_ulcer", "gout"]),
        MealTemplate(id: "snk_apple", mealType: "Перекус", time: "11:00", dishName: "Яблоко и йогурт без сахара", calories: 150,
            proteinG: 8, carbsG: 22, fatG: 2, foodTags: ["apple", "yogurt"],
            portions: [ing("Яблоко", 150, "yabloko"), ing("Йогурт", 125, "yogurt")],
            recipeSteps: ["Нарезать яблоко"]),
        MealTemplate(id: "snk_carrot", mealType: "Перекус", time: "11:00", dishName: "Морковь и хумус", calories: 120,
            proteinG: 4, carbsG: 14, fatG: 5, foodTags: ["carrot"],
            portions: [ing("Морковь", 100, "morkov"), ing("Хумус", 40, "hummus")],
            recipeSteps: ["Натереть морковь"]),
        MealTemplate(id: "snk_banana", mealType: "Перекус", time: "11:00", dishName: "Банан и кефир", calories: 180,
            proteinG: 8, carbsG: 28, fatG: 3, foodTags: ["banana", "kefir"],
            portions: [ing("Банан", 100, "banan"), ing("Кефир 1%", 150, "kefir")],
            recipeSteps: ["Подать сразу"]),
        MealTemplate(id: "snk_cott", mealType: "Перекус", time: "11:00", dishName: "Творог 2% порция", calories: 140,
            proteinG: 18, carbsG: 6, fatG: 4, foodTags: ["cottage"],
            portions: [ing("Творог 2%", 120, "tvorog")],
            recipeSteps: ["Подать охлаждённым"]),
        MealTemplate(id: "snk_cucumber", mealType: "Перекус", time: "11:00", dishName: "Огурец и йогурт", calories: 110,
            proteinG: 8, carbsG: 10, fatG: 2, foodTags: ["cucumber", "yogurt"],
            portions: [ing("Огурец", 150, "ogurets"), ing("Йогурт", 100, "yogurt")],
            recipeSteps: ["Нарезать огурец"]),
        MealTemplate(id: "snk_berries", mealType: "Перекус", time: "11:00", dishName: "Ягоды и орехи", calories: 160,
            proteinG: 4, carbsG: 12, fatG: 10, foodTags: ["berries", "nuts"],
            portions: [ing("Черника", 100, "chernika"), ing("Грецкий орех", 12, "oreh")],
            recipeSteps: ["Подать свежим"], excludedDiseases: ["gout", "peptic_ulcer"]),
        MealTemplate(id: "snk_tom_cott", mealType: "Перекус", time: "11:00", dishName: "Помидор и творог", calories: 130,
            proteinG: 12, carbsG: 8, fatG: 4, foodTags: ["tomato", "cottage"],
            portions: [ing("Помидор", 120, "pomidor"), ing("Творог 2%", 80, "tvorog")],
            recipeSteps: ["Нарезать помидор"], excludedDiseases: ["gerd"]),
        MealTemplate(id: "snk_bread_cott", mealType: "Перекус", time: "11:00", dishName: "Хлебец с творогом", calories: 170,
            proteinG: 14, carbsG: 18, fatG: 4, foodTags: ["bread_whole", "cottage"],
            portions: [ing("Хлеб цельнозерновой", 35, "hleb"), ing("Творог 2%", 100, "tvorog")],
            recipeSteps: ["Подать сразу"], excludedDiseases: ["celiac"]),
        MealTemplate(id: "snk_apple_nuts", mealType: "Перекус", time: "11:00", dishName: "Яблоко и миндаль", calories: 155,
            proteinG: 4, carbsG: 20, fatG: 7, foodTags: ["apple", "nuts"],
            portions: [ing("Яблоко", 150, "yabloko"), ing("Миндаль", 10, "mindal")],
            recipeSteps: ["Подать свежим"], excludedDiseases: ["gout"]),

        MealTemplate(id: "lnc_chick", mealType: "Обед", time: "13:30", dishName: "Куриная грудка с гречкой и салатом", calories: 450,
            proteinG: 38, carbsG: 42, fatG: 10, foodTags: ["chicken", "buckwheat", "cucumber", "tomato"],
            portions: [ing("Куриная грудка", 120, "kuritsa"), ing("Гречка", 150, "grechka"),
                       ing("Огурец", 50, "ogurets"), ing("Помидор", 50, "pomidor")],
            recipeSteps: ["Отварить грудку", "Отварить гречку", "Собрать салат"]),
        MealTemplate(id: "lnc_fish", mealType: "Обед", time: "13:30", dishName: "Запечённая треска с овощами", calories: 420,
            proteinG: 36, carbsG: 18, fatG: 12, foodTags: ["fish", "broccoli", "carrot"],
            portions: [ing("Треска", 150, "treska"), ing("Брокколи", 100, "brokkoli"), ing("Морковь", 80, "morkov")],
            recipeSteps: ["Запечь рыбу 25 мин", "Приготовить овощи на пару"]),
        MealTemplate(id: "lnc_lentil", mealType: "Обед", time: "13:30", dishName: "Чечевица с тушёными овощами", calories: 380,
            proteinG: 20, carbsG: 48, fatG: 6, foodTags: ["lentils", "carrot", "tomato"],
            portions: [ing("Чечевица", 150, "chechevitsa"), ing("Морковь", 80, "morkov"), ing("Помидор", 80, "pomidor")],
            recipeSteps: ["Отварить чечевицу", "Тушить овощи"], excludedDiseases: ["ibs"]),
        MealTemplate(id: "lnc_turkey", mealType: "Обед", time: "13:30", dishName: "Индейка с рисом и брокколи", calories: 440,
            proteinG: 36, carbsG: 44, fatG: 8, foodTags: ["turkey", "rice", "broccoli"],
            portions: [ing("Индейка", 120, "indeyka"), ing("Рис", 150, "ris"), ing("Брокколи", 100, "brokkoli")],
            recipeSteps: ["Отварить индейку", "Отварить рис"]),
        MealTemplate(id: "lnc_soup", mealType: "Обед", time: "13:30", dishName: "Овощной суп-пюре + хлеб", calories: 350,
            proteinG: 12, carbsG: 48, fatG: 8, foodTags: ["broccoli", "carrot", "bread_whole"],
            portions: [ing("Брокколи", 100, "brokkoli"), ing("Морковь", 80, "morkov"), ing("Хлеб", 30, "hleb")],
            recipeSteps: ["Сварить суп-пюре"], note: "Щадящий вариант"),
        MealTemplate(id: "lnc_salmon", mealType: "Обед", time: "13:30", dishName: "Лосось с киноа и салатом", calories: 460,
            proteinG: 34, carbsG: 38, fatG: 18, foodTags: ["fish", "quinoa", "cucumber"],
            portions: [ing("Лосось", 130, "losos"), ing("Киноа", 120, "kinoa"), ing("Огурец", 80, "ogurets")],
            recipeSteps: ["Запечь лосось", "Отварить киноа"]),
        MealTemplate(id: "lnc_veg", mealType: "Обед", time: "13:30", dishName: "Тушёные овощи с индейкой", calories: 400,
            proteinG: 32, carbsG: 30, fatG: 12, foodTags: ["turkey", "broccoli", "carrot"],
            portions: [ing("Индейка", 100, "indeyka"), ing("Брокколи", 100, "brokkoli"), ing("Морковь", 100, "morkov")],
            recipeSteps: ["Тушить 25 мин"]),
        MealTemplate(id: "lnc_buck_chick", mealType: "Обед", time: "13:30", dishName: "Гречка с курицей и овощами", calories: 430,
            proteinG: 35, carbsG: 40, fatG: 10, foodTags: ["chicken", "buckwheat", "carrot"],
            portions: [ing("Курица", 110, "kuritsa"), ing("Гречка", 140, "grechka"), ing("Морковь", 80, "morkov")],
            recipeSteps: ["Отварить курицу и гречку"]),

        MealTemplate(id: "aft_cott", mealType: "Полдник", time: "16:30", dishName: "Творог с бананом", calories: 220,
            proteinG: 18, carbsG: 24, fatG: 5, foodTags: ["cottage", "banana"],
            portions: [ing("Творог 5%", 120, "tvorog"), ing("Банан", 60, "banan")],
            recipeSteps: ["Нарезать банан", "Смешать"]),
        MealTemplate(id: "aft_yog", mealType: "Полдник", time: "16:30", dishName: "Йогурт и миндаль", calories: 180,
            proteinG: 12, carbsG: 14, fatG: 8, foodTags: ["yogurt", "nuts"],
            portions: [ing("Йогурт", 150, "yogurt"), ing("Миндаль", 10, "mindal")],
            recipeSteps: ["Подать сразу"], excludedDiseases: ["gout"]),
        MealTemplate(id: "aft_kefir", mealType: "Полдник", time: "16:30", dishName: "Кефир с ягодами", calories: 160,
            proteinG: 10, carbsG: 18, fatG: 4, foodTags: ["kefir", "berries"],
            portions: [ing("Кефир 1%", 180, "kefir"), ing("Черника", 60, "chernika")],
            recipeSteps: ["Смешать"]),
        MealTemplate(id: "aft_apple", mealType: "Полдник", time: "16:30", dishName: "Яблоко и творог", calories: 190,
            proteinG: 14, carbsG: 20, fatG: 4, foodTags: ["apple", "cottage"],
            portions: [ing("Яблоко", 120, "yabloko"), ing("Творог 2%", 100, "tvorog")],
            recipeSteps: ["Нарезать яблоко"]),

        MealTemplate(id: "din_fish", mealType: "Ужин", time: "19:00", dishName: "Лосось на пару с салатом", calories: 350,
            proteinG: 32, carbsG: 8, fatG: 20, foodTags: ["fish", "cucumber", "tomato"],
            portions: [ing("Лосось", 130, "losos"), ing("Огурец", 80, "ogurets"), ing("Помидор черри", 80, "pomidor")],
            recipeSteps: ["Приготовить рыбу на пару", "Нарезать салат"]),
        MealTemplate(id: "din_soup", mealType: "Ужин", time: "19:00", dishName: "Куриный суп с овощами", calories: 280,
            proteinG: 22, carbsG: 24, fatG: 8, foodTags: ["chicken", "carrot", "potato"],
            portions: [ing("Курица", 80, "kuritsa"), ing("Морковь", 60, "morkov"), ing("Картофель", 80, "kartofel")],
            recipeSteps: ["Варить суп 40 мин"], note: "Тёплый, нежирный"),
        MealTemplate(id: "din_omelet", mealType: "Ужин", time: "19:00", dishName: "Омлет + салат из огурцов", calories: 300,
            proteinG: 20, carbsG: 6, fatG: 20, foodTags: ["eggs", "cucumber"],
            portions: [ing("Яйцо", 100, "yayco"), ing("Огурец", 100, "ogurets")],
            recipeSteps: ["Приготовить омлет", "Нарезать огурец"]),
        MealTemplate(id: "din_buck", mealType: "Ужин", time: "19:00", dishName: "Гречка с овощной смесью", calories: 320,
            proteinG: 12, carbsG: 48, fatG: 8, foodTags: ["buckwheat", "broccoli", "carrot"],
            portions: [ing("Гречка", 150, "grechka"), ing("Овощная смесь", 100, "ovoshchi"), ing("Морковь", 80, "morkov")],
            recipeSteps: ["Отварить гречку", "Приготовить овощи"]),
        MealTemplate(id: "din_turkey", mealType: "Ужин", time: "19:30", dishName: "Индейка запечённая с кабачком", calories: 330,
            proteinG: 34, carbsG: 12, fatG: 12, foodTags: ["turkey", "cucumber"],
            portions: [ing("Индейка", 120, "indeyka"), ing("Кабачок", 150, "kabachok")],
            recipeSteps: ["Запечь 30 мин при 180°C"]),
        MealTemplate(id: "din_cott", mealType: "Ужин", time: "19:00", dishName: "Творожная запеканка", calories: 280,
            proteinG: 24, carbsG: 22, fatG: 8, foodTags: ["cottage", "eggs"],
            portions: [ing("Творог 2%", 150, "tvorog"), ing("Яйцо", 50, "yayco")],
            recipeSteps: ["Запечь 25 мин"]),
        MealTemplate(id: "din_fish_veg", mealType: "Ужин", time: "19:00", dishName: "Треска с брокколи", calories: 310,
            proteinG: 34, carbsG: 14, fatG: 10, foodTags: ["fish", "broccoli"],
            portions: [ing("Треска", 140, "treska"), ing("Брокколи", 120, "brokkoli")],
            recipeSteps: ["Приготовить на пару"]),
        MealTemplate(id: "din_salad", mealType: "Ужин", time: "19:00", dishName: "Салат с курицей", calories: 290,
            proteinG: 28, carbsG: 10, fatG: 14, foodTags: ["chicken", "cucumber", "tomato"],
            portions: [ing("Курица", 100, "kuritsa"), ing("Огурец", 80, "ogurets"), ing("Помидор", 80, "pomidor")],
            recipeSteps: ["Отварить курицу", "Собрать салат"])
    ]

    static let all: [MealTemplate] = coreTemplates
    static let minVariantsPerMeal = 30

    static func byId(_ id: String) -> MealTemplate? { all.first { $0.id == id } }

    static func eligibleFor(mealType: String, profile: UserProfile) -> [MealTemplate] {
        let active = profile.activeDiseaseIds()
        return all.filter { $0.mealType == mealType }
            .filter { t in !t.excludedDiseases.contains(where: { active.contains($0) }) }
            .filter { t in active.allSatisfy { isCompatible(template: t, diseaseId: $0) } }
            .filter { AllergenFilter.isTemplateAllowed($0, allergenIds: profile.allergenIds) }
            .sorted { $0.id < $1.id }
    }

    static func nextAlternative(mealType: String, profile: UserProfile, currentTemplateId: String?) -> MealTemplate? {
        let eligible = eligibleFor(mealType: mealType, profile: profile)
        if eligible.count <= 1 { return nil }
        let currentIdx = eligible.firstIndex { $0.id == currentTemplateId } ?? -1
        let nextIdx = (currentIdx + 1) % eligible.count
        return eligible[nextIdx]
    }

    static func toDayMeal(_ template: MealTemplate) -> DayMeal {
        let details = template.portions.map { p in
            MealIngredientDetail(name: p.displayName, grams: p.grams, nutritionKey: p.nutritionKey,
                                 calories: Int(Double(template.calories) / Double(max(template.portions.count, 1))))
        }
        return DayMeal(
            mealType: template.mealType, time: template.time, dishName: template.dishName,
            portion: template.portion, calories: template.calories,
            proteinG: template.proteinG, carbsG: template.carbsG, fatG: template.fatG,
            templateId: template.id, recipeSteps: template.recipeSteps,
            ingredients: template.ingredients, ingredientDetails: details, note: template.note
        )
    }

    private static func isCompatible(template: MealTemplate, diseaseId: String) -> Bool {
        switch diseaseId {
        case "celiac":
            return !template.foodTags.contains("bread_whole") && !template.foodTags.contains("oatmeal")
        case "gout":
            return !template.dishName.localizedCaseInsensitiveContains("орех") || template.mealType != "Ужин"
        default:
            return true
        }
    }
}
