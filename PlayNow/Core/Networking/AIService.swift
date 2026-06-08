import Foundation

struct ChatTurn {
    let role: String
    let content: String
}

final class AIService {

    private static let endpoint = "https://api.apifree.ai/v1/chat/completions"
    private static let apiKey = "sk-pP3C7H4ZDd9p0rhECrPbTrsPmK9BH"

    private let session: URLSession = {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        configuration.urlCache = nil
        configuration.timeoutIntervalForRequest = 60
        configuration.timeoutIntervalForResource = 60
        return URLSession(configuration: configuration)
    }()

    nonisolated func chat(systemPrompt: String, history: [ChatTurn], userMessage: String) async -> String {
        guard let resource = URL(string: AIService.endpoint) else {
            return "Error: invalid endpoint"
        }

        var messages: [[String: Any]] = []
        messages.append(["role": "system", "content": systemPrompt])
        for turn in history {
            messages.append(["role": turn.role, "content": turn.content])
        }
        messages.append(["role": "user", "content": userMessage])

        let payload: [String: Any] = [
            "model": "gemini-2.5-pro",
            "messages": messages,
            "temperature": 0.7
        ]

        guard let body = try? JSONSerialization.data(withJSONObject: payload) else {
            return "Error: bad request"
        }

        var request = URLRequest(url: resource)
        request.httpMethod = "POST"
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(AIService.apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("no-cache, no-store, must-revalidate", forHTTPHeaderField: "Cache-Control")
        request.httpBody = body

        do {
            let (data, response) = try await session.data(for: request)
            if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
                return "Service unavailable (\(http.statusCode)). Try again."
            }
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                return "Empty response"
            }
            guard let choices = json["choices"] as? [[String: Any]], let first = choices.first,
                  let message = first["message"] as? [String: Any],
                  let content = message["content"] as? String else {
                return "No reply"
            }
            return content.isEmpty ? "No reply" : content
        } catch {
            return "Error: \(error.localizedDescription)"
        }
    }
}
