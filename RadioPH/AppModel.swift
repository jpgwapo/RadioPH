import Foundation
import Observation

@MainActor
@Observable
final class AppModel {
    @ObservationIgnored
    private let defaults: UserDefaults
    @ObservationIgnored
    private var playbackTask: Task<Void, Never>?
    @ObservationIgnored
    private var sleepTimerTask: Task<Void, Never>?

    var selectedTab: AppTab = .tuner
    var stations = RadioStation.fallbackStations
    var favorites: Set<String>
    var recentStationIDs: [String]
    var isLoading = false
    var searchText = ""
    var selectedGenre = "All"
    var isDarkMode = false
    var sleepTimerEnd: Date?
    var player: RadioPlayer

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.favorites = Set(defaults.stringArray(forKey: StorageKey.favorites) ?? [])
        self.recentStationIDs =
            defaults.stringArray(forKey: StorageKey.recentStationIDs) ?? []

        let player = RadioPlayer()
        self.player = player
        player.togglePlaybackHandler = { [weak self] in
            self?.togglePlayback()
        }
    }

    var filteredStations: [RadioStation] {
        stations.filter { station in
            let matchesGenre = selectedGenre == "All"
                || station.genre.localizedCaseInsensitiveContains(selectedGenre)
            let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            let matchesQuery = query.isEmpty
                || station.name.localizedCaseInsensitiveContains(query)
                || station.location.localizedCaseInsensitiveContains(query)
                || station.genre.localizedCaseInsensitiveContains(query)
            return matchesGenre && matchesQuery
        }
    }

    func loadStations() async {
        // The bundled curated catalog is ready immediately and remains available offline.
    }

    func play(_ station: RadioStation) {
        playbackTask?.cancel()
        playbackTask = nil

        if let streamURL = station.streamURL {
            player.play(station, from: streamURL)
        } else if let resolverURL = station.streamResolverURL {
            player.prepare(station)
            playbackTask = Task {
                do {
                    let streamURL = try await StreamResolver.resolve(from: resolverURL)
                    try Task.checkCancellation()
                    guard player.currentStation?.id == station.id else { return }
                    player.play(station, from: streamURL)
                } catch is CancellationError {
                    return
                } catch {
                    guard !Task.isCancelled else { return }
                    guard player.currentStation?.id == station.id else { return }
                    player.fail(
                        station,
                        message: "K-Lite's live stream is currently unavailable."
                    )
                }
            }
        } else {
            player.fail(station, message: "No playable stream is available for this station.")
        }
        recentStationIDs.removeAll { $0 == station.id }
        recentStationIDs.insert(station.id, at: 0)
        recentStationIDs = Array(recentStationIDs.prefix(20))
        persistLibrary()
    }

    func togglePlayback(_ station: RadioStation? = nil) {
        let targetStation = station ?? player.currentStation
        guard let targetStation else { return }

        let isCurrentStation = player.currentStation?.id == targetStation.id
        if isCurrentStation && (player.isPlaying || player.isLoading) {
            playbackTask?.cancel()
            playbackTask = nil
            player.pause()
        } else {
            play(targetStation)
        }
    }

    func cancelTuning() {
        guard player.isLoading else { return }
        playbackTask?.cancel()
        playbackTask = nil
        player.pause()
    }

    func setSleepTimer(minutes: Int) {
        sleepTimerTask?.cancel()
        let duration = TimeInterval(minutes * 60)
        sleepTimerEnd = Date().addingTimeInterval(duration)
        sleepTimerTask = Task { [weak self] in
            do {
                try await Task.sleep(for: .seconds(duration))
                guard !Task.isCancelled, let self else { return }
                self.playbackTask?.cancel()
                self.playbackTask = nil
                self.player.stop()
                self.sleepTimerEnd = nil
                self.sleepTimerTask = nil
            } catch {
                return
            }
        }
    }

    func cancelSleepTimer() {
        sleepTimerTask?.cancel()
        sleepTimerTask = nil
        sleepTimerEnd = nil
    }

    func toggleFavorite(_ station: RadioStation) {
        if favorites.contains(station.id) {
            favorites.remove(station.id)
        } else {
            favorites.insert(station.id)
        }
        persistLibrary()
    }

    private func persistLibrary() {
        defaults.set(favorites.sorted(), forKey: StorageKey.favorites)
        defaults.set(recentStationIDs, forKey: StorageKey.recentStationIDs)
    }

    private enum StorageKey {
        static let favorites = "library.favoriteStationIDs"
        static let recentStationIDs = "library.recentStationIDs"
    }
}

enum AppTab: Hashable {
    case home
    case tuner
    case presets
    case settings
}
