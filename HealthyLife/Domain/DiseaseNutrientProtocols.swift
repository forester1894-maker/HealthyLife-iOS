import Foundation

struct DiseaseNutrientProtocol {
    let diseaseId: String
    let patternName: String
    var sodiumMgMax: Int?
    var addedSugarGMax: Int?
    var saturatedFatPercentMax: Int?
    var carbsPerMealGMax: Int?
    var proteinGPerKgMax: Float?
    var fiberGMin: Int?
    var waterGlasses: Int?
    var waterLiters: String?
    var waterNote: String?
    var fatBeneficial: [String] = []
    var fatLimit: [String] = []
    var fatAvoid: [String] = []
    var omega3Guidance: String?
    var potassiumGuidance: String?
    var rules: [TherapeuticNutrientRule] = []
    var evidence: String = ""
}

enum DiseaseNutrientProtocols {
    static let byId: [String: DiseaseNutrientProtocol] = [
        masld().diseaseId: masld(),
        hypertension().diseaseId: hypertension(),
        type2Diabetes().diseaseId: type2Diabetes(),
        dyslipidemia().diseaseId: dyslipidemia(),
        ckd().diseaseId: ckd(),
        gout().diseaseId: gout(),
        gerd().diseaseId: gerd(),
        pepticUlcer().diseaseId: pepticUlcer(),
        gastritis().diseaseId: gastritis(),
        ibs().diseaseId: ibs(),
        celiac().diseaseId: celiac(),
        obesity().diseaseId: obesity()
    ]

    private static func masld() -> DiseaseNutrientProtocol {
        DiseaseNutrientProtocol(
            diseaseId: "masld", patternName: "Средиземноморская / лечебная при МАЖБП",
            sodiumMgMax: 2300, addedSugarGMax: 25, saturatedFatPercentMax: 10, fiberGMin: 25,
            waterGlasses: 8, waterLiters: "1,5–2,5 л",
            waterNote: "Достаточная гидратация; исключить сладкие напитки и фруктозу",
            fatBeneficial: ["Оливковое масло (MUFA)", "Омега-3 из рыбы", "Орехи, семена"],
            fatLimit: ["Насыщенные жиры <10%", "Простые сахара и фруктоза"],
            fatAvoid: ["Трансжиры", "Алкоголь"],
            omega3Guidance: "Омега-3: 2–3 порции жирной рыбы в неделю (EASL/EASD)",
            evidence: "EASL–EASD–EASO MASLD 2024"
        )
    }

    private static func hypertension() -> DiseaseNutrientProtocol {
        DiseaseNutrientProtocol(
            diseaseId: "hypertension", patternName: "DASH / ограничение натрия",
            sodiumMgMax: 1500, addedSugarGMax: 25, saturatedFatPercentMax: 6, fiberGMin: 25,
            waterGlasses: 6, waterLiters: "1,5–2 л",
            waterNote: "При гипертонии ключевое — соль, не голодание по воде",
            fatBeneficial: ["Омега-3 из рыбы", "Оливковое масло", "Орехи несолёные"],
            fatAvoid: ["Трансжиры", "Солёные снеки"],
            potassiumGuidance: "Калий из пищи (овощи, бобовые): ориентир DASH",
            omega3Guidance: "Омега-3: 2 порции рыбы в неделю (AHA)",
            evidence: "AHA/ACC; DASH-Sodium Trial"
        )
    }

    private static func type2Diabetes() -> DiseaseNutrientProtocol {
        DiseaseNutrientProtocol(
            diseaseId: "type2_diabetes", patternName: "Контроль углеводов и ГИ",
            sodiumMgMax: 2300, addedSugarGMax: 25, saturatedFatPercentMax: 10,
            carbsPerMealGMax: 60, fiberGMin: 25, waterGlasses: 8, waterLiters: "1,5–2,5 л",
            fatBeneficial: ["Омега-3", "MUFA", "Орехи"],
            omega3Guidance: "Омега-3: жирная рыба 2 раза в неделю",
            evidence: "ADA Standards of Care"
        )
    }

    private static func dyslipidemia() -> DiseaseNutrientProtocol {
        DiseaseNutrientProtocol(
            diseaseId: "dyslipidemia", patternName: "Снижение ТГ и ЛПНП",
            sodiumMgMax: 2300, addedSugarGMax: 25, saturatedFatPercentMax: 7, fiberGMin: 25,
            waterGlasses: 8, waterLiters: "1,5–2,5 л",
            fatBeneficial: ["Омега-3", "Растительные стеролы", "Орехи"],
            fatAvoid: ["Трансжиры", "Насыщенные жиры"],
            omega3Guidance: "Омега-3: 2–3 г EPA+DHA/сут по назначению врача",
            evidence: "ESC/EAS Dyslipidemia"
        )
    }

    private static func ckd() -> DiseaseNutrientProtocol {
        DiseaseNutrientProtocol(
            diseaseId: "ckd", patternName: "Почечная диета по стадии",
            sodiumMgMax: 2000, addedSugarGMax: 25, saturatedFatPercentMax: 10,
            proteinGPerKgMax: 0.8, waterGlasses: 5, waterLiters: "1–1,5 л (по нефрологу)",
            waterNote: "Объём жидкости индивидуален по стадии ХБП",
            evidence: "KDIGO CKD"
        )
    }

    private static func gout() -> DiseaseNutrientProtocol {
        DiseaseNutrientProtocol(
            diseaseId: "gout", patternName: "Низкопуриновый",
            sodiumMgMax: 2300, addedSugarGMax: 25, saturatedFatPercentMax: 10,
            waterGlasses: 10, waterLiters: "2–2,5 л",
            waterNote: "Обильное питьё для выведения мочевой кислоты",
            fatAvoid: ["Алкоголь", "Сладкие напитки с фруктозой"],
            evidence: "ACR Gout Guidelines"
        )
    }

    private static func gerd() -> DiseaseNutrientProtocol {
        DiseaseNutrientProtocol(
            diseaseId: "gerd", patternName: "Щадящий при ГЭРБ",
            sodiumMgMax: 2300, addedSugarGMax: 30, saturatedFatPercentMax: 10,
            waterGlasses: 8, waterLiters: "1,5–2 л",
            fatLimit: ["Жирное, жареное", "Кофе, шоколад, мята"],
            evidence: "ACG GERD Guidelines"
        )
    }

    private static func pepticUlcer() -> DiseaseNutrientProtocol {
        DiseaseNutrientProtocol(
            diseaseId: "peptic_ulcer", patternName: "Щадящий при язве",
            sodiumMgMax: 2300, addedSugarGMax: 30, saturatedFatPercentMax: 10,
            waterGlasses: 8, waterLiters: "1,5–2 л",
            fatLimit: ["Острое, копчёное", "Кофе, алкоголь"],
            evidence: "Clinical nutrition"
        )
    }

    private static func gastritis() -> DiseaseNutrientProtocol {
        DiseaseNutrientProtocol(
            diseaseId: "gastritis", patternName: "Щадящий при гастрите",
            sodiumMgMax: 2300, addedSugarGMax: 30, saturatedFatPercentMax: 10,
            waterGlasses: 8, waterLiters: "1,5–2 л",
            evidence: "Clinical nutrition"
        )
    }

    private static func ibs() -> DiseaseNutrientProtocol {
        DiseaseNutrientProtocol(
            diseaseId: "ibs", patternName: "FODMAP-адаптированный",
            sodiumMgMax: 2300, addedSugarGMax: 25, saturatedFatPercentMax: 10, fiberGMin: 20,
            waterGlasses: 8, waterLiters: "1,5–2,5 л",
            evidence: "Monash FODMAP"
        )
    }

    private static func celiac() -> DiseaseNutrientProtocol {
        DiseaseNutrientProtocol(
            diseaseId: "celiac", patternName: "Безглютеновый",
            sodiumMgMax: 2300, addedSugarGMax: 25, saturatedFatPercentMax: 10,
            waterGlasses: 8, waterLiters: "1,5–2,5 л",
            fatAvoid: ["Пшеница, рожь, ячмень", "Скрытый глютен"],
            evidence: "Coeliac Society"
        )
    }

    private static func obesity() -> DiseaseNutrientProtocol {
        DiseaseNutrientProtocol(
            diseaseId: "obesity", patternName: "Сбалансированный дефицит",
            sodiumMgMax: 2300, addedSugarGMax: 25, saturatedFatPercentMax: 10, fiberGMin: 25,
            waterGlasses: 8, waterLiters: "1,5–2,5 л",
            evidence: "WHO Obesity"
        )
    }
}
