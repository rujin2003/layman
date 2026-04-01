import Foundation
import Combine

@MainActor
public class HomeViewModel: ObservableObject {
    @Published public var articles: [Article] = []
    @Published public var isLoading = false
    @Published public var errorMessage: String?
    
    // For the UI, we'll split articles into featured and 'today's picks'
    public var featuredArticles: [Article] {
        Array(articles.prefix(3))
    }
    
    public var todaysPicks: [Article] {
        guard articles.count > 3 else { return [] }
        return Array(articles.dropFirst(3))
    }
    
    private let networkService: NetworkServiceType
    
    public init(networkService: NetworkServiceType = NetworkService.shared) {
        self.networkService = networkService
    }
    
    public func fetchArticles() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // To simulate loading feel, we could delay, but let's just fetch
                let fetched = try await networkService.fetchArticles()
                
                // Set to fallback mock data if empty (since valid API keys might not be present initially)
                if fetched.isEmpty {
                    self.articles = Article.mocks + Article.mocks
                } else {
                    self.articles = fetched
                }
                self.isLoading = false
            } catch {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
                // Fallback for development if API fails
                self.articles = Article.mocks + Article.mocks
                print("Using mock data due to fetch error: \(error)")
            }
        }
    }
}
