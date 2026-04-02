import Foundation

public struct ArticleResponse: Codable {
    public let status: String
    public let totalResults: Int?
    public let results: [Article]?
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
    public let sourceName: String?
    public let sourceIcon: String?
    public let category: [String]?

    public var displayTitle: String {
        let cleaned = title.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.count > 52 {
            let index = cleaned.index(cleaned.startIndex, offsetBy: 49)
            return String(cleaned[..<index]) + "..."
        }
        return cleaned
    }

    public var displayContent: String {
        let raw = content ?? description ?? ""
        let cleaned = raw
            .replacingOccurrences(of: "ONLY AVAILABLE IN PAID PLANS", with: "")
            .replacingOccurrences(of: "[Removed]", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return cleaned.isEmpty ? (description ?? "No content available.") : cleaned
    }

    public var chunkedContent: [String] {
        let text = displayContent
        let words = text.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        var chunks: [String] = []
        let chunkSize = 30

        for i in stride(from: 0, to: words.count, by: chunkSize) {
            let end = min(i + chunkSize, words.count)
            let chunk = words[i..<end].joined(separator: " ")
            chunks.append(chunk)
            if chunks.count == 3 { break }
        }

        while chunks.count < 3 {
            let fillers = [
                "This story highlights how rapidly the business and tech landscape is shifting. Keep exploring to understand the full picture.",
                "Industry experts suggest this could reshape how startups approach growth and innovation in the coming years.",
                "Stay tuned as this story develops. The implications could be far-reaching for both investors and everyday consumers."
            ]
            chunks.append(fillers[chunks.count - 1 < fillers.count ? chunks.count - 1 : 0])
        }

        return chunks
    }

    public var formattedDate: String {
        guard let pubDate = pubDate else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = formatter.date(from: pubDate) {
            let relative = RelativeDateTimeFormatter()
            relative.unitsStyle = .abbreviated
            return relative.localizedString(for: date, relativeTo: Date())
        }
        return pubDate
    }

    enum CodingKeys: String, CodingKey {
        case id = "article_id"
        case title, link, description, content, pubDate, category
        case imageURL = "image_url"
        case sourceID = "source_id"
        case sourceName = "source_name"
        case sourceIcon = "source_icon"
    }
}

public extension Article {
    func toSavedRecord(userId: String) -> SavedArticleRecord {
        SavedArticleRecord(
            userId: userId,
            articleId: id,
            title: title,
            link: link,
            description: description,
            content: content,
            imageUrl: imageURL,
            sourceId: sourceID,
            pubDate: pubDate
        )
    }

    init(from record: SavedArticleRecord) {
        self.init(
            id: record.articleId,
            title: record.title,
            link: record.link,
            description: record.description,
            content: record.content,
            pubDate: record.pubDate,
            imageURL: record.imageUrl,
            sourceID: record.sourceId,
            sourceName: nil,
            sourceIcon: nil,
            category: nil
        )
    }
}

public struct SavedArticleRecord: Codable {
    var id: String?
    let userId: String
    let articleId: String
    let title: String
    let link: String
    let description: String?
    let content: String?
    let imageUrl: String?
    let sourceId: String?
    let pubDate: String?
    var savedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case articleId = "article_id"
        case title, link, description, content
        case imageUrl = "image_url"
        case sourceId = "source_id"
        case pubDate = "pub_date"
        case savedAt = "saved_at"
    }
}

public extension Article {
    static let mock = Article(
        id: "mock1",
        title: "This AI startup just raised $40M to build faster chips",
        link: "https://example.com",
        description: "A groundbreaking new startup is changing the game in AI hardware.",
        content: "The hardware startup announced a massive series B round today leading to widespread excitement in the ML community. They aim to reduce latency by half and energy consumption by a third, addressing severe bottlenecks in generative AI data centers. Many experts believe this could finally break the GPU compute shortage limits we've seen all year. With leading VCs on board, the race for next-generation silicon is heating up fast. Their first commercial chips are expected to ship by next fall with major cloud providers already signing letters of intent.",
        pubDate: "2026-04-01 12:00:00",
        imageURL: nil,
        sourceID: "techcrunch",
        sourceName: "TechCrunch",
        sourceIcon: nil,
        category: ["technology"]
    )

    static let mock2 = Article(
        id: "mock2",
        title: "Why every founder is talking about this new funding model",
        link: "https://example.com/2",
        description: "Revenue-based financing is shaking up how startups raise money.",
        content: "Traditional venture capital might have some serious competition. A new wave of revenue-based financing is giving founders more control over their companies while still providing the capital they need to grow. Unlike equity rounds, these deals let startups keep full ownership. The model works especially well for SaaS companies with predictable recurring revenue. Early adopters report faster closing times and less stress during fundraising.",
        pubDate: "2026-04-01 10:00:00",
        imageURL: nil,
        sourceID: "bloomberg",
        sourceName: "Bloomberg",
        sourceIcon: nil,
        category: ["business"]
    )

    static let mocks = [mock, mock2, mock, mock2, mock]
}
