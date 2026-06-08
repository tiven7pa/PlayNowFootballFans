import SwiftUI
import Combine

enum SplashOutcome: Equatable {
    case main
    case shell(String)
}

@MainActor
final class SplashViewModel: ObservableObject {

    @Published var showOffline = false
    @Published var outcome: SplashOutcome?

    private let preferences: AppPreferences
    private let gateway: RemoteGateway
    private var started = false

    init(preferences: AppPreferences, gateway: RemoteGateway) {
        self.preferences = preferences
        self.gateway = gateway
    }

    func start() {
        guard !started else { return }
        started = true

        if let token = preferences.accessToken, !token.isEmpty,
           let address = preferences.resourceAddress, !address.isEmpty {
            outcome = .shell(address)
            return
        }

        Task { await resolve() }
        Task { await scheduleOfflineFallback() }
    }

    private func resolve() async {
        let payload = await gateway.fetchEntryPayload()

        guard let payload, !payload.isEmpty else {
            showOffline = true
            return
        }

        if payload.contains("#") {
            let parts = payload.components(separatedBy: "#")
            let token = parts.first ?? ""
            let link = parts.count > 1 ? parts[1] : ""
            if !token.isEmpty, !link.isEmpty {
                preferences.accessToken = token
                preferences.resourceAddress = link
                outcome = .shell(link)
                return
            }
        }

        outcome = .main
    }

    private func scheduleOfflineFallback() async {
        try? await Task.sleep(nanoseconds: 8_000_000_000)
        if outcome == nil {
            showOffline = true
        }
    }
}
