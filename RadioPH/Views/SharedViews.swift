import AVKit
import SwiftUI

struct StationRow: View {
    @Environment(AppModel.self) private var model
    let station: RadioStation

    var body: some View {
        HStack(spacing: 12) {
            StationBadge(station: station)
            VStack(alignment: .leading, spacing: 3) {
                Text(station.name)
                    .font(.headline)
                    .foregroundStyle(Theme.espresso)
                Text("\(station.genre) · \(station.location)")
                    .font(.caption)
                    .foregroundStyle(Theme.espresso.opacity(0.64))
                    .lineLimit(1)
            }
            Spacer()
            Button { model.toggleFavorite(station) } label: {
                Image(systemName: model.favorites.contains(station.id)
                    ? "star.fill" : "star")
                    .foregroundStyle(Theme.brass)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel(
                model.favorites.contains(station.id)
                ? "Remove \(station.name) from favorites"
                : "Favorite \(station.name)"
            )
            Button { model.togglePlayback(station) } label: {
                Image(
                    systemName: model.player.isPlaying
                        && model.player.currentStation?.id == station.id
                        ? "pause.fill" : "play.fill"
                )
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(Theme.control, in: Circle())
            }
            .accessibilityLabel(
                model.player.isPlaying && model.player.currentStation?.id == station.id
                    ? "Pause \(station.name)"
                    : "Play \(station.name)"
            )
        }
        .padding(10)
        .background(Theme.surface.opacity(0.82), in: RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(Theme.brass.opacity(0.24), lineWidth: 1)
        }
    }
}

struct StationBadge: View {
    let station: RadioStation

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Theme.dialBlack)
            if let logoURL = station.logoURL {
                AsyncImage(url: logoURL) { phase in
                    if case .success(let image) = phase {
                        image.resizable().scaledToFit().padding(5)
                    } else {
                        frequency
                    }
                }
            } else {
                frequency
            }
        }
        .frame(width: 54, height: 54)
        .accessibilityHidden(true)
    }

    private var frequency: some View {
        Text(station.frequency)
            .font(.caption.weight(.black))
            .foregroundStyle(Theme.onDark)
            .minimumScaleFactor(0.65)
            .padding(4)
    }
}

struct MiniPlayerView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        if let station = model.player.currentStation {
            HStack(spacing: 10) {
                StationBadge(station: station)
                    .frame(width: 46, height: 46)
                VStack(alignment: .leading, spacing: 2) {
                    Text(station.name).font(.headline).lineLimit(1)
                    Text("● LIVE · \(station.location)")
                        .font(.caption)
                        .foregroundStyle(Theme.signalRed)
                        .lineLimit(1)
                }
                Spacer()
                Button { model.togglePlayback(station) } label: {
                    Image(systemName: model.player.isPlaying ? "pause.fill" : "play.fill")
                        .frame(width: 48, height: 48)
                        .background(Theme.brass, in: Circle())
                        .foregroundStyle(.white)
                }
                .accessibilityLabel(model.player.isPlaying ? "Pause live radio" : "Play live radio")
            }
            .padding(8)
            .foregroundStyle(Theme.espresso)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Theme.brass.opacity(0.45), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.14), radius: 8, y: 4)
        }
    }
}

struct PlaybackLoadingView: View {
    let station: RadioStation
    let onCancel: () -> Void

    var body: some View {
        ZStack {
            Button(action: onCancel) {
                Color.black.opacity(0.22)
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Cancel tuning")
            .accessibilityHint("Stops tuning in to \(station.name)")

            VStack(spacing: 14) {
                ProgressView()
                    .controlSize(.large)
                    .tint(Theme.brass)

                VStack(spacing: 4) {
                    Text("Tuning in…")
                        .font(.system(.headline, design: .serif, weight: .bold))
                    Text(station.name)
                        .font(.subheadline)
                        .foregroundStyle(Theme.espresso.opacity(0.68))
                }
            }
            .foregroundStyle(Theme.espresso)
            .padding(.horizontal, 34)
            .padding(.vertical, 26)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 22))
            .overlay {
                RoundedRectangle(cornerRadius: 22)
                    .stroke(Theme.brass.opacity(0.35), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.18), radius: 18, y: 8)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Tuning in to \(station.name)")
        .accessibilityAddTraits(.updatesFrequently)
        .accessibilityAction(.escape, onCancel)
    }
}

struct AudioRoutePicker: UIViewRepresentable {
    func makeUIView(context: Context) -> AVRoutePickerView {
        let picker = AVRoutePickerView()
        picker.prioritizesVideoDevices = false
        picker.tintColor = .label
        picker.activeTintColor = UIColor(Theme.brass)
        return picker
    }

    func updateUIView(_ picker: AVRoutePickerView, context: Context) {
        picker.tintColor = .label
        picker.activeTintColor = UIColor(Theme.brass)
    }
}
