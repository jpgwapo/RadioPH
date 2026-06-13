import SwiftUI

struct PresetsView: View {
    @Environment(AppModel.self) private var model

    private var favorites: [RadioStation] {
        model.stations.filter { model.favorites.contains($0.id) }
    }

    private var recent: [RadioStation] {
        model.recentStationIDs.compactMap { id in
            model.stations.first { $0.id == id }
        }
    }

    var body: some View {
        ZStack {
            Theme.ivory.ignoresSafeArea()
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    section("Favorites", stations: favorites, empty: "Star a station to save it offline.")
                    section("Recently Played", stations: recent, empty: "Your listening history will appear here.")
                }
                .padding(16)
                .padding(.bottom, 104)
            }
        }
        .navigationTitle("Presets")
    }

    @ViewBuilder
    private func section(_ title: String, stations: [RadioStation], empty: String) -> some View {
        Text(title)
            .font(.system(.title2, design: .serif, weight: .bold))
            .foregroundStyle(Theme.espresso)
            .padding(.top, 8)
        if stations.isEmpty {
            ContentUnavailableView(title, systemImage: "radio", description: Text(empty))
                .foregroundStyle(Theme.espresso)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 26)
        } else {
            ForEach(stations) { StationRow(station: $0) }
        }
    }
}
