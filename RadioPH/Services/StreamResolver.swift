import Foundation

enum StreamResolverError: Error {
    case invalidResponse
    case streamNotFound
}

enum StreamResolver {
    static func resolve(from resolverURL: URL) async throws -> URL {
        var request = URLRequest(url: resolverURL)
        request.timeoutInterval = 15
        request.setValue("RadioPH/1.0", forHTTPHeaderField: "User-Agent")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode,
              let page = String(data: data, encoding: .utf8) else {
            throw StreamResolverError.invalidResponse
        }

        let pattern = #"var\s+streamUrl\s*=\s*['"]([^'"]+)['"]"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(
                in: page,
                range: NSRange(page.startIndex..., in: page)
              ),
              let valueRange = Range(match.range(at: 1), in: page) else {
            throw StreamResolverError.streamNotFound
        }

        let value = String(page[valueRange])
            .replacingOccurrences(of: "http://", with: "https://")
        guard let streamURL = URL(string: value) else {
            throw StreamResolverError.streamNotFound
        }
        return streamURL
    }
}
