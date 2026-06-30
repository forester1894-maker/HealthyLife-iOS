import Foundation

enum WeeklyPlanGenerator {
    private static let dayNames = ["Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота", "Воскресенье"]

    static func generate(for profile: UserProfile) -> WeeklyPlan {
        let target = NutritionCalculator.targetCalories(profile: profile)
        let mealsCount = NutritionCalculator.mealsPerDay(profile: profile)
        let pattern = mealPattern(for: profile)
        let days = dayNames.enumerated().map { index, name in
            DayPlan(
                dayName: name,
                dayIndex: index,
                meals: buildMeals(pattern: pattern, targetKcal: target, count: mealsCount, dayIndex: index)
            )
        }
        return WeeklyPlan(
            targetKcal: target,
            mealsPerDay: mealsCount,
            waterGlasses: profile.isBreastfeeding ? 12 : 8,
            patternName: pattern.name,
            days: days,
            shoppingList: pattern.shopping
        )
    }

    private struct MealPattern {
        let name: String
        let breakfast: [String]
        let lunch: [String]
        let dinner: [String]
        let snack: [String]
        let shopping: [String]
    }

    private static func mealPattern(for profile: UserProfile) -> MealPattern {
        let ids = profile.activeDiseaseIds()
        if profile.isBreastfeeding {
            return MealPattern(
                name: "Грудное вскармливание",
                breakfast: ["Овсянка на молоке", "Творог 5%", "Яичница из 2 яиц"],
                lunch: ["Куриная грудка с гречкой", "Рыба на пару с овощами", "Суп-пюре из тыквы"],
                dinner: ["Творожная запеканка", "Омлет с овощами", "Кефир с хлебом"],
                snack: ["Йогурт", "Фрукты", "Орехи (30 г)"],
                shopping: ["Овсянка", "Творог", "Яйца", "Курица", "Гречка", "Рыба", "Овощи", "Кефир"]
            )
        }
        if ids.contains("type2_diabetes") || ids.contains("masld") {
            return MealPattern(
                name: "Низкий гликемический индекс",
                breakfast: ["Омлет с овощами", "Гречка с яйцом", "Творог с ягодами"],
                lunch: ["Куриная грудка с киноа", "Рыба с салатом", "Тушёные овощи с индейкой"],
                dinner: ["Творог", "Запечённая рыба", "Овощной суп"],
                snack: ["Яблоко", "Кефир", "Горсть орехов"],
                shopping: ["Яйца", "Гречка", "Киноа", "Курица", "Рыба", "Овощи", "Творог", "Ягоды"]
            )
        }
        if ids.contains("gout") {
            return MealPattern(
                name: "Низкопуриновый",
                breakfast: ["Овсянка", "Творог", "Хлеб с сыром"],
                lunch: ["Макароны с овощами", "Курица с рисом", "Суп овощной"],
                dinner: ["Творог", "Омлет", "Кефир"],
                snack: ["Фрукты", "Йогурт"],
                shopping: ["Овсянка", "Творог", "Курица", "Рис", "Овощи", "Кефир"]
            )
        }
        return MealPattern(
            name: "Сбалансированный лечебный",
            breakfast: ["Овсянка", "Творог 2%", "Яичница"],
            lunch: ["Курица с гречкой", "Рыба с овощами", "Суп овощной"],
            dinner: ["Творог", "Омлет", "Салат с курицей"],
            snack: ["Фрукт", "Кефир", "Йогурт"],
            shopping: ["Овсянка", "Творог", "Яйца", "Курица", "Гречка", "Рыба", "Овощи", "Кефир"]
        )
    }

    private static func buildMeals(pattern: MealPattern, targetKcal: Int, count: Int, dayIndex: Int) -> [DayMeal] {
        let perMeal = targetKcal / max(count, 1)
        let protein = max(15, perMeal / 10)
        let carbs = max(20, perMeal / 8)
        let fat = max(8, perMeal / 15)

        var meals: [DayMeal] = [
            DayMeal(mealType: "Завтрак", time: "08:00", dishName: pick(pattern.breakfast, dayIndex), calories: perMeal, proteinG: protein, carbsG: carbs, fatG: fat),
            DayMeal(mealType: "Обед", time: "13:00", dishName: pick(pattern.lunch, dayIndex), calories: perMeal, proteinG: protein, carbsG: carbs, fatG: fat),
            DayMeal(mealType: "Ужин", time: "19:00", dishName: pick(pattern.dinner, dayIndex), calories: perMeal, proteinG: protein, carbsG: carbs, fatG: fat)
        ]
        if count >= 4 {
            meals.append(DayMeal(mealType: "Перекус", time: "16:00", dishName: pick(pattern.snack, dayIndex), calories: perMeal / 2, proteinG: protein / 2, carbsG: carbs / 2, fatG: fat / 2))
        }
        if count >= 5 {
            meals.insert(DayMeal(mealType: "Полдник", time: "11:00", dishName: pick(pattern.snack, dayIndex + 1), calories: perMeal / 2, proteinG: protein / 2, carbsG: carbs / 2, fatG: fat / 2), at: 1)
        }
        return meals
    }

    private static func pick(_ items: [String], _ index: Int) -> String {
        guard !items.isEmpty else { return "Блюдо дня" }
        return items[index % items.count]
    }
}
