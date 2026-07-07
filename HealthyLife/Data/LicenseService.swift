import Foundation

final class LicenseStore {
    private let key = "nutriheal_license"
    private let defaults = UserDefaults.standard

    func load() -> StoredLicense? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(StoredLicense.self, from: data)
    }

    func save(_ license: StoredLicense) {
        if let data = try? JSONEncoder().encode(license) {
            defaults.set(data, forKey: key)
        }
    }

    func clear() {
        defaults.removeObject(forKey: key)
    }

    func deviceId() -> String {
        let installKey = "nutriheal_installation_id"
        if let existing = defaults.string(forKey: installKey) { return existing }
        let id = UUID().uuidString.lowercased()
        defaults.set(id, forKey: installKey)
        return id
    }
}

private struct LicenseAPI {
    struct ActivateRequest: Encodable {
        let code: String
        let deviceId: String
        let appVersion: String

        enum CodingKeys: String, CodingKey {
            case code
            case deviceId = "device_id"
            case appVersion = "app_version"
        }
    }

    struct ActivateResponse: Decodable {
        let ok: Bool?
        let sessionToken: String
        let expiresAt: String?
        let message: String?

        enum CodingKeys: String, CodingKey {
            case ok
            case sessionToken = "session_token"
            case expiresAt = "expires_at"
            case message
        }
    }

    struct VerifyRequest: Encodable {
        let deviceId: String
        let sessionToken: String

        enum CodingKeys: String, CodingKey {
            case deviceId = "device_id"
            case sessionToken = "session_token"
        }
    }

    struct VerifyResponse: Decodable {
        let ok: Bool
        let expiresAt: String?
        let message: String?

        enum CodingKeys: String, CodingKey {
            case ok
            case expiresAt = "expires_at"
            case message
        }
    }

    struct AutoTrialRequest: Encodable {
        let deviceId: String
        let appVersion: String
        let channel: String

        enum CodingKeys: String, CodingKey {
            case deviceId = "device_id"
            case appVersion = "app_version"
            case channel
        }
    }

    struct AutoTrialResponse: Decodable {
        let ok: Bool?
        let sessionToken: String?
        let code: String?
        let expiresAt: String?
        let message: String?
        let detail: String?

        enum CodingKeys: String, CodingKey {
            case ok
            case sessionToken = "session_token"
            case code
            case expiresAt = "expires_at"
            case message
            case detail
        }
    }
}

actor LicenseService {
    private let store = LicenseStore()
    private let offlineGraceSeconds: TimeInterval = 14 * 24 * 3600

    func bootstrapAccess() async -> (LicenseStatus, Bool) {
        var trialExpired = false
        if AppConfig.autoTrialEnabled, store.load() == nil {
            do {
                try await requestAutoTrial()
            } catch {
                let msg = error.localizedDescription
                trialExpired = msg.localizedCaseInsensitiveContains("завершён") || msg.localizedCaseInsensitiveContains("использован")
            }
        }
        let status = await evaluateAccess()
        return (status, trialExpired)
    }

    func requestAutoTrial() async throws {
        let body = LicenseAPI.AutoTrialRequest(
            deviceId: store.deviceId(),
            appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0",
            channel: AppConfig.distributionChannel
        )
        let response: LicenseAPI.AutoTrialResponse = try await post("/api/v1/auto-trial", body: body)
        guard let token = response.sessionToken else {
            throw LicenseError.server(response.detail ?? response.message ?? "Ошибка автотриала")
        }
        store.save(StoredLicense(
            installationId: store.deviceId(),
            sessionToken: token,
            code: response.code ?? "AUTO-TRIAL",
            expiresAt: response.expiresAt,
            lastVerifiedAt: Date()
        ))
    }

    func evaluateAccess() async -> LicenseStatus {
        guard let stored = store.load() else { return .needsActivation }
        if isExpiredLocally(stored.expiresAt) {
            store.clear()
            return .needsActivation
        }
        do {
            let valid = try await verify(stored: stored)
            if valid { return .licensed }
            store.clear()
            return .needsActivation
        } catch {
            if Date().timeIntervalSince(stored.lastVerifiedAt) < offlineGraceSeconds {
                return .licensed
            }
            return .needsActivation
        }
    }

    func activate(code: String) async throws {
        let normalized = code.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        let body = LicenseAPI.ActivateRequest(
            code: normalized,
            deviceId: store.deviceId(),
            appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        )
        let response: LicenseAPI.ActivateResponse = try await post("/api/v1/activate", body: body)
        store.save(StoredLicense(
            installationId: store.deviceId(),
            sessionToken: response.sessionToken,
            code: normalized,
            expiresAt: response.expiresAt,
            lastVerifiedAt: Date()
        ))
    }

    func deactivate() {
        store.clear()
    }

    private func isExpiredLocally(_ expiresAt: String?) -> Bool {
        guard let expiresAt, let date = parseDate(expiresAt) else { return false }
        return date <= Date()
    }

    private func parseDate(_ value: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = formatter.date(from: value) { return d }
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: value)
    }

    func expiryNoticeText() -> String? {
        guard let stored = store.load(), let expiresAt = stored.expiresAt else { return nil }
        guard let expiry = parseDate(expiresAt), expiry > Date() else { return nil }
        let days = Calendar.current.dateComponents([.day], from: Date(), to: expiry).day ?? 0
        if days <= 0 {
            return "Пробный доступ заканчивается сегодня. Продлите в Telegram @HealthyLifePlan_bot"
        }
        if days == 1 {
            return "Пробный доступ: остался 1 день. Продлите в @HealthyLifePlan_bot"
        }
        if days <= 14 {
            return "Пробный доступ: осталось \(days) дн. Продлите в @HealthyLifePlan_bot"
        }
        return nil
    }

    private func verify(stored: StoredLicense) async throws -> Bool {
        let body = LicenseAPI.VerifyRequest(deviceId: stored.installationId, sessionToken: stored.sessionToken)
        let decoded: LicenseAPI.VerifyResponse = try await post("/api/v1/verify", body: body)
        if decoded.ok {
            store.save(StoredLicense(
                installationId: stored.installationId,
                sessionToken: stored.sessionToken,
                code: stored.code,
                expiresAt: decoded.expiresAt ?? stored.expiresAt,
                lastVerifiedAt: Date()
            ))
        }
        return decoded.ok
    }

    private func post<T: Encodable, R: Decodable>(_ path: String, body: T) async throws -> R {
        var request = URLRequest(url: URL(string: AppConfig.licenseBaseURL + path)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(AppConfig.licenseAppKey, forHTTPHeaderField: "X-App-Key")
        request.httpBody = try JSONEncoder().encode(body)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw URLError(.badServerResponse) }
        if http.statusCode >= 400 {
            if let err = try? JSONDecoder().decode([String: String].self, from: data),
               let msg = err["detail"] ?? err["message"] {
                throw LicenseError.server(msg)
            }
            throw LicenseError.server("Ошибка сервера (\(http.statusCode))")
        }
        return try JSONDecoder().decode(R.self, from: data)
    }
}

enum LicenseError: LocalizedError {
    case server(String)
    var errorDescription: String? {
        switch self {
        case .server(let msg): return msg
        }
    }
}
