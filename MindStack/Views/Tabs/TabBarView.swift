import SwiftUI

struct TabBarView: View {
    enum Tab: Int, CaseIterable {
        case home = 0
        case analytics = 1
        case profile = 2
    }

    @State private var tab: Tab = .home

    var body: some View {
        TabView(selection: $tab) {
            NavigationStack {
                HomeView()
            }
                .tag(Tab.home)
                .tabItem { Label("Ana Sayfa", systemImage: "square.grid.2x2.fill") }

            NavigationStack {
                AnalyticsView()
            }
                .tag(Tab.analytics)
                .tabItem { Label("İstatistik", systemImage: "chart.bar.fill") }

            NavigationStack {
                ProfileView()
            }
                .tag(Tab.profile)
                .tabItem { Label("Profil", systemImage: "person.fill") }
        }
        .tint(AppColors.primary)
    }
}
