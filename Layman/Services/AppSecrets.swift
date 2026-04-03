import Foundation

/// API keys and URLs. Values come from `Secrets.plist` in the app bundle (not committed).
/// Copy `Secrets.plist.example` → `Secrets.plist` in this folder and fill in your keys.
public enum AppSecrets {
    private static let secrets: [String: String] = {
        guard let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let root = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil),
              let dict = root as? [String: String] else {
            #if DEBUG
            print("Layman: Add Secrets.plist (copy from Secrets.plist.example) with your API keys.")
            #endif
            return [:]
        }
        return dict
    }()

    private static func value(_ key: String) -> String {
        (secrets[key] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public static let supabaseURL: String = value("SUPABASE_URL")
    public static let supabaseAnonKey: String = value("SUPABASE_ANON_KEY")
    public static let newsDataAPIKey: String = value("NEWSDATA_API_KEY")
    public static let geminiAPIKey: String = value("GEMINI_API_KEY")
}
