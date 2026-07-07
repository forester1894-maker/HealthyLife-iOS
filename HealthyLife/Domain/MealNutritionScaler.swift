import Foundation

enum MealNutritionScaler {
    static func scaleMealsToTarget(_ meals: [DayMeal], target: Int) -> [DayMeal] {
        if meals.isEmpty || target <= 0 { return meals }
        let currents = meals.map { mealCalories($0) }
        let current = currents.reduce(0, +)
        if current <= 0 || current == target { return meals }

        let mealTargets = distributeTargets(currents: currents, target: target)
        return meals.enumerated().map { index, meal in
            scaleMealToTarget(meal, target: mealTargets[index], current: currents[index])
        }
    }

    private static func mealCalories(_ meal: DayMeal) -> Int {
        let fromIngredients = meal.ingredientDetails.reduce(0) { $0 + $1.calories }
        if fromIngredients > 0 { return fromIngredients }
        return max(meal.calories, 1)
    }

    private static func distributeTargets(currents: [Int], target: Int) -> [Int] {
        let total = max(currents.reduce(0, +), 1)
        var allocated = currents.map { Int(Double($0) * Double(target) / Double(total)) }
        var diff = target - allocated.reduce(0, +)
        var i = 0
        while diff != 0 && i < allocated.count * 4 {
            let idx = i % allocated.count
            if diff > 0 {
                allocated[idx] += 1
                diff -= 1
            } else if allocated[idx] > 1 {
                allocated[idx] -= 1
                diff += 1
            }
            i += 1
        }
        return allocated
    }

    private static func scaleMealToTarget(_ meal: DayMeal, target: Int, current: Int) -> DayMeal {
        if current <= 0 || target == current { return meal }
        let factor = Double(target) / Double(current)
        var scaled = meal
        scaled.calories = target
        scaled.proteinG = (meal.proteinG * factor * 10).rounded() / 10
        scaled.carbsG = (meal.carbsG * factor * 10).rounded() / 10
        scaled.fatG = (meal.fatG * factor * 10).rounded() / 10
        scaled.sodiumMg = meal.sodiumMg * factor
        scaled.sugarG = meal.sugarG * factor
        scaled.saturatedFatG = meal.saturatedFatG * factor
        if !scaled.ingredientDetails.isEmpty {
            scaled.ingredientDetails = scaled.ingredientDetails.map { ing in
                var s = ing
                s.grams = (ing.grams * factor * 10).rounded() / 10
                s.amountLabel = "\(Int(s.grams)) г"
                s.calories = Int(Double(ing.calories) * factor)
                return s
            }
            scaled.portion = scaled.ingredientDetails.map { "\(Int($0.grams)) г \($0.name.lowercased())" }.joined(separator: " + ")
        }
        return scaled
    }
}
