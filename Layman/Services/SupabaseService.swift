import Foundation

public enum AuthServiceError: Error {
    case loginFailed(String)
    case signupFailed(String)
    case unknown
}

public protocol AuthServiceType {
    // These methods will interface with `supabase-swift` package
    func signUp(email: String, password: String) async throws
    func signIn(email: String, password: String) async throws
    func signOut() async throws
}

public class SupabaseService: AuthServiceType {
    public static let shared = SupabaseService()
    
    // Once supabse package is included:
    // private let client = SupabaseClient(
    //    supabaseURL: URL(string: Environment.supabaseURL)!,
    //    supabaseKey: Environment.supabaseAnonKey
    // )
    
    private init() {}
    
    public func signUp(email: String, password: String) async throws {
        // Implementation will call:
        // try await client.auth.signUp(email: email, password: password)
    }
    
    public func signIn(email: String, password: String) async throws {
        // Implementation will call:
        // try await client.auth.signInWithPassword(email: email, password: password)
    }
    
    public func signOut() async throws {
        // try await client.auth.signOut()
    }
}
