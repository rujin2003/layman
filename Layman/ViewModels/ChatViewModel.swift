import Foundation
import Combine
import UIKit

@MainActor
public final class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isTyping = false
    @Published var suggestions: [String] = []

    let articleContext: Article

    public init(article: Article) {
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
                let aiResponse = try await answerWithContext(userPrompt: userPrompt)
                self.isTyping = false
                self.messages.append(ChatMessage(text: aiResponse, isUser: false))
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            } catch {
                self.isTyping = false
                let detail = error.localizedDescription
                self.messages.append(
                    ChatMessage(
                        text: "Hmm, I hit a snag: \(detail)",
                        isUser: false
                    )
                )
            }
        }
    }

    private func generateSuggestions() {
        Task {
            let prompt = """
            You are helping readers of a news app. Given this article, write exactly 3 short questions \
            (under 10 words each) a curious reader might tap to ask. Output only 3 lines, no numbers or bullets.

            Title: \(articleContext.title)
            Summary: \(articleContext.displayContent.prefix(400))
            """

            do {
                let response = try await GeminiClient.generateText(prompt: prompt)
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

    private func answerWithContext(userPrompt: String) async throws -> String {
        let contextBlock = """
        Article title: \(articleContext.title)
        Article link: \(articleContext.link)
        Body (for context only): \(articleContext.displayContent.prefix(3500))
        """

        let prompt = """
        You are Layman — you explain business, tech, and startup news in plain, friendly English like talking to a friend.
        Rules: 1–2 sentences only. No jargon. If the question is not about this article, say so briefly and still be kind.

        \(contextBlock)

        User question: \(userPrompt)
        """

        return try await GeminiClient.generateText(prompt: prompt)
    }
}
