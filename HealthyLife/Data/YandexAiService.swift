import Foundation

struct AiReply {
    let text: String
    let model: String?
}

final class YandexAiService {
    static let shared = YandexAiService()
    private init() {}

    private let baseURL = "https://ai.api.cloud.yandex.net/v1/chat/completions"
    private let modelName = "deepseek-v4-flash/latest"

    func ask(
        question: String,
        profile: UserProfile?,
        plan: WeeklyPlan?,
        history: [ChatMessage]
    ) async throws -> AiReply {
        let apiKey = AppConfig.yandexApiKey
        let folderId = AppConfig.yandexFolderId
        guard !apiKey.isEmpty, !folderId.isEmpty else {
            return AiReply(
                text: "ИИ-советник недоступен: не настроен Yandex API.",
                model: nil
            )
        }

        let systemPrompt = """
        Ты — диетолог-ассистент приложения Healthy Life. Отвечай кратко на русском.
        Не назначай лечение и лекарства. Рекомендации носят справочный характер.
        """

        var patientContext = "Профиль не заполнен."
        if let profile, let disease = DiseaseCatalog.byId(profile.diseaseId) {
            patientContext = """
            Заболевание: \(disease.nameRu)
            Возраст: \(profile.age), пол: \(profile.gender.labelRu)
            Вес: \(String(format: "%.1f", profile.weightKg)) кг, рост: \(profile.heightCm) см
            """
            if let plan {
                patientContext += "\nЦель калорий: \(plan.targetKcal) ккал/день, режим: \(plan.patternName)"
            }
        }

        var messages: [[String: String]] = [
            ["role": "system", "content": systemPrompt],
            ["role": "user", "content": "Контекст пациента:\n\(patientContext)"],
            ["role": "assistant", "content": "Контекст принят. Готов анализировать питание."]
        ]
        for msg in history.suffix(10) where msg.role != "system" {
            messages.append(["role": msg.role, "content": msg.content])
        }
        messages.append(["role": "user", "content": question])

        let body: [String: Any] = [
            "model": "gpt://\(folderId)/\(modelName)",
            "messages": messages,
            "temperature": 0.3,
            "max_tokens": 2000
        ]

        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Api-Key \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("false", forHTTPHeaderField: "x-data-logging-enabled")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw URLError(.badServerResponse) }

        if http.statusCode == 429 {
            throw LicenseError.server("Превышен лимит запросов Yandex AI. Подождите минуту.")
        }
        if http.statusCode == 401 || http.statusCode == 403 {
            throw LicenseError.server("Неверный API-ключ или нет доступа к каталогу Yandex Cloud.")
        }
        if http.statusCode >= 400 {
            let snippet = String(data: data, encoding: .utf8)?.prefix(200) ?? ""
            throw LicenseError.server("Ошибка Yandex AI (\(http.statusCode)): \(snippet)")
        }

        struct CompletionResponse: Decodable {
            struct Choice: Decodable {
                struct Message: Decodable {
                    let content: String?
                    let reasoningContent: String?

                    enum CodingKeys: String, CodingKey {
                        case content
                        case reasoningContent = "reasoning_content"
                    }
                }
                let message: Message?
            }
            let choices: [Choice]?
        }

        let decoded = try JSONDecoder().decode(CompletionResponse.self, from: data)
        let message = decoded.choices?.first?.message
        let text = message?.content?.trimmingCharacters(in: .whitespacesAndNewlines)
            ?? message?.reasoningContent?.trimmingCharacters(in: .whitespacesAndNewlines)
            ?? ""
        guard !text.isEmpty else {
            throw LicenseError.server("Пустой ответ Yandex AI")
        }
        return AiReply(text: text, model: "DeepSeek V4 Flash")
    }
}
