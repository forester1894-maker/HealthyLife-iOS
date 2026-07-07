import Foundation

enum AllergenFilter {
    static func isFoodTagAllowed(foodId: String, allergenIds: Set<String>) -> Bool {
        foodId !in AllergenCatalog.blockedFoodTags(allergenIds)
    }

    static func isTemplateAllowed(_ template: MealTemplate, allergenIds: Set<String>) -> Bool {
        if allergenIds.isEmpty { return true }
        let blocked = AllergenCatalog.blockedFoodTags(allergenIds)
        if template.foodTags.contains(where: { blocked.contains($0) }) { return false }
        var text = template.dishName.lowercased() + " "
        text += template.ingredients.joined(separator: " ").lowercased()
        for p in template.portions {
            text += " \(p.displayName.lowercased()) \(p.nutritionKey.lowercased())"
        }
        return !AllergenCatalog.keywordsFor(allergenIds).contains { kw in text.contains(kw) }
    }

    static func foodNameMatchesAllergen(name: String, allergenIds: Set<String>) -> Bool {
        if allergenIds.isEmpty { return false }
        let lower = name.lowercased()
        return AllergenCatalog.keywordsFor(allergenIds).contains { lower.contains($0) }
    }

    static func filterSearchResults(_ results: [FoodSearchResult], allergenIds: Set<String>) -> [FoodSearchResult] {
        if allergenIds.isEmpty { return results }
        return results.filter { !foodNameMatchesAllergen(name: $0.name, allergenIds: allergenIds) }
    }
}
