import SwiftUI

struct AppRootView: View {
    @StateObject private var appVM = AppViewModel()
    @AppStorage("isOnboarded") private var isOnboarded: Bool = false
    @AppStorage("ui_build") private var uiBuild: String = ""
    @State private var didBootstrap = false

    private static let currentBuild = "ui_2026-02-14_4"

    init() {
        let defaults = UserDefaults.standard
        let savedBuild = defaults.string(forKey: "ui_build") ?? ""
        if savedBuild != Self.currentBuild {
            defaults.set(Self.currentBuild, forKey: "ui_build")
            defaults.set(false, forKey: "isOnboarded")
        }
    }

    var body: some View {
        Group {
            if appVM.isLoading {
                SplashView()
            } else if !isOnboarded {
                OnboardingView()
            } else if !appVM.isAuthenticated {
                AuthView()
            } else {
                TabBarView()
            }
        }
        .environmentObject(appVM)
        .environment(\.layoutDirection, .leftToRight)
        .dynamicTypeSize(.xSmall ... .xxxLarge)
        .preferredColorScheme(.dark)
        .onAppear {
            guard !didBootstrap else { return }
            didBootstrap = true

            if uiBuild != Self.currentBuild {
                uiBuild = Self.currentBuild
                isOnboarded = false
            }
        }
    }
}
