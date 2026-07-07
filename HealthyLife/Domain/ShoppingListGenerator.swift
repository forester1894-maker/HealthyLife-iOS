import Foundation

enum ShoppingListGenerator {
    static func generate(plan: WeeklyPlan) -> [String] {
        var items = Set<String>()
        for day in plan.days {
            for meal in day.meals {
                if !meal.ingredientDetails.isEmpty {
                    for ing in meal.ingredientDetails {
                        items.insert("\(ing.name) — \(Int(ing.grams)) г")
                    }
                } else if !meal.ingredients.isEmpty {
                    meal.ingredients.forEach { items.insert($0) }
                } else {
                    items.insert(meal.dishName)
                }
            }
        }
        return items.sorted()
    }
}
