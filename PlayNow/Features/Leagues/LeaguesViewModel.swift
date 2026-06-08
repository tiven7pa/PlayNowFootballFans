import SwiftUI
import Combine

enum LeagueTab: String, CaseIterable {
    case fixtures = "Fixtures"
    case standings = "Table"
    case scorers = "Scorers"
}

@MainActor
final class LeaguesViewModel: ObservableObject {

    @Published var selectedLeagueId: Int
    @Published var tab: LeagueTab = .fixtures
    @Published var fixtures: [FixtureItem] = []
    @Published var standings: [StandingRow] = []
    @Published var scorers: [TopScorer] = []
    @Published var loading = false

    private let service = FootballService()
    private let preferences = AppPreferences.shared
    private var loadToken = 0

    init() {
        selectedLeagueId = AppPreferences.shared.favoriteLeague
    }

    func select(_ leagueId: Int) {
        guard leagueId != selectedLeagueId else { return }
        selectedLeagueId = leagueId
        preferences.favoriteLeague = leagueId
        reload()
    }

    func choose(_ tab: LeagueTab) {
        guard tab != self.tab else { return }
        self.tab = tab
        reload()
    }

    func reload() {
        loadToken += 1
        let token = loadToken
        loading = true
        let leagueId = selectedLeagueId
        let season = FootballCatalog.currentSeason()
        let activeTab = tab

        Task {
            switch activeTab {
            case .fixtures:
                let upcoming = await service.upcomingByLeague(leagueId: leagueId, season: season, next: 12)
                let recent = await service.fixturesByLeague(leagueId: leagueId, season: season, last: 12)
                var seen = Set<Int>()
                let merged = ((upcoming.data ?? []) + (recent.data ?? []))
                    .filter { seen.insert($0.fixtureId).inserted }
                    .sorted { $0.timestamp < $1.timestamp }
                if token == loadToken {
                    fixtures = merged
                }
            case .standings:
                let result = await service.standings(leagueId: leagueId, season: season)
                if token == loadToken {
                    standings = result.data ?? []
                }
            case .scorers:
                let result = await service.topScorers(leagueId: leagueId, season: season)
                if token == loadToken {
                    scorers = result.data ?? []
                }
            }
            if token == loadToken {
                loading = false
            }
        }
    }
}
