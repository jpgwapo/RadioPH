import Foundation

struct StationDirectory {
    private let endpoint = URL(
        string: "https://de1.api.radio-browser.info/json/stations/bycountrycodeexact/PH?hidebroken=true&order=votes&reverse=true&limit=100"
    )!

    func fetchPhilippineStations() async throws -> [RadioStation] {
        var request = URLRequest(url: endpoint)
        request.timeoutInterval = 15
        request.setValue("RadioPH/1.0", forHTTPHeaderField: "User-Agent")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse,
              200..<300 ~= http.statusCode else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder()
            .decode([RadioBrowserStation].self, from: data)
            .filter { $0.lastcheckok == 1 && !$0.name.isEmpty && !$0.urlResolved.isEmpty }
            .map(\.station)
    }
}
