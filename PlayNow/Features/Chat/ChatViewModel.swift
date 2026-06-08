import SwiftUI
import Combine

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}

@MainActor
final class ChatViewModel: ObservableObject {

    @Published var messages: [ChatMessage] = []
    @Published var input = ""
    @Published var sending = false
    @Published var started = false

    private let topic: ChatTopic
    private let service = AIService()

    init(topic: ChatTopic) {
        self.topic = topic
    }

    func beginWithStarter() {
        started = true
        send(topic.starter)
    }

    func beginManually() {
        started = true
    }

    func submitInput() {
        let text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        input = ""
        send(text)
    }

    func send(_ message: String) {
        guard !message.isEmpty, !sending else { return }
        messages.append(ChatMessage(text: message, isUser: true))
        sending = true

        let history = messages.dropLast().map { ChatTurn(role: $0.isUser ? "user" : "assistant", content: $0.text) }
        let prompt = topic.systemPrompt

        Task {
            let reply = await service.chat(systemPrompt: prompt, history: Array(history), userMessage: message)
            messages.append(ChatMessage(text: reply, isUser: false))
            sending = false
        }
    }
}
