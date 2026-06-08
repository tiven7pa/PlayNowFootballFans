import SwiftUI
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {

    @Published var displayName: String
    @Published var balance: Int
    @Published var favoriteLeagueId: Int

    private let preferences = AppPreferences.shared

    init() {
        displayName = AppPreferences.shared.displayName
        balance = AppPreferences.shared.balance
        favoriteLeagueId = AppPreferences.shared.favoriteLeague
    }

    var favoriteLeague: LeagueInfo? {
        FootballCatalog.popularLeagues.first { $0.id == favoriteLeagueId }
    }

    func refresh() {
        balance = preferences.balance
        favoriteLeagueId = preferences.favoriteLeague
        displayName = preferences.displayName
    }

    func saveName(_ name: String) {
        let cleaned = String(name.trimmingCharacters(in: .whitespacesAndNewlines).prefix(24))
        guard !cleaned.isEmpty else { return }
        displayName = cleaned
        preferences.displayName = cleaned
    }

    func selectLeague(_ id: Int) {
        favoriteLeagueId = id
        preferences.favoriteLeague = id
    }

    func resetBalance() {
        preferences.resetBalance()
        balance = preferences.balance
    }
}
