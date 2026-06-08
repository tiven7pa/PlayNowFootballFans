import SwiftUI

struct SectionHeader: View {
    let title: String
    var action: String? = nil
    var onAction: (() -> Void)? = nil

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppPalette.accentDark)
            Spacer()
            if let action, let onAction {
                Text(action)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppPalette.accent)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(AppPalette.accentSoft)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .onTapGesture { onAction() }
            }
        }
    }
}

struct TeamBadge: View {
    let name: String
    var size: CGFloat = 36

    private static let palette: [Color] = [
        Color(hex: 0xE2580B), Color(hex: 0x2A5FB1), Color(hex: 0x2E8B57),
        Color(hex: 0xB54708), Color(hex: 0x7A3FE4), Color(hex: 0xC1392B),
        Color(hex: 0xE0A23A), Color(hex: 0x1E7F8E)
    ]

    private var initials: String {
        let parts = name
            .components(separatedBy: CharacterSet(charactersIn: " -./"))
            .filter { !$0.isEmpty }
            .prefix(2)
            .compactMap { $0.first.map { String($0).uppercased() } }
        let joined = parts.joined()
        return joined.isEmpty ? "?" : joined
    }

    private var color: Color {
        let index = abs(name.hashValue) % TeamBadge.palette.count
        return TeamBadge.palette[index]
    }

    var body: some View {
        Text(initials)
            .font(.system(size: size * 0.38, weight: .bold))
            .foregroundColor(color)
            .frame(width: size, height: size)
            .background(color.opacity(0.15))
            .clipShape(Circle())
    }
}

struct LoadingBlock: View {
    var message: String = "Loading..."

    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
                .tint(AppPalette.accent)
            Text(message)
                .font(.system(size: 13))
                .foregroundColor(AppPalette.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(32)
    }
}

struct Pill: View {
    let text: String
    var color: Color = AppPalette.accentDark
    var background: Color = AppPalette.accentSoft

    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct EmptyStateCard: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.system(size: 13))
            .foregroundColor(AppPalette.textSecondary)
            .frame(maxWidth: .infinity)
            .padding(20)
            .background(AppPalette.surface)
            .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
