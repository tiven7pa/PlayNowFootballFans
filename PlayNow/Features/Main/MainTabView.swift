import SwiftUI

struct MainTabView: View {
    let onOpenNotice: () -> Void

    @State private var selection = 0

    init(onOpenNotice: @escaping () -> Void) {
        self.onOpenNotice = onOpenNotice
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(AppPalette.surface)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView(selection: $selection) {
            HomeView(onOpenNotice: onOpenNotice)
                .tabItem {
                    Label("Home", systemImage: selection == 0 ? "house.fill" : "house")
                }
                .tag(0)

            LeaguesView()
                .tabItem {
                    Label("Leagues", systemImage: selection == 1 ? "soccerball.inverse" : "soccerball")
                }
                .tag(1)

            ChatListView()
                .tabItem {
                    Label("Coach", systemImage: selection == 2 ? "bubble.left.and.bubble.right.fill" : "bubble.left.and.bubble.right")
                }
                .tag(2)

            SimulatorView()
                .tabItem {
                    Label("Simulator", systemImage: selection == 3 ? "dice.fill" : "dice")
                }
                .tag(3)

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: selection == 4 ? "person.fill" : "person")
                }
                .tag(4)
        }
        .tint(AppPalette.accent)
        .statusBarHidden(false)
    }
}
