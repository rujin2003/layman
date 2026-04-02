import Foundation
import Combine
import UIKit

public class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isTyping = false
    @Published var suggestions: [String] = []

    let articleContext: Article

    init(article: Article) {
        self.articleContext = article
        self.messages.append(
            ChatMessage(text: "Hi, I'm Layman! What can I answer for you?", isUser: false)
        )
        generateSuggestions()
    }

    func fetchResponse(for userPrompt: String) {
        let msg = ChatMessage(text: userPrompt, isUser: true)
        messages.append(msg)
        isTyping = true
        suggestions = []

        Task {
            do {
                let aiResponse = try await callGemini(query: userPrompt)
                self.isTyping = false
                self.messages.append(ChatMessage(text: aiResponse, isUser: false))
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            } catch {
                self.isTyping = false
                self.messages.append(
                    ChatMessage(
                        text: "Sorry, I couldn't process that right now. Try again in a moment!",
                        isUser: false
                    )
                )
            }
        }
    }

    private func generateSuggestions() {
        Task {
            do {
                let prompt = """
                Based on this news article, generate exactly 3 short curiosity-driven questions a reader might ask. \
                Each question should be under 10 words. Return ONLY the 3 questions, one per line, no numbering.
                
                Article: \(articleContext.title)
                Content: \(articleContext.displayContent.prefix(300))
                """

                let response = try await callGeminiRaw(prompt: prompt)
                let lines = response.components(separatedBy: .newlines)
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty }
                    .prefix(3)

                self.suggestions = Array(lines)
            } catch {
                self.suggestions = [
                    "What does this mean for me?",
                    "Who are the main players here?",
                    "Why should I care about this?"
                ]
            }
        }
    }

    private func callGemini(query: String) async throws -> String {
        let systemPrompt = """
        You are Layman, a friendly expert who explains complex business and tech news \
        in simple everyday language. Keep answers to 1-2 sentences max. Be conversational \
        and casual. No jargon. Context article: "\(articleContext.title)" — \
        \(articleContext.displayContent.prefix(500))
        """

        let fullPrompt = "\(systemPrompt)\n\nUser question: \(query)"
        return try await callGeminiRaw(prompt: fullPrompt)
    }

    private func callGeminiRaw(prompt: String) async throws -> String {
        let endpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=\(AppSecrets.geminiAPIKey)"
        guard let url = URL(string: endpoint) else { throw URLError(.badURL) }

        let reqBody: [String: Any] = [
            "contents": [
                ["role": "user", "parts": [["text": prompt]]]
            ],
            "generationConfig": [
                "temperature": 0.7,
                "maxOutputTokens": 150
            ]
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: reqBody)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let candidates = json["candidates"] as? [[String: Any]],
              let firstCandidate = candidates.first,
              let content = firstCandidate["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let firstPart = parts.first,
              let text = firstPart["text"] as? String else {
            throw URLError(.cannotParseResponse)
        }

        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
