import Foundation

enum MenopauseNutrition {
    static let calciumMgPost = 1200
    static let calciumMgPeri = 1000
    static let vitaminDMcg = 20
    static let vitaminDIU = 800
    static let proteinGPerKgPeri: Float = 1.0
    static let proteinGPerKgPost: Float = 1.1
    static let caffeineMgMax = 200

    static func proteinMinG(status: MenopauseStatus, weightKg: Float) -> Int {
        switch status {
        case .perimenopause: return Int((proteinGPerKgPeri * weightKg).rounded())
        case .postmenopause: return Int((proteinGPerKgPost * weightKg).rounded())
        case .none: return 0
        }
    }

    static func calciumMg(status: MenopauseStatus) -> Int {
        switch status {
        case .perimenopause: return calciumMgPeri
        case .postmenopause: return calciumMgPost
        case .none: return 0
        }
    }
}
