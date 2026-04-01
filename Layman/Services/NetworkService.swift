import Foundation

public enum NetworkError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingFailed(Error)
}

public protocol NetworkServiceType {
    func fetchArticles() async throws -> [Article]
}

public class NetworkService: NetworkServiceType {
    public static let shared = NetworkService()
    
    private let baseURL = "https://newsdata.io/api/1/news"
    private var apiKey: String { Environment.newsDataAPIKey }
    
    private init() {}
    
    public func fetchArticles() async throws -> [Article] {
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "apikey", value: apiKey),
            URLQueryItem(name: "category", value: "business,technology,startup"),
            URLQueryItem(name: "language", value: "en"),
            URLQueryItem(name: "image", value: "1") // only articles with images
        ]
        
        guard let url = components?.url else {
            throw NetworkError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.invalidResponse
            }
            
            let decodedResponse = try JSONDecoder().decode(ArticleResponse.self, from: data)
            return decodedResponse.results
            
        } catch let DecodingError.dataCorrupted(context) {
            print("Data corrupted: \(context)")
            throw NetworkError.decodingFailed(DecodingError.dataCorrupted(context))
        } catch let DecodingError.keyNotFound(key, context) {
            print("Key '\(key)' not found: \(context.debugDescription)")
            throw NetworkError.decodingFailed(DecodingError.keyNotFound(key, context))
        } catch {
            print("Decoding error: \(error)")
            throw NetworkError.requestFailed(error)
        }
    }
}
