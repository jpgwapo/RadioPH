import AVFoundation
import MediaPlayer
import Observation

@MainActor
@Observable
final class RadioPlayer {
    @ObservationIgnored
    private var player: AVPlayer?
    @ObservationIgnored
    private var timeControlObservation: NSKeyValueObservation?
    @ObservationIgnored
    private var itemStatusObservation: NSKeyValueObservation?
    @ObservationIgnored
    var togglePlaybackHandler: (() -> Void)?

    var currentStation: RadioStation?
    var isPlaying = false
    var isLoading = false
    var errorMessage: String?

    init() {
        configureAudioSession()
        configureRemoteCommands()
    }

    func play(_ station: RadioStation) {
        guard let streamURL = station.streamURL else {
            fail(station, message: "No playable stream is available for this station.")
            return
        }
        play(station, from: streamURL)
    }

    func play(_ station: RadioStation, from streamURL: URL) {
        clearPlayer()
        currentStation = station
        errorMessage = nil
        isLoading = true
        isPlaying = true

        let item = AVPlayerItem(url: streamURL)
        let newPlayer = AVPlayer(playerItem: item)
        player = newPlayer
        observePlayback(newPlayer, item: item, station: station)
        newPlayer.play()
        updateNowPlaying()
    }

    func prepare(_ station: RadioStation) {
        clearPlayer()
        currentStation = station
        isPlaying = false
        isLoading = true
        errorMessage = nil
    }

    func fail(_ station: RadioStation, message: String) {
        prepare(station)
        isLoading = false
        errorMessage = message
    }

    func togglePlayback() {
        if let togglePlaybackHandler {
            togglePlaybackHandler()
            return
        }
        pause()
    }

    func pause() {
        clearPlayer()
        isPlaying = false
        isLoading = false
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = 0
    }

    func stop() {
        pause()
        currentStation = nil
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }

    private func observePlayback(
        _ player: AVPlayer,
        item: AVPlayerItem,
        station: RadioStation
    ) {
        timeControlObservation = player.observe(
            \.timeControlStatus,
            options: [.initial, .new]
        ) { [weak self] player, _ in
            Task { @MainActor in
                guard let self,
                      self.player === player,
                      self.currentStation?.id == station.id else { return }
                switch player.timeControlStatus {
                case .playing:
                    self.isPlaying = true
                    self.isLoading = false
                case .waitingToPlayAtSpecifiedRate:
                    if self.isPlaying {
                        self.isLoading = true
                    }
                case .paused:
                    if !self.isPlaying {
                        self.isLoading = false
                    }
                @unknown default:
                    break
                }
            }
        }

        itemStatusObservation = item.observe(\.status, options: [.new]) {
            [weak self] item, _ in
            guard item.status == .failed else { return }
            Task { @MainActor in
                guard let self,
                      self.currentStation?.id == station.id else { return }
                self.isPlaying = false
                self.isLoading = false
                self.errorMessage = "Unable to play \(station.name)'s live stream."
            }
        }
    }

    private func clearPlayer() {
        timeControlObservation?.invalidate()
        itemStatusObservation?.invalidate()
        timeControlObservation = nil
        itemStatusObservation = nil
        player?.pause()
        player = nil
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: [.allowAirPlay, .allowBluetoothA2DP]
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            errorMessage = "Audio output could not be prepared."
        }
    }

    private func configureRemoteCommands() {
        let commands = MPRemoteCommandCenter.shared()
        commands.playCommand.addTarget { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                if !self.isPlaying { self.togglePlayback() }
            }
            return .success
        }
        commands.pauseCommand.addTarget { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                if self.isPlaying { self.togglePlayback() }
            }
            return .success
        }
    }

    private func updateNowPlaying() {
        guard let station = currentStation else { return }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyTitle: station.name,
            MPMediaItemPropertyArtist: "\(station.genre) · \(station.location)",
            MPNowPlayingInfoPropertyIsLiveStream: true,
            MPNowPlayingInfoPropertyPlaybackRate: 1
        ]
    }
}
