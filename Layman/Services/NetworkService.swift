import Foundation

public enum NetworkError: Error, LocalizedError {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingFailed(Error)
    case rateLimited

    public var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid request URL"
        case .requestFailed(let err): return err.localizedDescription
        case .invalidResponse: return "Server returned an invalid response"
        case .decodingFailed: return "Could not read server response"
        case .rateLimited: return "Too many requests. Please try again later."
        }
    }
}

public class NetworkService {
    static let shared = NetworkService()

    private let baseURL = "https://newsdata.io/api/1/latest"
    private var apiKey: String { Environment.newsDataAPIKey }

    private init() {}

    func fetchArticles(query: String? = nil) async throws -> [Article] {
        var components = URLComponents(string: baseURL)
        var queryItems = [
            URLQueryItem(name: "apikey", value: apiKey),
            URLQueryItem(name: "category", value: "business,technology"),
            URLQueryItem(name: "language", value: "en"),
            URLQueryItem(name: "image", value: "1"),
            URLQueryItem(name: "removeduplicate", value: "1"),
            URLQueryItem(name: "size", value: "10")
        ]

        if let query = query, !query.isEmpty {
            queryItems.append(URLQueryItem(name: "q", value: query))
        }

        components?.queryItems = queryItems

        guard let url = components?.url else {
            throw NetworkError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        if httpResponse.statusCode == 429 {
            throw NetworkError.rateLimited
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }

        let decoded = try JSONDecoder().decode(ArticleResponse.self, from: data)
        let articles = decoded.results ?? []

        return articles.filter { article in
            !article.title.isEmpty && article.imageURL != nil
        }
    }
}
