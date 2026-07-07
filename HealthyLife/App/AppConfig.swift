import Foundation

enum AppConfig {
    static let autoTrialEnabled = true
    static let autoTrialDays = 3
    static let distributionChannel = "ios"

    static var licenseBaseURL: String {
        Bundle.main.object(forInfoDictionaryKey: "LICENSE_BASE_URL") as? String
            ?? "http://213.176.94.59:8080"
    }

    static var licenseAppKey: String {
        Bundle.main.object(forInfoDictionaryKey: "LICENSE_APP_KEY") as? String
            ?? "NH-lic-2026-Xk9mQ2pL7vRw4nT1"
    }

    static var yandexApiKey: String {
        SecretsLoader.value("YANDEX_API_KEY")
            ?? Bundle.main.object(forInfoDictionaryKey: "YANDEX_API_KEY") as? String
            ?? ""
    }

    static var yandexFolderId: String {
        SecretsLoader.value("YANDEX_FOLDER_ID")
            ?? Bundle.main.object(forInfoDictionaryKey: "YANDEX_FOLDER_ID") as? String
            ?? ""
    }
}
