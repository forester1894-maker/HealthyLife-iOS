import Foundation

enum DiseaseCatalog {
    static let all: [Disease] = [
        Disease(id: "masld", nameRu: "Жировой гепатоз печени (МАЖБП / MASLD)", shortDescription: "Накопление жира в печени при метаболических нарушениях."),
        Disease(id: "peptic_ulcer", nameRu: "Язва желудка / двенадцатиперстной кишки", shortDescription: "Повреждение слизистой ЖКТ."),
        Disease(id: "type2_diabetes", nameRu: "Сахарный диабет 2 типа", shortDescription: "Нарушение углеводного обмена."),
        Disease(id: "hypertension", nameRu: "Артериальная гипертония", shortDescription: "Стойкое повышение артериального давления."),
        Disease(id: "gout", nameRu: "Подагра", shortDescription: "Метаболическое заболевание с повышением мочевой кислоты."),
        Disease(id: "ckd", nameRu: "Хроническая болезнь почек (ХБП)", shortDescription: "Прогрессирующее снижение функции почек."),
        Disease(id: "ibs", nameRu: "Синдром раздражённого кишечника (СРК)", shortDescription: "Функциональное расстройство кишечника."),
        Disease(id: "gerd", nameRu: "ГЭРБ", shortDescription: "Рефлюкс желудочного содержимого."),
        Disease(id: "gastritis", nameRu: "Гастрит", shortDescription: "Воспаление слизистой желудка."),
        Disease(id: "dyslipidemia", nameRu: "Дислипидемия", shortDescription: "Нарушение липидного обмена."),
        Disease(id: "celiac", nameRu: "Целиакия", shortDescription: "Непереносимость глютена."),
        Disease(id: "obesity", nameRu: "Ожирение", shortDescription: "Избыточная масса тела.")
    ]

    static func byId(_ id: String) -> Disease? {
        all.first { $0.id == id }
    }
}
