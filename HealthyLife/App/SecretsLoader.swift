import Foundation

enum SecretsLoader {
    private static let cache: [String: String] = {
        guard let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let dict = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: String]
        else { return [:] }
        return dict
    }()

    static func value(_ key: String) -> String? {
        let v = cache[key]?.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let v, !v.isEmpty, !v.hasPrefix("YOUR_") else { return nil }
        return v
    }
}
