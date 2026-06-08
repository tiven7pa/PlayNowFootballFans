import Foundation

struct FixtureItem: Identifiable, Hashable {
    let fixtureId: Int
    let date: String
    let timestamp: Double
    let statusShort: String
    let statusLong: String
    let elapsed: Int?
    let leagueId: Int
    let leagueName: String
    let homeId: Int
    let homeName: String
    let awayId: Int
    let awayName: String
    let homeGoals: Int?
    let awayGoals: Int?
    let venue: String?

    var id: Int { fixtureId }
}

struct StandingRow: Identifiable, Hashable {
    let rank: Int
    let teamId: Int
    let teamName: String
    let played: Int
    let win: Int
    let draw: Int
    let lose: Int
    let goalsFor: Int
    let goalsAgainst: Int
    let points: Int
    let form: String?

    var id: Int { teamId }
    var goalDifference: Int { goalsFor - goalsAgainst }
}

struct TopScorer: Identifiable, Hashable {
    let rank: Int
    let playerName: String
    let teamName: String
    let goals: Int
    let assists: Int

    var id: Int { rank }
}

struct LeagueInfo: Identifiable, Hashable {
    let id: Int
    let name: String
    let country: String
}

enum FootballCatalog {
    static let popularLeagues: [LeagueInfo] = [
        LeagueInfo(id: 39, name: "Premier League", country: "England"),
        LeagueInfo(id: 140, name: "La Liga", country: "Spain"),
        LeagueInfo(id: 135, name: "Serie A", country: "Italy"),
        LeagueInfo(id: 78, name: "Bundesliga", country: "Germany"),
        LeagueInfo(id: 61, name: "Ligue 1", country: "France"),
        LeagueInfo(id: 2, name: "UEFA Champions League", country: "World"),
        LeagueInfo(id: 3, name: "UEFA Europa League", country: "World"),
        LeagueInfo(id: 88, name: "Eredivisie", country: "Netherlands"),
        LeagueInfo(id: 94, name: "Primeira Liga", country: "Portugal"),
        LeagueInfo(id: 203, name: "Super Lig", country: "Turkey")
    ]

    static func currentSeason() -> Int {
        let calendar = Calendar.current
        let now = Date()
        let year = calendar.component(.year, from: now)
        let month = calendar.component(.month, from: now)
        return month >= 7 ? year : year - 1
    }

    static func todayDate() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: Date())
    }

    static func formatTime(_ iso: String) -> String {
        formatISO(iso, output: "HH:mm")
    }

    static func formatDate(_ iso: String) -> String {
        formatISO(iso, output: "MMM d, HH:mm")
    }

    private static func formatISO(_ iso: String, output: String) -> String {
        let parser = DateFormatter()
        parser.locale = Locale(identifier: "en_US_POSIX")
        parser.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXX"
        guard let date = parser.date(from: iso) else { return iso }
        let out = DateFormatter()
        out.locale = Locale(identifier: "en_US_POSIX")
        out.dateFormat = output
        out.timeZone = TimeZone.current
        return out.string(from: date)
    }
}
