import SwiftUI

struct ChatView: View {
    let topic: ChatTopic
    @StateObject private var viewModel: ChatViewModel

    init(topic: ChatTopic) {
        self.topic = topic
        _viewModel = StateObject(wrappedValue: ChatViewModel(topic: topic))
    }

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.started {
                conversation
                inputBar
            } else {
                intro
            }
        }
        .background(AppPalette.background.ignoresSafeArea())
        .navigationTitle(topic.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var intro: some View {
        VStack(spacing: 0) {
            Spacer()
            Image(systemName: topic.icon)
                .font(.system(size: 48))
                .foregroundColor(AppPalette.accentDark)
                .frame(width: 96, height: 96)
                .background(AppPalette.accentSoft)
                .clipShape(RoundedRectangle(cornerRadius: 28))
            Text(topic.title)
                .font(.system(size: 26, weight: .heavy))
                .foregroundColor(AppPalette.textPrimary)
                .padding(.top, 20)
            Text(topic.subtitle)
                .font(.system(size: 13))
                .foregroundColor(AppPalette.textSecondary)
                .padding(.top, 6)

            Button(action: { viewModel.beginWithStarter() }) {
                Text("Start with: \"\(topic.starter)\"")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .background(AppPalette.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.top, 24)

            Button(action: { viewModel.beginManually() }) {
                Text("Or ask my own question")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppPalette.accentDark)
                    .frame(maxWidth: .infinity)
                    .padding(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(AppPalette.accent, lineWidth: 1.5)
                    )
            }
            .padding(.top, 12)
            Spacer()
        }
        .padding(24)
    }

    private var conversation: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(viewModel.messages) { message in
                        Bubble(message: message)
                            .id(message.id)
                    }
                    if viewModel.sending {
                        thinkingRow
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
            .onChange(of: viewModel.messages.count) { _ in
                if let last = viewModel.messages.last {
                    withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                }
            }
        }
    }

    private var thinkingRow: some View {
        HStack {
            Image(systemName: "soccerball")
                .font(.system(size: 16))
                .foregroundColor(AppPalette.accentDark)
                .frame(width: 28, height: 28)
                .background(AppPalette.accentSoft)
                .clipShape(Circle())
            ProgressView()
                .tint(AppPalette.accent)
            Text("Coach is thinking...")
                .font(.system(size: 12))
                .foregroundColor(AppPalette.textSecondary)
            Spacer()
        }
    }

    private var inputBar: some View {
        HStack(spacing: 8) {
            TextField("Ask the coach...", text: $viewModel.input)
                .font(.system(size: 14))
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(AppPalette.background)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(AppPalette.accentSoft, lineWidth: 1)
                )
                .disabled(viewModel.sending)

            Button(action: { viewModel.submitInput() }) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .frame(width: 48, height: 48)
                    .background(canSend ? AppPalette.accent : AppPalette.accent.opacity(0.4))
                    .clipShape(Circle())
            }
            .disabled(!canSend)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(AppPalette.surface)
    }

    private var canSend: Bool {
        !viewModel.input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !viewModel.sending
    }
}

private struct Bubble: View {
    let message: ChatMessage

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if message.isUser {
                Spacer(minLength: 40)
                bubbleText
                avatar(icon: "person.fill", background: AppPalette.accent, tint: .white)
            } else {
                avatar(icon: "soccerball", background: AppPalette.accentSoft, tint: AppPalette.accentDark)
                bubbleText
                Spacer(minLength: 40)
            }
        }
    }

    private var bubbleText: some View {
        Text(message.text)
            .font(.system(size: 14))
            .foregroundColor(message.isUser ? .white : AppPalette.textPrimary)
            .lineSpacing(4)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(message.isUser ? AppPalette.accent : AppPalette.surface)
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func avatar(icon: String, background: Color, tint: Color) -> some View {
        Image(systemName: icon)
            .font(.system(size: 16))
            .foregroundColor(tint)
            .frame(width: 30, height: 30)
            .background(background)
            .clipShape(Circle())
    }
}
