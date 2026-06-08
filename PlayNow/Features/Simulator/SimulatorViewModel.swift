import SwiftUI
import Combine

struct SimMatch: Identifiable {
    let id = UUID()
    let home: String
    let away: String
    let homeStrength: Int
    let awayStrength: Int

    func oddsHome() -> Double { Self.oddsFromStrength(my: homeStrength + 6, opp: awayStrength) }
    func oddsDraw() -> Double { 3.2 + Double(abs(homeStrength - awayStrength)) / 12.0 }
    func oddsAway() -> Double { Self.oddsFromStrength(my: awayStrength, opp: homeStrength + 6) }

    private static func oddsFromStrength(my: Int, opp: Int) -> Double {
        let ratio = (Double(opp) + 8) / (Double(my) + 8)
        return ((1.05 + ratio * 1.6) * 100).rounded() / 100
    }
}

struct SimHistoryItem: Identifiable {
    let id = UUID()
    let description: String
    let stake: Int
    let payoff: Int
    let won: Bool
}

enum SimPick: String, CaseIterable {
    case home = "Home"
    case draw = "Draw"
    case away = "Away"
}

@MainActor
final class SimulatorViewModel: ObservableObject {

    @Published var matches: [SimMatch] = []
    @Published var selectedIndex = 0
    @Published var pick: SimPick = .home
    @Published var stakeText = "100"
    @Published var history: [SimHistoryItem] = []
    @Published var lastResult: SimHistoryItem?
    @Published var rolling = false
    @Published var balance: Int

    private let preferences = AppPreferences.shared

    private static let sampleTeams: [(String, Int)] = [
        ("Northbridge FC", 78), ("Royal Crown", 74), ("Ironworks", 70), ("Orange Bay", 66),
        ("Westside United", 62), ("Pinewood", 58), ("Granite SC", 55), ("Lakeside", 52),
        ("Riverstone", 49), ("Highgate", 46), ("Crescent", 44), ("Old Mill", 41)
    ]

    init() {
        balance = AppPreferences.shared.balance
        matches = Self.generateMatches()
    }

    var match: SimMatch {
        matches.indices.contains(selectedIndex) ? matches[selectedIndex] : matches[0]
    }

    var stakeValue: Int { Int(stakeText) ?? 0 }

    var canSimulate: Bool {
        !rolling && stakeValue >= 1 && stakeValue <= balance
    }

    func reroll() {
        matches = Self.generateMatches()
        selectedIndex = 0
    }

    func resetBalance() {
        preferences.resetBalance()
        balance = preferences.balance
        history.removeAll()
        lastResult = nil
    }

    func simulate() {
        let stake = stakeValue
        guard stake > 0, stake <= balance, !rolling else { return }
        rolling = true

        let current = match
        let odds: Double
        switch pick {
        case .home: odds = current.oddsHome()
        case .draw: odds = current.oddsDraw()
        case .away: odds = current.oddsAway()
        }
        let outcome = Self.simulateOutcome(current)
        let won = outcome == pick
        let payoff = won ? Int((Double(stake) * odds).rounded()) : 0
        let newBalance = max(0, balance - stake + payoff)
        balance = newBalance
        preferences.balance = newBalance

        let description = "\(current.home) vs \(current.away) • \(pick.rawValue) @ \(String(format: "%.2f", odds))"
        let item = SimHistoryItem(description: description, stake: stake, payoff: payoff, won: won)
        history.insert(item, at: 0)
        lastResult = item
        rolling = false
    }

    private static func generateMatches() -> [SimMatch] {
        let pool = sampleTeams.shuffled()
        var list: [SimMatch] = []
        var index = 0
        while index + 1 < pool.count && list.count < 5 {
            let first = pool[index]
            let second = pool[index + 1]
            list.append(SimMatch(home: first.0, away: second.0, homeStrength: first.1, awayStrength: second.1))
            index += 2
        }
        return list
    }

    private static func simulateOutcome(_ match: SimMatch) -> SimPick {
        let home = match.homeStrength + 6 + Int.random(in: 0..<12)
        let away = match.awayStrength + Int.random(in: 0..<12)
        let diff = home - away
        if diff > 6 { return .home }
        if diff < -6 { return .away }
        if Int.random(in: 0..<100) < 35 { return .draw }
        return diff >= 0 ? .home : .away
    }
}
