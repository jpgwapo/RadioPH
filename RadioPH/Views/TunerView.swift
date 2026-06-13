import SwiftUI

struct TunerView: View {
    @Environment(AppModel.self) private var model
    @State private var showingSleepTimer = false

    private var station: RadioStation {
        model.player.currentStation
            ?? model.stations.first
            ?? RadioStation.fallbackStations[0]
    }

    var body: some View {
        ZStack {
            Theme.ivory.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 18) {
                    header
                    radioConsole
                    presets
                    stationList
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 112)
            }
            .scrollIndicators(.hidden)
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showingSleepTimer) {
            SleepTimerView()
                .presentationDetents([.medium])
        }
    }

    private var header: some View {
        VStack(spacing: 4) {
            HStack {
                Button { showingSleepTimer = true } label: {
                    VStack(spacing: 2) {
                        Image(systemName: model.sleepTimerEnd == nil
                            ? "moon.zzz.fill" : "timer")
                            .font(.body)
                        Text(model.sleepTimerEnd == nil ? "Sleep" : "Timer")
                            .font(.caption2.weight(.semibold))
                    }
                        .foregroundStyle(Theme.espresso)
                        .frame(width: 64, height: 54)
                        .background(
                            Theme.surface.opacity(0.72),
                            in: RoundedRectangle(cornerRadius: 20)
                        )
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
                .accessibilityHint("Choose when radio playback should stop")
                Spacer()
                VStack(spacing: 0) {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .foregroundStyle(Theme.brass)
                    Text("RadioPH")
                        .font(.system(size: 37, weight: .bold, design: .serif))
                        .foregroundStyle(Theme.espresso)
                }
                Spacer()
                VStack(spacing: 2) {
                    AudioRoutePicker()
                        .frame(width: 44, height: 38)
                    Text("Output")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(Theme.espresso)
                }
                .frame(width: 64, height: 54)
                .background(
                    Theme.surface.opacity(0.72),
                    in: RoundedRectangle(cornerRadius: 20)
                )
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Choose audio output")
            }
            Text("T U N E  I N")
                .font(.caption.weight(.bold))
                .tracking(4)
                .foregroundStyle(Theme.brass)
        }
    }

    private var radioConsole: some View {
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                FrequencyScale(frequency: station.fmFrequency)
                stationReadout
                speaker
            }
            .padding(16)
            .background(Theme.brushedBrass, in: RoundedRectangle(cornerRadius: 20))
        }
        .padding(12)
        .background {
            Image("WoodTexture")
                .resizable()
                .scaledToFill()
                .overlay(.black.opacity(0.08))
        }
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .overlay {
            RoundedRectangle(cornerRadius: 30)
                .stroke(.black.opacity(0.3), lineWidth: 2)
        }
        .shadow(color: Theme.control.opacity(0.22), radius: 12, y: 8)
    }

    private var stationReadout: some View {
        VStack(spacing: 3) {
            Text(station.name)
                .font(.system(.title2, design: .serif, weight: .bold))
                .lineLimit(1)
                .minimumScaleFactor(0.72)
            HStack(spacing: 6) {
                Text("● LIVE").foregroundStyle(Theme.signalRed)
                Text("•")
                Text(station.location).lineLimit(1)
            }
            .font(.caption.weight(.semibold))
        }
        .foregroundStyle(Theme.onDark)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Theme.dialBlack, in: RoundedRectangle(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Theme.brass.opacity(0.7), lineWidth: 1)
        }
    }

    private var speaker: some View {
        HStack(spacing: 6) {
            VintageSpeakerCone()
            centerSpeakerControl
            VintageSpeakerCone()
        }
        .frame(maxWidth: .infinity)
        .frame(height: 118)
    }

    private var centerSpeakerControl: some View {
        ZStack {
            Image("BrassSpeakerGrille")
                .resizable()
                .scaledToFill()
                .frame(width: 74, height: 102)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Theme.control.opacity(0.24), lineWidth: 1)
                }

            Button { model.togglePlayback(station) } label: {
                Circle()
                    .fill(Theme.control)
                    .frame(width: 68, height: 68)
                    .overlay {
                        Image(
                            systemName: model.player.isPlaying
                                && model.player.currentStation?.id == station.id
                                ? "pause.fill" : "play.fill"
                        )
                        .font(.title2)
                        .foregroundStyle(Theme.onDark)
                        .offset(
                            x: model.player.isPlaying
                                && model.player.currentStation?.id == station.id ? 0 : 2
                        )
                    }
                    .overlay {
                        Circle()
                            .stroke(Theme.brass.opacity(0.42), lineWidth: 1)
                    }
                    .shadow(color: .black.opacity(0.25), radius: 6, y: 3)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(
                model.player.isPlaying && model.player.currentStation?.id == station.id
                    ? "Pause \(station.name)"
                    : "Play \(station.name)"
            )
        }
        .frame(width: 74)
    }

    private var presets: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Quick Presets")
                .font(.system(.title3, design: .serif, weight: .bold))
                .foregroundStyle(Theme.espresso)
            ScrollView(.horizontal) {
                HStack(spacing: 10) {
                    ForEach(model.stations.prefix(5)) { item in
                        Button {
                            model.play(item)
                        } label: {
                            VStack(spacing: 5) {
                                Image(systemName: model.favorites.contains(item.id)
                                    ? "star.fill" : "star")
                                Text(item.frequency)
                                    .font(.headline)
                                    .lineLimit(1)
                                Text(item.name)
                                    .font(.caption2)
                                    .lineLimit(1)
                            }
                            .foregroundStyle(
                                item.id == station.id ? .white : Theme.espresso
                            )
                            .frame(width: 94, height: 84)
                            .background(
                                item.id == station.id
                                    ? Theme.brass : Theme.surface.opacity(0.82),
                                in: RoundedRectangle(cornerRadius: 16)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }

    private var stationList: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Philippine Stations")
                .font(.system(.title2, design: .serif, weight: .bold))
                .foregroundStyle(Theme.espresso)
            ForEach(model.stations.prefix(8)) { item in
                StationRow(station: item)
            }
            if model.isLoading {
                ProgressView("Finding live stations…")
                    .tint(Theme.brass)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
        }
    }
}

private struct VintageSpeakerCone: View {
    var body: some View {
        Image("VintageWoofer")
            .resizable()
            .scaledToFit()
            .clipShape(Circle())
            .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .aspectRatio(1, contentMode: .fit)
        .accessibilityHidden(true)
    }
}

private struct FrequencyScale: View {
    let frequency: Double?
    private let minimumFrequency = 87.5
    private let maximumFrequency = 108.0
    private let ticks = [88.0, 92.0, 96.0, 100.0, 104.0, 108.0]

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("FM")
                Spacer()
                ForEach(ticks, id: \.self) { tick in
                    Text(tick.formatted(.number.precision(.fractionLength(0))))
                    if tick != ticks.last { Spacer() }
                }
            }
            .font(.system(.caption, design: .serif, weight: .bold))
            .foregroundStyle(Theme.onDark)

            GeometryReader { proxy in
                let markerX = markerPosition(in: proxy.size.width)
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Theme.brass.opacity(0.35))
                        .frame(height: 3)
                        .offset(y: 14)

                    ForEach(ticks, id: \.self) { tick in
                        Rectangle()
                            .fill(Theme.brass.opacity(0.55))
                            .frame(width: 1, height: 10)
                            .position(
                                x: position(for: tick, width: proxy.size.width),
                                y: 15
                            )
                    }

                    if let frequency {
                        VStack(spacing: 2) {
                            Text(frequency.formatted(.number.precision(.fractionLength(1))))
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(Theme.ember)
                            Capsule()
                                .fill(Theme.ember)
                                .frame(width: 4, height: 32)
                                .shadow(color: Theme.ember, radius: 5)
                        }
                        .position(x: markerX, y: 28)
                    } else {
                        Text("LIVE")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Theme.ember)
                            .frame(maxWidth: .infinity)
                            .offset(y: 15)
                    }
                }
            }
            .frame(height: 58)
        }
        .padding(12)
        .background(Theme.dialBlack, in: RoundedRectangle(cornerRadius: 14))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityDescription)
    }

    private var accessibilityDescription: String {
        guard let frequency else { return "Live internet station" }
        return "FM dial positioned at \(frequency.formatted())"
    }

    private func markerPosition(in width: CGFloat) -> CGFloat {
        guard let frequency else { return width / 2 }
        return position(for: frequency, width: width)
    }

    private func position(for frequency: Double, width: CGFloat) -> CGFloat {
        let progress =
            (frequency - minimumFrequency) / (maximumFrequency - minimumFrequency)
        return max(2, min(width - 2, width * progress))
    }
}
