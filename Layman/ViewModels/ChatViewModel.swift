import Foundation
import Combine
import SwiftUI
import UIKit

@MainActor
public class ChatViewModel: ObservableObject {
    @Published public var messages: [ChatMessage] = []
    @Published public var isTyping = false
    
    // Suggested Questions (auto-generated logic via random pick for prototype)
    public let suggestions = [
        "What does this mean for the industry?",
        "Who are the competitors?",
        "Explain this to me like a 10-year-old."
    ]
    
    let articleContext: Article
    
    public init(article: Article) {
        self.articleContext = article
        
        // Initial Message
        self.messages.append(ChatMessage(text: "Hi, I'm Layman! What can I answer for you?", isUser: false))
    }
    
    public func fetchResponse(for userPrompt: String) {
        let msg = ChatMessage(text: userPrompt, isUser: true)
        messages.append(msg)
        isTyping = true
        
        Task {
            do {
                let aiResponse = try await fetchGeminiResponse(query: userPrompt, context: articleContext)
                self.isTyping = false
                let botMsg = ChatMessage(text: aiResponse, isUser: false)
                self.messages.append(botMsg)
                // Haptic feedback when finishing typing
                #if os(iOS)
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                #endif
            } catch {
                self.isTyping = false
                let errorMsg = ChatMessage(text: "Oops, I had a bit of brain fog. (Error: \(error.localizedDescription))", isUser: false)
                self.messages.append(errorMsg)
            }
        }
    }
    
    private func fetchGeminiResponse(query: String, context: Article) async throws -> String {
        let systemPrompt = "You are Layman, a friendly expert who explains complex business and tech news to a 10-year-old. Use casual language, avoid jargon, and keep answers to 2 sentences max. Context article title: \(context.title), content snippet: \(context.chunkedContent.joined(separator: " "))."
        
        let endpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=\(Environment.geminiAPIKey)"
        guard let url = URL(string: endpoint) else {
            throw URLError(.badURL)
        }
        
        let reqBody: [String: Any] = [
            "contents": [
                [
                    "role": "user",
                    "parts": [
                        ["text": "\(systemPrompt)\n\nQuestion: \(query)"]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 0.5,
                "maxOutputTokens": 100 // keep it short as requested -> 2 sentences max
            ]
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: reqBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        // Quick dict parse for Gemini JSON schema
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let candidates = json["candidates"] as? [[String: Any]],
              let firstCandidate = candidates.first,
              let content = firstCandidate["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let firstPart = parts.first,
              let text = firstPart["text"] as? String else {
            throw URLError(.cannotParseResponse)
        }
        
        return text
    }
}
