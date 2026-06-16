import Foundation

enum WikipediaServiceError: Error, Equatable {
    case invalidURL
    case requestFailed
    case emptyResponse
}

struct WikipediaService {
    private let session: URLSession
    private let endpoint: URL

    init(
        session: URLSession = .shared,
        endpoint: URL = URL(string: "https://en.wikipedia.org/w/api.php")!
    ) {
        self.session = session
        self.endpoint = endpoint
    }

    func loadRandomTitles(limit: Int = 40) async throws -> [String] {
        var components = URLComponents(url: endpoint, resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "action", value: "query"),
            URLQueryItem(name: "generator", value: "random"),
            URLQueryItem(name: "grnnamespace", value: "0"),
            URLQueryItem(name: "grnlimit", value: "\(limit)"),
            URLQueryItem(name: "prop", value: "info"),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "origin", value: "*")
        ]

        guard let url = components?.url else {
            throw WikipediaServiceError.invalidURL
        }

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(from: url)
        } catch {
            throw WikipediaServiceError.requestFailed
        }

        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode
        else {
            throw WikipediaServiceError.requestFailed
        }

        let decoded = try JSONDecoder().decode(WikipediaRandomResponse.self, from: data)
        let titles = decoded.query.pages.values
            .map(\.title)
            .map(sanitizedTitle)
            .filter { !$0.isEmpty && $0.count <= 50 }
            .sorted()

        guard !titles.isEmpty else {
            throw WikipediaServiceError.emptyResponse
        }

        return titles
    }

    private func sanitizedTitle(_ title: String) -> String {
        title
            .replacingOccurrences(of: "_", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

private struct WikipediaRandomResponse: Decodable {
    let query: WikipediaQuery
}

private struct WikipediaQuery: Decodable {
    let pages: [String: WikipediaPage]
}

private struct WikipediaPage: Decodable {
    let title: String
}
