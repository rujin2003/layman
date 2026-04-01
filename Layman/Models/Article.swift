import Foundation

public struct ArticleResponse: Codable {
    public let status: String
    public let totalResults: Int
    public let results: [Article]
}

public struct Article: Identifiable, Codable, Hashable {
    public let id: String
    public let title: String
    public let link: String
    public let description: String?
    public let content: String?
    public let pubDate: String?
    public let imageURL: String?
    public let sourceID: String?
    
    // We compute an array of sentences for the detail view swipe cards
    // 6 lines rule: We will break content into 28-35 word chunks.
    public var chunkedContent: [String] {
        let text = content ?? description ?? "No content available."
        // A simple splitting logic for the UI prototype.
        let words = text.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        var chunks: [String] = []
        let chunkSize = 30 // aiming for the ~30 words (28-35 range)
        
        for i in stride(from: 0, to: words.count, by: chunkSize) {
            let end = min(i + chunkSize, words.count)
            let chunk = words[i..<end].joined(separator: " ")
            chunks.append(chunk)
            // Limit to 3 cards as per the mockup spec
            if chunks.count == 3 { break }
        }
        
        // Pad to exactly 3 chunks if we have less
        while chunks.count < 3 {
            chunks.append("Continue exploring to learn more about this startup and its impact on the industry.")
        }
        
        return chunks
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "article_id"
        case title
        case link
        case description
        case content
        case pubDate
        case imageURL = "image_url"
        case sourceID = "source_id"
    }
}

// Sample Data for Previews
public extension Article {
    static let mock = Article(
        id: "mock1",
        title: "This AI startup just raised $40M to build faster chips for ChatGPT",
        link: "https://example.com",
        description: "A new standard for AI acceleration.",
        content: "The hardware startup announced a massive series B round today leading to widespread excitement in the ML community. They aim to reduce latency by half and energy consumption by a third, addressing severe bottlenecks in generative AI data centers. Many experts believe this could finally break the GPU compute shortage limits we've seen all year. With leading VCs on board, the race for next-generation silicon is heating up. We anticipate their first chips available next fall.",
        pubDate: "2024-05-01 12:00:00",
        imageURL: nil,
        sourceID: "techcrunch"
    )
    
    static let mocks = [mock, mock, mock]
}
