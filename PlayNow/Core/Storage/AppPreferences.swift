import Foundation

final class AppPreferences {

    static let shared = AppPreferences()

    static let defaultBalance = 1000

    private let store = UserDefaults.standard

    private enum Keys {
        static let balance = "sim_balance"
        static let notifications = "notifications"
        static let displayName = "display_name"
        static let favoriteLeague = "favorite_league"
        static let accessToken = "access_token"
        static let resourceAddress = "resource_address"
        static let balanceInitialized = "balance_initialized"
    }

    var balance: Int {
        get {
            if store.object(forKey: Keys.balanceInitialized) == nil {
                return AppPreferences.defaultBalance
            }
            return store.integer(forKey: Keys.balance)
        }
        set {
            store.set(true, forKey: Keys.balanceInitialized)
            store.set(newValue, forKey: Keys.balance)
        }
    }

    var displayName: String {
        get { store.string(forKey: Keys.displayName) ?? "PlayNow fan" }
        set { store.set(newValue, forKey: Keys.displayName) }
    }

    var favoriteLeague: Int {
        get {
            if store.object(forKey: Keys.favoriteLeague) == nil { return 39 }
            return store.integer(forKey: Keys.favoriteLeague)
        }
        set { store.set(newValue, forKey: Keys.favoriteLeague) }
    }

    var accessToken: String? {
        get { store.string(forKey: Keys.accessToken) }
        set { store.set(newValue, forKey: Keys.accessToken) }
    }

    var resourceAddress: String? {
        get { store.string(forKey: Keys.resourceAddress) }
        set { store.set(newValue, forKey: Keys.resourceAddress) }
    }

    func resetBalance() {
        balance = AppPreferences.defaultBalance
    }
}
