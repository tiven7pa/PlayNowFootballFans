import SwiftUI

struct HomeView: View {
    let onOpenNotice: () -> Void

    @StateObject private var viewModel = HomeViewModel()
    @State private var tipIndex = 0
    private let displayName = AppPreferences.shared.displayName

    private let tips = [
        "Underdogs win when motivation outweighs class. Always check team news first.",
        "Avoid stacking many legs in one accumulator — variance multiplies fast.",
        "Home advantage is real, but smaller in empty stadiums and neutral venues.",
        "Goals expected (xG) is more predictive than recent goals scored.",
        "Set a fixed unit size for every prediction. Discipline beats inspiration.",
        "Teams chasing a title late in season often outperform their xG numbers.",
        "Cup matches are noisier than league fixtures. Treat them with caution."
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                heroBanner
                statsRow
                tipCard
                SectionHeader(title: "Live & Today")
                liveSection
                SectionHeader(title: "Top Leagues")
                leaguesRow
                noticeButton
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 18)
        }
        .background(AppPalette.background.ignoresSafeArea())
        .onAppear { viewModel.loadIfNeeded() }
    }

    private var heroBanner: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Hello, \(displayName)")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white.opacity(0.85))
            Text("PlayNow")
                .font(.system(size: 32, weight: .heavy))
                .foregroundColor(.white)
            Text("Football data, AI insights\nand a risk-free betting simulator")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.92))
                .lineSpacing(4)
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
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }

    private var statsRow: some View {
        HStack(spacing: 12) {
            StatBox(icon: "calendar", label: "Today", value: "\(viewModel.todayCount)")
            StatBox(icon: "soccerball", label: "Live now", value: "\(viewModel.liveCount)")
            StatBox(icon: "sportscourt", label: "Leagues", value: "\(FootballCatalog.popularLeagues.count)")
        }
    }

    private var tipCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Pill(text: "Daily tip")
                Spacer()
                Text("Next")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppPalette.accent)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .onTapGesture { tipIndex = (tipIndex + 1) % tips.count }
            }
            Text(tips[tipIndex])
                .font(.system(size: 14))
                .foregroundColor(AppPalette.textPrimary)
                .lineSpacing(4)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppPalette.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    @ViewBuilder
    private var liveSection: some View {
        if viewModel.loading {
            LoadingBlock(message: "Fetching today's fixtures...")
        } else if viewModel.live.isEmpty {
            EmptyStateCard(message: "No fixtures right now. Check back soon.")
        } else {
            VStack(spacing: 10) {
                ForEach(viewModel.live.prefix(6)) { item in
                    LiveFixtureCard(item: item)
                }
            }
        }
    }

    private var leaguesRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(FootballCatalog.popularLeagues) { league in
                    LeagueChip(name: league.name, country: league.country)
                }
            }
        }
    }

    private var noticeButton: some View {
        HStack {
            Image(systemName: "checkmark.shield")
                .font(.system(size: 22))
                .foregroundColor(AppPalette.accentDark)
                .frame(width: 44, height: 44)
                .background(AppPalette.accentSoft)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            VStack(alignment: .leading, spacing: 2) {
                Text("Privacy Policy")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppPalette.textPrimary)
                Text("Read how we handle your data")
                    .font(.system(size: 12))
                    .foregroundColor(AppPalette.textSecondary)
            }
            Spacer()
            Text("Open")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(AppPalette.accent)
        }
        .padding(16)
        .background(AppPalette.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .onTapGesture { onOpenNotice() }
    }
}

private struct StatBox: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(AppPalette.accentDark)
                .frame(width: 32, height: 32)
                .background(AppPalette.accentSoft)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            Text(value)
                .font(.system(size: 22, weight: .heavy))
                .foregroundColor(AppPalette.accentDark)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(AppPalette.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(AppPalette.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

private struct LiveFixtureCard: View {
    let item: FixtureItem

    private var statusColor: Color {
        switch item.statusShort {
        case "1H", "2H", "ET", "P", "LIVE": return AppPalette.red
        case "HT": return AppPalette.accent
        case "FT", "AET", "PEN": return AppPalette.green
        default: return AppPalette.textMuted
        }
    }

    private var statusText: String {
        if let elapsed = item.elapsed, ["1H", "2H", "ET"].contains(item.statusShort) {
            return "\(elapsed)'  \(item.statusShort)"
        }
        return item.statusShort.isEmpty ? "TBD" : item.statusShort
    }

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text(item.leagueName)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(AppPalette.textSecondary)
                Spacer()
                Pill(text: statusText, color: .white, background: statusColor)
            }
            teamLine(name: item.homeName, score: item.homeGoals, isHome: true)
            teamLine(name: item.awayName, score: item.awayGoals, isHome: false)
        }
        .padding(14)
        .background(AppPalette.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func teamLine(name: String, score: Int?, isHome: Bool) -> some View {
        HStack {
            TeamBadge(name: name, size: 32)
            Text(name)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppPalette.textPrimary)
                .lineLimit(1)
            Spacer()
            if let score {
                Text("\(score)")
                    .font(.system(size: 18, weight: .heavy))
                    .foregroundColor(AppPalette.accentDark)
            } else if isHome {
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 12))
                        .foregroundColor(AppPalette.textMuted)
                    Text(FootballCatalog.formatTime(item.date))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppPalette.textSecondary)
                }
            }
        }
    }
}

private struct LeagueChip: View {
    let name: String
    let country: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: "sportscourt")
                .font(.system(size: 22))
                .foregroundColor(AppPalette.accentDark)
                .frame(width: 40, height: 40)
                .background(AppPalette.accentSoft)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            Text(name)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(AppPalette.textPrimary)
                .lineLimit(1)
            Text(country)
                .font(.system(size: 10))
                .foregroundColor(AppPalette.textMuted)
        }
        .frame(width: 110)
        .padding(12)
        .background(AppPalette.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
