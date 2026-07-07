import Foundation

enum DiseaseCatalog {
    static let all: [Disease] = [
        Disease(id: "masld", nameRu: "Жировой гепатоз печени (МАЖБП / MASLD)", shortDescription: "Накопление жира в печени при метаболических нарушениях.", dietPattern: "Средиземноморская диета, дефицит калорий при избыточном весе"),
        Disease(id: "peptic_ulcer", nameRu: "Язва желудка / двенадцатиперстной кишки", shortDescription: "Повреждение слизистой ЖКТ.", dietPattern: "Сбалансированное питание + индивидуальная переносимость"),
        Disease(id: "type2_diabetes", nameRu: "Сахарный диабет 2 типа", shortDescription: "Нарушение углеводного обмена.", dietPattern: "Низкий ГИ, контроль углеводов и сахара"),
        Disease(id: "hypertension", nameRu: "Артериальная гипертония", shortDescription: "Стойкое повышение артериального давления.", dietPattern: "DASH / ограничение соли"),
        Disease(id: "gout", nameRu: "Подагра", shortDescription: "Метаболическое заболевание с повышением мочевой кислоты.", dietPattern: "Ограничение пуринов, достаточное потребление жидкости"),
        Disease(id: "ckd", nameRu: "Хроническая болезнь почек (ХБП)", shortDescription: "Прогрессирующее снижение функции почек.", dietPattern: "Индивидуальный белок, фосфор, калий по стадии"),
        Disease(id: "ibs", nameRu: "Синдром раздражённого кишечника (СРК)", shortDescription: "Функциональное расстройство кишечника.", dietPattern: "FODMAP / индивидуальная переносимость"),
        Disease(id: "gerd", nameRu: "ГЭРБ", shortDescription: "Рефлюкс желудочного содержимого.", dietPattern: "Дробное питание, ограничение триггеров"),
        Disease(id: "gastritis", nameRu: "Гастрит", shortDescription: "Воспаление слизистой желудка.", dietPattern: "Щадящее питание, отказ от раздражителей"),
        Disease(id: "dyslipidemia", nameRu: "Дислипидемия", shortDescription: "Нарушение липидного обмена.", dietPattern: "Средиземноморская / ограничение насыщенных жиров"),
        Disease(id: "celiac", nameRu: "Целиакия", shortDescription: "Непереносимость глютена.", dietPattern: "Строго безглютеновая диета"),
        Disease(id: "obesity", nameRu: "Ожирение", shortDescription: "Избыточная масса тела.", dietPattern: "Дефицит калорий, высокая насыщенность белком и клетчаткой")
    ]

    static func byId(_ id: String) -> Disease? {
        all.first { $0.id == id }
    }
}
