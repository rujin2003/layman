import Foundation
import Combine

// MARK: - Auth Models

struct SupabaseUser: Codable {
    let id: String
    let email: String?
    let emailConfirmedAt: String?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id, email
        case emailConfirmedAt = "email_confirmed_at"
        case createdAt = "created_at"
    }
}

struct AuthResponse: Codable {
    let accessToken: String?
    let tokenType: String?
    let expiresIn: Int?
    let refreshToken: String?
    let user: SupabaseUser?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
        case user
    }
}

struct SupabaseErrorResponse: Codable {
    let message: String?
    let msg: String?
    let error: String?
    let errorDescription: String?

    enum CodingKeys: String, CodingKey {
        case message, msg, error
        case errorDescription = "error_description"
    }

    var displayMessage: String {
        errorDescription ?? message ?? msg ?? error ?? "Something went wrong"
    }
}

// MARK: - Errors

enum AuthError: LocalizedError {
    case loginFailed(String)
    case signupFailed(String)
    case confirmationRequired
    case notAuthenticated
    case networkError(String)

    var errorDescription: String? {
        switch self {
        case .loginFailed(let msg): return msg
        case .signupFailed(let msg): return msg
        case .confirmationRequired: return "Please check your email to confirm your account."
        case .notAuthenticated: return "You need to sign in first."
        case .networkError(let msg): return msg
        }
    }
}

// MARK: - Service

public class SupabaseService: ObservableObject {
    static let shared = SupabaseService()

    private let baseURL = AppSecrets.supabaseURL
    private let anonKey = AppSecrets.supabaseAnonKey

    @Published var currentUser: SupabaseUser?
    @Published var isAuthenticated = false

    private var accessToken: String? {
        get { UserDefaults.standard.string(forKey: "sb_access_token") }
        set { UserDefaults.standard.set(newValue, forKey: "sb_access_token") }
    }

    private var refreshToken: String? {
        get { UserDefaults.standard.string(forKey: "sb_refresh_token") }
        set { UserDefaults.standard.set(newValue, forKey: "sb_refresh_token") }
    }

    private var storedEmail: String? {
        get { UserDefaults.standard.string(forKey: "sb_user_email") }
        set { UserDefaults.standard.set(newValue, forKey: "sb_user_email") }
    }

    private var storedUserId: String? {
        get { UserDefaults.standard.string(forKey: "sb_user_id") }
        set { UserDefaults.standard.set(newValue, forKey: "sb_user_id") }
    }

    private init() {
        if let id = storedUserId, let token = accessToken, !token.isEmpty {
            currentUser = SupabaseUser(id: id, email: storedEmail, emailConfirmedAt: nil, createdAt: nil)
            isAuthenticated = true
        }
    }

    var userEmail: String { storedEmail ?? "" }
    var userId: String? { storedUserId }

    // MARK: - Sign Up

    func signUp(email: String, password: String) async throws {
        let url = URL(string: "\(baseURL)/auth/v1/signup")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(anonKey, forHTTPHeaderField: "apikey")

        let body: [String: String] = ["email": email, "password": password]
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw AuthError.networkError("No response from server")
        }

        if (200...299).contains(http.statusCode) {
            let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)

            if let token = authResponse.accessToken, !token.isEmpty,
               let refresh = authResponse.refreshToken,
               let user = authResponse.user {
                saveSession(token: token, refresh: refresh, user: user)
            } else {
                throw AuthError.confirmationRequired
            }
        } else {
            let err = try? JSONDecoder().decode(SupabaseErrorResponse.self, from: data)
            throw AuthError.signupFailed(err?.displayMessage ?? "Sign up failed (HTTP \(http.statusCode))")
        }
    }

    // MARK: - Sign In

    func signIn(email: String, password: String) async throws {
        let url = URL(string: "\(baseURL)/auth/v1/token?grant_type=password")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(anonKey, forHTTPHeaderField: "apikey")

        let body: [String: String] = ["email": email, "password": password]
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw AuthError.networkError("No response from server")
        }

        if http.statusCode == 200 {
            let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
            guard let token = authResponse.accessToken,
                  let refresh = authResponse.refreshToken,
                  let user = authResponse.user else {
                throw AuthError.loginFailed("Invalid response from server")
            }
            saveSession(token: token, refresh: refresh, user: user)
        } else {
            let err = try? JSONDecoder().decode(SupabaseErrorResponse.self, from: data)
            throw AuthError.loginFailed(err?.displayMessage ?? "Invalid email or password")
        }
    }

    // MARK: - Sign Out

    func signOut() async {
        if let token = accessToken {
            let url = URL(string: "\(baseURL)/auth/v1/logout")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue(anonKey, forHTTPHeaderField: "apikey")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            _ = try? await URLSession.shared.data(for: request)
        }
        clearSession()
    }

    // MARK: - Session Restore

    func restoreSession() async -> Bool {
        guard let refresh = refreshToken, !refresh.isEmpty else { return false }

        do {
            let url = URL(string: "\(baseURL)/auth/v1/token?grant_type=refresh_token")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(anonKey, forHTTPHeaderField: "apikey")
            request.httpBody = try JSONEncoder().encode(["refresh_token": refresh])

            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                clearSession()
                return false
            }

            let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
            if let token = authResponse.accessToken,
               let newRefresh = authResponse.refreshToken,
               let user = authResponse.user {
                saveSession(token: token, refresh: newRefresh, user: user)
                return true
            }
            clearSession()
            return false
        } catch {
            clearSession()
            return false
        }
    }

    // MARK: - Saved Articles

    func saveArticle(_ article: Article) async throws {
        guard let token = accessToken, let userId = currentUser?.id else {
            throw AuthError.notAuthenticated
        }

        let record = article.toSavedRecord(userId: userId)
        let url = URL(string: "\(baseURL)/rest/v1/saved_articles")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("return=minimal", forHTTPHeaderField: "Prefer")
        request.httpBody = try JSONEncoder().encode(record)

        let (_, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw AuthError.networkError("Failed to save article")
        }
    }

    func unsaveArticle(articleId: String) async throws {
        guard let token = accessToken, let userId = currentUser?.id else {
            throw AuthError.notAuthenticated
        }

        let urlString = "\(baseURL)/rest/v1/saved_articles?article_id=eq.\(articleId)&user_id=eq.\(userId)"
        guard let url = URL(string: urlString) else { throw AuthError.networkError("Invalid URL") }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (_, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw AuthError.networkError("Failed to remove saved article")
        }
    }

    func fetchSavedArticles() async throws -> [Article] {
        guard let token = accessToken, let userId = currentUser?.id else {
            throw AuthError.notAuthenticated
        }

        let urlString = "\(baseURL)/rest/v1/saved_articles?user_id=eq.\(userId)&select=*&order=saved_at.desc"
        guard let url = URL(string: urlString) else { throw AuthError.networkError("Invalid URL") }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw AuthError.networkError("Failed to fetch saved articles")
        }

        let records = try JSONDecoder().decode([SavedArticleRecord].self, from: data)
        return records.map { Article(from: $0) }
    }

    func deleteAllSavedArticles() async throws {
        guard let token = accessToken, let userId = currentUser?.id else {
            throw AuthError.notAuthenticated
        }

        let urlString = "\(baseURL)/rest/v1/saved_articles?user_id=eq.\(userId)"
        guard let url = URL(string: urlString) else { throw AuthError.networkError("Invalid URL") }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (_, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw AuthError.networkError("Failed to delete saved articles")
        }
    }

    func isArticleSaved(articleId: String) async -> Bool {
        guard let token = accessToken, let userId = currentUser?.id else { return false }

        let urlString = "\(baseURL)/rest/v1/saved_articles?article_id=eq.\(articleId)&user_id=eq.\(userId)&select=id"
        guard let url = URL(string: urlString) else { return false }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        guard let (data, _) = try? await URLSession.shared.data(for: request),
              let results = try? JSONDecoder().decode([[String: String]].self, from: data) else {
            return false
        }
        return !results.isEmpty
    }

    // MARK: - Private Helpers

    private func saveSession(token: String, refresh: String, user: SupabaseUser) {
        accessToken = token
        refreshToken = refresh
        storedEmail = user.email
        storedUserId = user.id
        currentUser = user
        isAuthenticated = true
    }

    private func clearSession() {
        accessToken = nil
        refreshToken = nil
        storedEmail = nil
        storedUserId = nil
        currentUser = nil
        isAuthenticated = false
    }
}
