import SwiftUI

struct SettingsView: View {
    @Environment(AppModel.self) private var model
    @State private var highQuality = true

    var body: some View {
        @Bindable var model = model
        Form {
            Section("Appearance") {
                Toggle("Dark mode", isOn: $model.isDarkMode)
            }
            Section("Playback") {
                Toggle("High-quality streams", isOn: $highQuality)
                NavigationLink {
                    EqualizerView()
                } label: {
                    Label("Equalizer", systemImage: "slider.vertical.3")
                }
                HStack {
                    Label("Bluetooth & AirPlay", systemImage: "airplayaudio")
                    Spacer()
                    AudioRoutePicker()
                        .frame(width: 44, height: 44)
                }
            }
            Section("Library") {
                LabeledContent("Offline favorites list", value: "\(model.favorites.count) saved")
                LabeledContent("Philippine stations", value: "\(model.stations.count)")
            }
            Section("About") {
                Text("Station directory data is provided by the community Radio Browser service. Stream availability belongs to each broadcaster.")
                    .font(.footnote)
            }
        }
        .tint(Theme.brass)
        .navigationTitle("Settings")
    }
}

struct EqualizerView: View {
    @State private var bass = 0.6
    @State private var mids = 0.5
    @State private var treble = 0.55

    var body: some View {
        Form {
            Section("Tone") {
                LabeledSlider(title: "Bass", value: $bass)
                LabeledSlider(title: "Mids", value: $mids)
                LabeledSlider(title: "Treble", value: $treble)
            }
            Text("Equalizer controls are prepared for a future audio-engine integration.")
                .font(.footnote)
        }
        .navigationTitle("Equalizer")
    }
}

private struct LabeledSlider: View {
    let title: String
    @Binding var value: Double

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
            Slider(value: $value)
        }
    }
}
