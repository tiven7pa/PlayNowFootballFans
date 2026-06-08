import SwiftUI

struct ChatListView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    header
                    SectionHeader(title: "Topics")
                    ForEach(ChatCatalog.topics) { topic in
                        NavigationLink(value: topic) {
                            topicRow(topic)
                        }
                        .buttonStyle(.plain)
                    }
                    disclaimer
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 18)
            }
            .background(AppPalette.background.ignoresSafeArea())
            .navigationDestination(for: ChatTopic.self) { topic in
                ChatView(topic: topic)
            }
        }
        .tint(AppPalette.accentDark)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("AI Football Coaches")
                .font(.system(size: 22, weight: .heavy))
                .foregroundColor(.white)
            Text("Pick a topic and chat with a specialised football AI")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.92))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            LinearGradient(
                colors: [AppPalette.accent, AppPalette.blue],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func topicRow(_ topic: ChatTopic) -> some View {
        HStack {
            Image(systemName: topic.icon)
                .font(.system(size: 24))
                .foregroundColor(AppPalette.accentDark)
                .frame(width: 46, height: 46)
                .background(AppPalette.accentSoft)
                .clipShape(RoundedRectangle(cornerRadius: 13))
            VStack(alignment: .leading) {
                Text(topic.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppPalette.textPrimary)
                Text(topic.subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(AppPalette.textSecondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppPalette.accent)
        }
        .padding(14)
        .background(AppPalette.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var disclaimer: some View {
        Text("AI replies are educational. They are not financial or betting advice. Always verify facts before acting.")
            .font(.system(size: 12))
            .foregroundColor(AppPalette.accentDark)
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppPalette.accentSoft)
            .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
