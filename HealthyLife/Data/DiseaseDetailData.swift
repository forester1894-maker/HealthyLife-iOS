import Foundation

struct DiseaseDetailInfo {
    let keyGoals: [String]
    let recommendedFoods: [String]
    let limitFoods: [String]
    let lifestyleTips: [String]
    let macroGuidance: String
    let sources: [String]
}

enum DiseaseDetailData {
    static func info(for diseaseId: String) -> DiseaseDetailInfo? {
        details[diseaseId]
    }

    private static let details: [String: DiseaseDetailInfo] = [
        "masld": DiseaseDetailInfo(
            keyGoals: ["Снижение массы тела на 5–10% при избыточном весе", "Улучшение качества рациона", "Отказ от алкоголя и сладких напитков"],
            recommendedFoods: ["Овощи и фрукты", "Цельнозерновые", "Рыба 2–3 раза в неделю", "Бобовые, орехи", "Оливковое масло"],
            limitFoods: ["Ультрапереработанные продукты", "Сахар и сладкие напитки", "Насыщенные жиры", "Алкоголь"],
            lifestyleTips: ["150+ минут активности в неделю", "Дефицит 500–1000 ккал при ожирении"],
            macroGuidance: "Акцент на клетчатку, ПНЖ, умеренный белок.",
            sources: ["EASL–EASD–EASO MASLD Guidelines"]
        ),
        "type2_diabetes": DiseaseDetailInfo(
            keyGoals: ["Контроль гликемии", "Снижение веса при ожирении", "Регулярный режим питания"],
            recommendedFoods: ["Овощи безкрахмальные", "Цельнозерновые", "Нежирный белок", "Бобовые"],
            limitFoods: ["Сахар", "Сладкие напитки", "Белый хлеб", "Жареное и фастфуд"],
            lifestyleTips: ["Регулярные приёмы пищи", "Физическая активность по согласованию с врачом"],
            macroGuidance: "Равномерное распределение углеводов, контроль порций.",
            sources: ["ADA Standards of Care"]
        ),
        "hypertension": DiseaseDetailInfo(
            keyGoals: ["Снижение соли", "Поддержание нормального веса", "Контроль давления"],
            recommendedFoods: ["Овощи", "Фрукты", "Нежирные молочные", "Рыба", "Орехи"],
            limitFoods: ["Соль >5 г/день", "Колбасы", "Консервы", "Алкоголь в избытке"],
            lifestyleTips: ["DASH-рацион", "Регулярная активность", "Контроль стресса"],
            macroGuidance: "Калий из овощей и фруктов, ограничение натрия.",
            sources: ["ESC/ESH Hypertension Guidelines"]
        ),
        "gout": DiseaseDetailInfo(
            keyGoals: ["Снижение мочевой кислоты", "Профилактика приступов", "Нормализация веса"],
            recommendedFoods: ["Овощи", "Нежирные молочные", "Яйца", "Цельнозерновые", "Вода"],
            limitFoods: ["Красное мясо", "Субпродукты", "Алкоголь", "Сладкие напитки с фруктозой"],
            lifestyleTips: ["Достаточное потребление воды", "Ограничение алкоголя"],
            macroGuidance: "Умеренный белок, акцент на растительную пищу.",
            sources: ["ACR Gout Guidelines"]
        ),
        "gerd": DiseaseDetailInfo(
            keyGoals: ["Снижение рефлюкса", "Контроль триггеров", "Поддержание веса"],
            recommendedFoods: ["Овощи", "Нежирный белок", "Цельнозерновые", "Некислые фрукты"],
            limitFoods: ["Жирное и жареное", "Кофе (при непереносимости)", "Шоколад", "Алкоголь"],
            lifestyleTips: ["Не ложиться сразу после еды", "Дробное питание"],
            macroGuidance: "Индивидуальная переносимость важнее жёстких запретов.",
            sources: ["ACG GERD Guidelines"]
        ),
        "obesity": DiseaseDetailInfo(
            keyGoals: ["Устойчивое снижение веса", "Сохранение мышечной массы", "Формирование привычек"],
            recommendedFoods: ["Овощи", "Нежирный белок", "Цельнозерновые", "Бобовые"],
            limitFoods: ["Сладости", "Фастфуд", "Сладкие напитки", "Перекусы вне режима"],
            lifestyleTips: ["Дефицит 500–750 ккал", "Регулярная активность"],
            macroGuidance: "Достаточный белок и клетчатка для насыщения.",
            sources: ["WHO Obesity Guidelines"]
        )
    ]
}
