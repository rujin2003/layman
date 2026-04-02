import Foundation

public struct ChatMessage: Identifiable, Hashable {
    public let id = UUID()
    public let text: String
    public let isUser: Bool
    public let timestamp = Date()

    public init(text: String, isUser: Bool) {
        self.text = text
        self.isUser = isUser
    }
}
