import SwiftUI

struct HomeView: View {
    @Environment(AppModel.self) private var model
    private let genres = ["All", "News", "Music", "Religious", "Sports", "Talk", "OPM", "Rock"]

    var body: some View {
        @Bindable var model = model
        ZStack {
            Theme.ivory.ignoresSafeArea()
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 14) {
                    Text("Discover")
                        .font(.system(size: 38, weight: .bold, design: .serif))
                        .foregroundStyle(Theme.espresso)
                    Text("Live radio from across the Philippines")
                        .foregroundStyle(Theme.espresso.opacity(0.66))
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(genres, id: \.self) { genre in
                                Button {
                                    model.selectedGenre = genre
                                } label: {
                                    Text(genre)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(
                                            model.selectedGenre == genre ? .white : Theme.espresso
                                        )
                                        .padding(.horizontal, 15)
                                        .frame(height: 42)
                                        .background(
                                            model.selectedGenre == genre
                                                ? Theme.brass : Theme.surface.opacity(0.82),
                                            in: Capsule()
                                        )
                                }
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                    ForEach(model.filteredStations) { StationRow(station: $0) }
                }
                .padding(16)
                .padding(.bottom, 104)
            }
            .searchable(
                text: $model.searchText,
                prompt: "Station, city, province, or genre"
            )
        }
        .navigationTitle("RadioPH")
        .navigationBarTitleDisplayMode(.inline)
    }
}
