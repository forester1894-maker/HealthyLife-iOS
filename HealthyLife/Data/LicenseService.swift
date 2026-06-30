import Foundation

enum AppConfig {
    static var licenseBaseURL: String {
        Bundle.main.object(forInfoDictionaryKey: "LICENSE_BASE_URL") as? String
            ?? "http://213.176.94.59:8080"
    }

    static var licenseAppKey: String {
        Bundle.main.object(forInfoDictionaryKey: "LICENSE_APP_KEY") as? String
            ?? "NH-lic-2026-Xk9mQ2pL7vRw4nT1"
    }

    static var yandexApiKey: String {
        Bundle.main.object(forInfoDictionaryKey: "YANDEX_API_KEY") as? String ?? ""
    }

    static var yandexFolderId: String {
        Bundle.main.object(forInfoDictionaryKey: "YANDEX_FOLDER_ID") as? String ?? ""
    }
}

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
}

actor LicenseService {
    private let store = LicenseStore()

    func evaluateAccess() async -> LicenseStatus {
        guard let stored = store.load() else { return .needsActivation }
        do {
            let valid = try await verify(stored: stored)
            if valid { return .licensed }
            store.clear()
            return .needsActivation
        } catch {
            if Date().timeIntervalSince(stored.lastVerifiedAt) < 72 * 3600 {
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
