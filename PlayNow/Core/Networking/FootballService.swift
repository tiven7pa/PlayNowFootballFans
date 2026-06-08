import Foundation

struct ServiceResult<T> {
    var data: T?
    var error: String?
    var isSuccess: Bool { data != nil && error == nil }
}

final class FootballService {

    private static let baseAddress = "https://v3.football.api-sports.io"
    private static let apiKey = "e6f0ed29a80992c8178326ee775fd6be"

    private let session: URLSession = {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        configuration.urlCache = nil
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 30
        return URLSession(configuration: configuration)
    }()

    private func makeRequest(path: String) -> URLRequest? {
        guard let resource = URL(string: FootballService.baseAddress + path) else { return nil }
        var request = URLRequest(url: resource)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.setValue("v3.football.api-sports.io", forHTTPHeaderField: "x-rapidapi-host")
        request.setValue(FootballService.apiKey, forHTTPHeaderField: "x-apisports-key")
        request.setValue("no-cache, no-store, must-revalidate", forHTTPHeaderField: "Cache-Control")
        return request
    }

    private func call(_ path: String) async -> [String: Any]? {
        guard let request = makeRequest(path: path) else { return nil }
        do {
            let (data, _) = try await session.data(for: request)
            return try JSONSerialization.jsonObject(with: data) as? [String: Any]
        } catch {
            return nil
        }
    }

    nonisolated func fixturesByDate(_ date: String) async -> ServiceResult<[FixtureItem]> {
        guard let json = await call("/fixtures?date=\(date)") else {
            return ServiceResult(error: "Network error")
        }
        let response = json["response"] as? [[String: Any]] ?? []
        return ServiceResult(data: parseFixtures(response))
    }

    nonisolated func fixturesByLeague(leagueId: Int, season: Int, last: Int = 30) async -> ServiceResult<[FixtureItem]> {
        guard let json = await call("/fixtures?league=\(leagueId)&season=\(season)&last=\(last)") else {
            return ServiceResult(error: "Network error")
        }
        let response = json["response"] as? [[String: Any]] ?? []
        return ServiceResult(data: parseFixtures(response))
    }

    nonisolated func upcomingByLeague(leagueId: Int, season: Int, next: Int = 20) async -> ServiceResult<[FixtureItem]> {
        guard let json = await call("/fixtures?league=\(leagueId)&season=\(season)&next=\(next)") else {
            return ServiceResult(error: "Network error")
        }
        let response = json["response"] as? [[String: Any]] ?? []
        return ServiceResult(data: parseFixtures(response))
    }

    nonisolated func standings(leagueId: Int, season: Int) async -> ServiceResult<[StandingRow]> {
        guard let json = await call("/standings?league=\(leagueId)&season=\(season)") else {
            return ServiceResult(error: "Network error")
        }
        guard let response = json["response"] as? [[String: Any]], let first = response.first,
              let league = first["league"] as? [String: Any],
              let groups = league["standings"] as? [[[String: Any]]],
              let group = groups.first else {
            return ServiceResult(data: [])
        }
        var rows: [StandingRow] = []
        for entry in group {
            guard let team = entry["team"] as? [String: Any],
                  let all = entry["all"] as? [String: Any],
                  let goals = all["goals"] as? [String: Any] else { continue }
            let form = (entry["form"] as? String).flatMap { $0.isEmpty ? nil : $0 }
            rows.append(
                StandingRow(
                    rank: entry["rank"] as? Int ?? 0,
                    teamId: team["id"] as? Int ?? 0,
                    teamName: team["name"] as? String ?? "",
                    played: all["played"] as? Int ?? 0,
                    win: all["win"] as? Int ?? 0,
                    draw: all["draw"] as? Int ?? 0,
                    lose: all["lose"] as? Int ?? 0,
                    goalsFor: goals["for"] as? Int ?? 0,
                    goalsAgainst: goals["against"] as? Int ?? 0,
                    points: entry["points"] as? Int ?? 0,
                    form: form
                )
            )
        }
        return ServiceResult(data: rows)
    }

    nonisolated func topScorers(leagueId: Int, season: Int) async -> ServiceResult<[TopScorer]> {
        guard let json = await call("/players/topscorers?league=\(leagueId)&season=\(season)") else {
            return ServiceResult(error: "Network error")
        }
        let response = json["response"] as? [[String: Any]] ?? []
        var rows: [TopScorer] = []
        for (index, entry) in response.enumerated() {
            guard let player = entry["player"] as? [String: Any],
                  let statistics = entry["statistics"] as? [[String: Any]],
                  let first = statistics.first,
                  let team = first["team"] as? [String: Any],
                  let goals = first["goals"] as? [String: Any] else { continue }
            rows.append(
                TopScorer(
                    rank: index + 1,
                    playerName: player["name"] as? String ?? "",
                    teamName: team["name"] as? String ?? "",
                    goals: goals["total"] as? Int ?? 0,
                    assists: goals["assists"] as? Int ?? 0
                )
            )
        }
        return ServiceResult(data: rows)
    }

    private func parseFixtures(_ array: [[String: Any]]) -> [FixtureItem] {
        var items: [FixtureItem] = []
        for entry in array {
            guard let fixture = entry["fixture"] as? [String: Any],
                  let league = entry["league"] as? [String: Any],
                  let teams = entry["teams"] as? [String: Any],
                  let home = teams["home"] as? [String: Any],
                  let away = teams["away"] as? [String: Any],
                  let status = fixture["status"] as? [String: Any] else { continue }
            let goals = entry["goals"] as? [String: Any]
            let venue = fixture["venue"] as? [String: Any]
            items.append(
                FixtureItem(
                    fixtureId: fixture["id"] as? Int ?? 0,
                    date: fixture["date"] as? String ?? "",
                    timestamp: (fixture["timestamp"] as? NSNumber)?.doubleValue ?? 0,
                    statusShort: status["short"] as? String ?? "",
                    statusLong: status["long"] as? String ?? "",
                    elapsed: status["elapsed"] as? Int,
                    leagueId: league["id"] as? Int ?? 0,
                    leagueName: league["name"] as? String ?? "",
                    homeId: home["id"] as? Int ?? 0,
                    homeName: home["name"] as? String ?? "",
                    awayId: away["id"] as? Int ?? 0,
                    awayName: away["name"] as? String ?? "",
                    homeGoals: goals?["home"] as? Int,
                    awayGoals: goals?["away"] as? Int,
                    venue: venue?["name"] as? String
                )
            )
        }
        return items
    }
}
