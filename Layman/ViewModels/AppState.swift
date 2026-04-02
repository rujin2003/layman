import Foundation
import SwiftUI
import Combine

public enum AppScreen: Equatable {
    case welcome
    case auth
    case main
}

public class AppState: ObservableObject {
    private static let appearanceStorageKey = "layman_appearance_mode"

    @Published public var currentScreen: AppScreen = .welcome
    @Published public var isLoggedIn: Bool = false
    @Published public var isCheckingSession: Bool = true
    @Published public var savedArticleIDs: Set<String> = []
    @Published public var appearanceMode: AppearanceMode = .system {
        didSet {
            UserDefaults.standard.set(appearanceMode.rawValue, forKey: Self.appearanceStorageKey)
        }
    }

    let supabase = SupabaseService.shared

    public init() {
        if let raw = UserDefaults.standard.string(forKey: Self.appearanceStorageKey),
           let stored = AppearanceMode(rawValue: raw) {
            appearanceMode = stored
        }
        checkExistingSession()
    }

    private func checkExistingSession() {
        if supabase.isAuthenticated {
            Task {
                let restored = await supabase.restoreSession()
                self.isCheckingSession = false
                if restored {
                    self.isLoggedIn = true
                    self.currentScreen = .main
                    await self.refreshSavedArticleIDs()
                }
            }
        } else {
            isCheckingSession = false
        }
    }

    func login() {
        withAnimation(.easeInOut(duration: 0.4)) {
            isLoggedIn = true
            currentScreen = .main
        }
        Task { await refreshSavedArticleIDs() }
    }

    func logout() async {
        await supabase.signOut()
        withAnimation(.easeInOut(duration: 0.4)) {
            isLoggedIn = false
            currentScreen = .welcome
            savedArticleIDs = []
        }
    }

    func toggleSaveArticle(_ article: Article) async {
        if savedArticleIDs.contains(article.id) {
            savedArticleIDs.remove(article.id)
            try? await supabase.unsaveArticle(articleId: article.id)
        } else {
            savedArticleIDs.insert(article.id)
            try? await supabase.saveArticle(article)
        }
    }

    func isArticleSaved(_ article: Article) -> Bool {
        savedArticleIDs.contains(article.id)
    }

    func refreshSavedArticleIDs() async {
        if let articles = try? await supabase.fetchSavedArticles() {
            savedArticleIDs = Set(articles.map { $0.id })
        }
    }
}
