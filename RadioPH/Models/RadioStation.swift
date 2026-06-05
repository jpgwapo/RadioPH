import Foundation

struct RadioStation: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let streamURL: URL?
    let streamResolverURL: URL?
    let websiteURL: URL?
    let listenPageURL: URL?
    let streamType: String?
    let directStream: Bool
    let browserPlayable: Bool
    let notes: String?
    let logoURL: URL?
    let location: String
    let genre: String
    let frequency: String
    let votes: Int

    var fmFrequency: Double? {
        let number = frequency.prefix { $0.isNumber || $0 == "." }
        guard let value = Double(number), 87.5...108.0 ~= value else {
            return nil
        }
        return value
    }

    init(
        id: String,
        name: String,
        streamURL: URL?,
        streamResolverURL: URL? = nil,
        websiteURL: URL? = nil,
        listenPageURL: URL? = nil,
        streamType: String? = nil,
        directStream: Bool = false,
        browserPlayable: Bool = false,
        notes: String? = nil,
        logoURL: URL?,
        location: String,
        genre: String,
        frequency: String,
        votes: Int
    ) {
        self.id = id
        self.name = name
        self.streamURL = streamURL
        self.streamResolverURL = streamResolverURL
        self.websiteURL = websiteURL
        self.listenPageURL = listenPageURL
        self.streamType = streamType
        self.directStream = directStream
        self.browserPlayable = browserPlayable
        self.notes = notes
        self.logoURL = logoURL
        self.location = location
        self.genre = genre
        self.frequency = frequency
        self.votes = votes
    }

    private static let seedStations: [RadioStation] = [
        .init(
            id: "easy-rock-manila",
            name: "Easy Rock Manila",
            streamURL: URL(
                string: "https://azura.easyrock.com.ph/listen/easy_rock_manila/radio.mp3"
            ),
            websiteURL: URL(string: "https://www.easyrock.com.ph/"),
            listenPageURL: URL(string: "https://www.easyrock.com.ph/"),
            streamType: "audio/mpeg",
            directStream: true,
            browserPlayable: true,
            logoURL: nil,
            location: "Pasay · Metro Manila",
            genre: "Soft Rock · Love Songs · Adult Contemporary",
            frequency: "96.3 FM",
            votes: 0
        ),
        .init(
            id: "klite-olongapo",
            name: "96.7 K-Lite",
            streamURL: nil,
            streamResolverURL: URL(
                string: "https://widgets.caster.fm/em_player.php?jsinit=true&uid=487014&t=yellow&c="
            ),
            websiteURL: URL(string: "https://967klite.caster.fm/"),
            listenPageURL: URL(string: "https://967klite.caster.fm/"),
            directStream: false,
            browserPlayable: true,
            notes: "Caster.fm player links are generated and should not be stored permanently.",
            logoURL: nil,
            location: "Olongapo · Zambales",
            genre: "CHR · Top 40 · Pop",
            frequency: "96.7 FM",
            votes: 0
        )
    ]

    static let fallbackStations: [RadioStation] = {
        guard let url = Bundle.main.url(forResource: "stations", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let records = try? JSONDecoder().decode([CuratedStationRecord].self, from: data)
        else {
            return seedStations
        }

        let seedStreamURLs = Set(seedStations.compactMap { $0.streamURL?.absoluteString })
        let imported = records.compactMap { record -> RadioStation? in
            guard !record.title.isEmpty,
                  let streamURL = URL(string: record.streamURL),
                  !seedStreamURLs.contains(record.streamURL)
            else {
                return nil
            }

            return RadioStation(
                id: record.id,
                name: record.title,
                streamURL: streamURL,
                websiteURL: URL(string: record.pageURL),
                listenPageURL: URL(string: record.pageURL),
                directStream: true,
                browserPlayable: true,
                logoURL: nil,
                location: "Philippines",
                genre: "Live Radio",
                frequency: frequency(in: record.title),
                votes: 0
            )
        }
        return seedStations + imported
    }()

    private static func frequency(in name: String) -> String {
        let pattern = #"\b(?:8[7-9]|9\d|10[0-8])(?:\.\d)?\b|\b\d{3,4}\b"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(
                in: name,
                range: NSRange(name.startIndex..., in: name)
              ),
              let range = Range(match.range, in: name) else {
            return "LIVE"
        }
        return String(name[range])
    }
}

private struct CuratedStationRecord: Decodable {
    let pageURL: String
    let title: String
    let streamURL: String

    enum CodingKeys: String, CodingKey {
        case title
        case pageURL = "url"
        case streamURL = "stream_url"
    }

    var id: String {
        guard let page = URL(string: pageURL) else {
            return title.lowercased().replacingOccurrences(of: " ", with: "-")
        }
        return page.deletingPathExtension().lastPathComponent
    }
}

struct RadioBrowserStation: Decodable {
    let stationuuid: String
    let name: String
    let urlResolved: String
    let favicon: String
    let tags: String
    let state: String
    let votes: Int
    let lastcheckok: Int

    enum CodingKeys: String, CodingKey {
        case stationuuid, name, favicon, tags, state, votes, lastcheckok
        case urlResolved = "url_resolved"
    }

    var station: RadioStation {
        RadioStation(
            id: stationuuid,
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            streamURL: URL(string: urlResolved),
            logoURL: URL(string: favicon),
            location: state.isEmpty ? "Philippines" : state,
            genre: normalizedGenre,
            frequency: Self.frequency(in: name),
            votes: votes
        )
    }

    private var normalizedGenre: String {
        let firstTags = tags
            .split(separator: ",")
            .prefix(2)
            .map { $0.trimmingCharacters(in: .whitespaces).capitalized }
        return firstTags.isEmpty ? "Community Radio" : firstTags.joined(separator: " · ")
    }

    private static func frequency(in name: String) -> String {
        let pattern = #"\b(?:8[7-9]|9\d|10[0-8])(?:\.\d)?\b|\b\d{3,4}\b"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(
                in: name,
                range: NSRange(name.startIndex..., in: name)
              ),
              let range = Range(match.range, in: name) else {
            return "LIVE"
        }
        return String(name[range])
    }
}
