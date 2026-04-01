import Foundation

public enum Environment {
    enum Keys {
        static let supabaseURL = "SUPABASE_URL"
        static let supabaseAnonKey = "SUPABASE_ANON_KEY"
        static let newsDataAPIKey = "NEWSDATA_API_KEY"
        static let geminiAPIKey = "GEMINI_API_KEY"
    }
    
    // Get variables from Info.plist which is populated by Config.xcconfig
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("Info.plist file not found")
        }
        return dict
    }()
    
    static let supabaseURL: String = {
        guard let urlString = Environment.infoDictionary[Keys.supabaseURL] as? String else {
            // Provide a fallback or print warning so the UI components don't crash in preview
            print("⚠️ Warning: SUPABASE_URL not set in environment or Config.xcconfig")
            return "https://YOUR_PROJECT_REF.supabase.co"
        }
        return urlString
    }()
    
    static let supabaseAnonKey: String = {
        guard let key = Environment.infoDictionary[Keys.supabaseAnonKey] as? String else {
            print("⚠️ Warning: SUPABASE_ANON_KEY not set in environment or Config.xcconfig")
            return "YOUR_SUPABASE_ANON_KEY"
        }
        return key
    }()
    
    static let newsDataAPIKey: String = {
        guard let key = Environment.infoDictionary[Keys.newsDataAPIKey] as? String else {
            print("⚠️ Warning: NEWSDATA_API_KEY not set in environment or Config.xcconfig")
            return "YOUR_NEWSDATA_API_KEY"
        }
        return key
    }()
    
    static let geminiAPIKey: String = {
        guard let key = Environment.infoDictionary[Keys.geminiAPIKey] as? String else {
            print("⚠️ Warning: GEMINI_API_KEY not set in environment or Config.xcconfig")
            return "YOUR_GEMINI_API_KEY"
        }
        return key
    }()
}
