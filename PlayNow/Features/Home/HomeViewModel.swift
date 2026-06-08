import SwiftUI
import Combine

@MainActor
final class HomeViewModel: ObservableObject {

    @Published var live: [FixtureItem] = []
    @Published var todayCount = 0
    @Published var liveCount = 0
    @Published var loading = true
    @Published var loaded = false

    private let service = FootballService()
    private static let liveStatuses: Set<String> = ["1H", "2H", "HT", "ET", "P", "LIVE"]

    func loadIfNeeded() {
        guard !loaded else { return }
        loaded = true
        Task {
            let result = await service.fixturesByDate(FootballCatalog.todayDate())
            let all = result.data ?? []
            todayCount = all.count
            let running = all.filter { HomeViewModel.liveStatuses.contains($0.statusShort) }
            liveCount = running.count
            if running.isEmpty {
                live = Array(all.sorted { $0.timestamp < $1.timestamp }.prefix(5))
            } else {
                live = running
            }
            loading = false
        }
    }
}
