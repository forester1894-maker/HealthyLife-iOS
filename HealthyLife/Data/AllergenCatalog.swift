import Foundation

struct Allergen: Identifiable {
    let id: String
    let nameRu: String
    let hintRu: String
    let searchKeywords: [String]
    let foodTagIds: Set<String>
}

enum AllergenCatalog {
    static let all: [Allergen] = [
        Allergen(id: "milk", nameRu: "Молоко / лактоза", hintRu: "Творог, кефир, йогурт, сыры",
                 searchKeywords: ["молок", "лактоз", "творог", "кефир", "йогурт", "сыр", "сливк"],
                 foodTagIds: ["cottage", "kefir", "yogurt"]),
        Allergen(id: "eggs", nameRu: "Яйца", hintRu: "Яйца, омлет, майонез",
                 searchKeywords: ["яйц", "яичн", "омлет", "альбумин"], foodTagIds: ["eggs"]),
        Allergen(id: "fish", nameRu: "Рыба / морепродукты", hintRu: "Рыба, икра, морепродукты",
                 searchKeywords: ["рыб", "лосос", "треск", "минтай", "икр", "кревет", "морепродукт"],
                 foodTagIds: ["fish"]),
        Allergen(id: "nuts", nameRu: "Орехи", hintRu: "Грецкий, миндаль, фундук и др.",
                 searchKeywords: ["орех", "миндал", "фундук", "кешью", "фисташ"], foodTagIds: ["nuts"]),
        Allergen(id: "gluten", nameRu: "Глютен / пшеница", hintRu: "Пшеница, хлеб, манка",
                 searchKeywords: ["пшен", "глютен", "хлеб", "манк", "булгур", "мук"],
                 foodTagIds: ["oatmeal", "bread_whole"]),
        Allergen(id: "soy", nameRu: "Соя", hintRu: "Соевый соус, тофу",
                 searchKeywords: ["соя", "соев", "тофу", "эдамаме"], foodTagIds: []),
        Allergen(id: "legumes", nameRu: "Бобовые", hintRu: "Фасоль, чечевица, горох, нут",
                 searchKeywords: ["фасол", "чечевиц", "горох", "нут", "бобов", "хумус"],
                 foodTagIds: ["lentils", "beans"]),
        Allergen(id: "celery", nameRu: "Сельдерей", hintRu: "Сельдерей, приправы",
                 searchKeywords: ["сельдер"], foodTagIds: []),
        Allergen(id: "mustard", nameRu: "Горчица", hintRu: "Горчица, соусы",
                 searchKeywords: ["горчиц"], foodTagIds: []),
        Allergen(id: "sesame", nameRu: "Кунжут", hintRu: "Кунжут, тахини",
                 searchKeywords: ["кунжут", "тахин", "сезам"], foodTagIds: []),
        Allergen(id: "sulphites", nameRu: "Сульфиты", hintRu: "Сухофрукты, вино",
                 searchKeywords: ["сульфит", "сухофрукт", "изюм", "курага"], foodTagIds: []),
        Allergen(id: "lupin", nameRu: "Люпин", hintRu: "Мука люпина",
                 searchKeywords: ["люпин"], foodTagIds: [])
    ]

    static func byId(_ id: String) -> Allergen? { all.first { $0.id == id } }

    static func keywordsFor(_ allergenIds: Set<String>) -> [String] {
        allergenIds.flatMap { id in byId(id)?.searchKeywords ?? [] }
    }

    static func blockedFoodTags(_ allergenIds: Set<String>) -> Set<String> {
        Set(allergenIds.flatMap { id in byId(id)?.foodTagIds ?? [] })
    }
}
