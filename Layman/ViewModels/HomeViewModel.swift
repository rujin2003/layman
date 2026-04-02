import Foundation
import Combine

public class HomeViewModel: ObservableObject {
    @Published var articles: [Article] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""

    var featuredArticles: [Article] {
        let source = filteredArticles
        return Array(source.prefix(min(5, source.count)))
    }

    var todaysPicks: [Article] {
        let source = filteredArticles
        guard source.count > 3 else { return [] }
        return Array(source.dropFirst(3))
    }

    var filteredArticles: [Article] {
        if searchText.isEmpty { return articles }
        let query = searchText.lowercased()
        return articles.filter { article in
            article.title.lowercased().contains(query)
            || (article.description?.lowercased().contains(query) ?? false)
            || (article.sourceID?.lowercased().contains(query) ?? false)
        }
    }

    private let networkService = NetworkService.shared

    func fetchArticles() {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let fetched = try await networkService.fetchArticles()
                if fetched.isEmpty {
                    self.articles = Article.mocks
                } else {
                    self.articles = fetched
                }
                self.isLoading = false
            } catch {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
                if self.articles.isEmpty {
                    self.articles = Article.mocks
                }
            }
        }
    }

    func refresh() async {
        isLoading = true
        errorMessage = nil
        do {
            let fetched = try await networkService.fetchArticles()
            self.articles = fetched.isEmpty ? Article.mocks : fetched
        } catch {
            self.errorMessage = error.localizedDescription
            if self.articles.isEmpty { self.articles = Article.mocks }
        }
        self.isLoading = false
    }
}
