import SwiftUI

struct AppShellView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        @Bindable var model = model
        TabView(selection: $model.selectedTab) {
            NavigationStack { HomeView() }
                .miniPlayerInset()
                .tag(AppTab.home)
                .tabItem { Label("Home", systemImage: "house") }

            NavigationStack { TunerView() }
                .miniPlayerInset()
                .tag(AppTab.tuner)
                .tabItem { Label("Tuner", systemImage: "radio") }

            NavigationStack { PresetsView() }
                .miniPlayerInset()
                .tag(AppTab.presets)
                .tabItem { Label("Presets", systemImage: "star") }

            NavigationStack { SettingsView() }
                .miniPlayerInset()
                .tag(AppTab.settings)
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
        .tint(Theme.brass)
        .overlay {
            if model.player.isLoading,
               let station = model.player.currentStation {
                PlaybackLoadingView(station: station) {
                    model.cancelTuning()
                }
                .transition(.opacity.combined(with: .scale(scale: 0.96)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: model.player.isLoading)
        .task { await model.loadStations() }
    }
}

private extension View {
    func miniPlayerInset() -> some View {
        safeAreaInset(edge: .bottom, spacing: 0) {
            MiniPlayerView()
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
        }
    }
}
