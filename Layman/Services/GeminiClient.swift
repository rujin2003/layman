import Foundation

/// Calls Google AI Gemini REST API with fallbacks and clear errors (for Ask Layman).
enum GeminiClient {
    private static let modelsToTry = [
        "gemini-2.0-flash",
        "gemini-2.0-flash-001",
        "gemini-1.5-flash",
        "gemini-1.5-flash-latest",
        "gemini-1.5-flash-8b"
    ]

    enum GeminiError: LocalizedError {
        case http(Int, String)
        case noTextInResponse(String)
        case allModelsFailed(String)

        var errorDescription: String? {
            switch self {
            case .http(let code, let msg): return "API error (\(code)): \(msg)"
            case .noTextInResponse(let msg): return msg
            case .allModelsFailed(let msg): return msg
            }
        }
    }

    static func generateText(prompt: String) async throws -> String {
        var lastDetail = ""

        for model in modelsToTry {
            do {
                return try await request(model: model, prompt: prompt)
            } catch let err as GeminiError {
                lastDetail = err.localizedDescription
                continue
            } catch {
                lastDetail = error.localizedDescription
                continue
            }
        }

        throw GeminiError.allModelsFailed(lastDetail.isEmpty ? "Could not reach Gemini." : lastDetail)
    }

    private static func request(model: String, prompt: String) async throws -> String {
        var components = URLComponents(string: "https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent")!
        components.queryItems = [URLQueryItem(name: "key", value: AppSecrets.geminiAPIKey)]
        guard let url = components.url else { throw URLError(.badURL) }

        let body: [String: Any] = [
            "contents": [
                ["parts": [["text": prompt]]]
            ],
            "generationConfig": [
                "temperature": 0.65,
                "maxOutputTokens": 256
            ]
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw URLError(.badServerResponse) }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw GeminiError.http(http.statusCode, "Invalid JSON")
        }

        if http.statusCode != 200 {
            let msg = parseErrorMessage(json) ?? String(data: data, encoding: .utf8) ?? "Unknown error"
            throw GeminiError.http(http.statusCode, msg)
        }

        if let feedback = json["promptFeedback"] as? [String: Any],
           let block = feedback["blockReason"] as? String {
            throw GeminiError.noTextInResponse("Blocked: \(block). Try rephrasing.")
        }

        guard let candidates = json["candidates"] as? [[String: Any]], let first = candidates.first else {
            throw GeminiError.noTextInResponse("No response from model. Enable billing or check API key in Google AI Studio.")
        }

        if let finish = first["finishReason"] as? String, finish != "STOP", finish != "MAX_TOKENS" {
            throw GeminiError.noTextInResponse("Stopped: \(finish)")
        }

        guard let content = first["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let text = parts.first?["text"] as? String,
              !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw GeminiError.noTextInResponse("Empty reply. Check Generative Language API is enabled for this key.")
        }

        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func parseErrorMessage(_ json: [String: Any]) -> String? {
        if let err = json["error"] as? [String: Any] {
            return err["message"] as? String ?? err["status"] as? String
        }
        return nil
    }
}
