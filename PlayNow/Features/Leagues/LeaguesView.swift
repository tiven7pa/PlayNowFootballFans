import SwiftUI

struct LeaguesView: View {
    @StateObject private var viewModel = LeaguesViewModel()
    @State private var loaded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Leagues")
                .font(.system(size: 30, weight: .heavy))
                .foregroundColor(AppPalette.textPrimary)

            leaguePicker
            tabSwitcher

            ScrollView {
                content
                    .padding(.bottom, 12)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(AppPalette.background.ignoresSafeArea())
        .onAppear {
            if !loaded {
                loaded = true
                viewModel.reload()
            }
        }
    }

    private var leaguePicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(FootballCatalog.popularLeagues) { league in
                    let selected = league.id == viewModel.selectedLeagueId
                    HStack(spacing: 6) {
                        Image(systemName: "soccerball")
                            .font(.system(size: 14))
                            .foregroundColor(selected ? .white : AppPalette.accentDark)
                        Text(league.name)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(selected ? .white : AppPalette.accentDark)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(selected ? AppPalette.accent : AppPalette.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .onTapGesture { viewModel.select(league.id) }
                }
            }
        }
    }

    private var tabSwitcher: some View {
        HStack(spacing: 4) {
            ForEach(LeagueTab.allCases, id: \.self) { tab in
                let selected = tab == viewModel.tab
                Text(tab.rawValue)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(selected ? .white : AppPalette.accentDark)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(selected ? AppPalette.accent : Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .onTapGesture { viewModel.choose(tab) }
            }
        }
        .padding(4)
        .background(AppPalette.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.loading {
            LoadingBlock()
        } else {
            switch viewModel.tab {
            case .fixtures:
                FixturesList(items: viewModel.fixtures)
            case .standings:
                StandingsTable(rows: viewModel.standings)
            case .scorers:
                ScorersTable(rows: viewModel.scorers)
            }
        }
    }
}

private struct FixturesList: View {
    let items: [FixtureItem]

    var body: some View {
        if items.isEmpty {
            EmptyStateCard(message: "No fixtures available")
        } else {
            VStack(spacing: 10) {
                ForEach(items) { fixture in
                    VStack(spacing: 8) {
                        HStack {
                            Text(FootballCatalog.formatDate(fixture.date))
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(AppPalette.textSecondary)
                            Spacer()
                            Text(fixture.statusShort.isEmpty ? "TBD" : fixture.statusShort)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(AppPalette.accentDark)
                        }
                        line(name: fixture.homeName, goals: fixture.homeGoals)
                        line(name: fixture.awayName, goals: fixture.awayGoals)
                    }
                    .padding(12)
                    .background(AppPalette.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
        }
    }

    private func line(name: String, goals: Int?) -> some View {
        HStack {
            TeamBadge(name: name, size: 26)
            Text(name)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(AppPalette.textPrimary)
                .lineLimit(1)
            Spacer()
            Text(goals.map { "\($0)" } ?? "-")
                .font(.system(size: 16, weight: .heavy))
                .foregroundColor(goals != nil ? AppPalette.accentDark : AppPalette.textMuted)
        }
    }
}

private struct StandingsTable: View {
    let rows: [StandingRow]

    var body: some View {
        if rows.isEmpty {
            EmptyStateCard(message: "Standings unavailable for this league")
        } else {
            VStack(spacing: 0) {
                HStack {
                    headerCell("#", width: 28, alignment: .leading)
                    Text("Team")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(AppPalette.textMuted)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    headerCell("P", width: 28, alignment: .trailing)
                    headerCell("GD", width: 36, alignment: .trailing)
                    headerCell("Pts", width: 36, alignment: .trailing)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                Rectangle()
                    .fill(AppPalette.divider)
                    .frame(height: 1)
                ForEach(rows) { row in
                    HStack {
                        Text("\(row.rank)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(rankColor(row.rank))
                            .frame(width: 22, height: 22)
                            .background(rankColor(row.rank).opacity(0.18))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        TeamBadge(name: row.teamName, size: 22)
                        Text(row.teamName)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AppPalette.textPrimary)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("\(row.played)")
                            .font(.system(size: 12))
                            .foregroundColor(AppPalette.textPrimary)
                            .frame(width: 28, alignment: .trailing)
                        Text("\(row.goalDifference)")
                            .font(.system(size: 12))
                            .foregroundColor(AppPalette.textPrimary)
                            .frame(width: 36, alignment: .trailing)
                        Text("\(row.points)")
                            .font(.system(size: 13, weight: .heavy))
                            .foregroundColor(AppPalette.accentDark)
                            .frame(width: 36, alignment: .trailing)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                }
            }
            .padding(.vertical, 8)
            .background(AppPalette.surface)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    private func headerCell(_ text: String, width: CGFloat, alignment: Alignment) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(AppPalette.textMuted)
            .frame(width: width, alignment: alignment)
    }

    private func rankColor(_ rank: Int) -> Color {
        switch rank {
        case ...4: return AppPalette.green
        case 5: return AppPalette.accent
        case 18...: return AppPalette.red
        default: return AppPalette.textMuted
        }
    }
}

private struct ScorersTable: View {
    let rows: [TopScorer]

    var body: some View {
        if rows.isEmpty {
            EmptyStateCard(message: "Top scorers unavailable")
        } else {
            VStack(spacing: 8) {
                ForEach(rows.prefix(20)) { scorer in
                    HStack {
                        Text("\(scorer.rank)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(AppPalette.accentDark)
                            .frame(width: 28, height: 28)
                            .background(AppPalette.accentSoft)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        VStack(alignment: .leading) {
                            Text(scorer.playerName)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppPalette.textPrimary)
                            Text(scorer.teamName)
                                .font(.system(size: 11))
                                .foregroundColor(AppPalette.textSecondary)
                        }
                        Spacer()
                        HStack(spacing: 4) {
                            Image(systemName: "soccerball")
                                .font(.system(size: 16))
                                .foregroundColor(AppPalette.accent)
                            Text("\(scorer.goals)")
                                .font(.system(size: 16, weight: .heavy))
                                .foregroundColor(AppPalette.accentDark)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(AppPalette.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
}
