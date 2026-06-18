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
        let targetCount = max(12, min(limit, 60))
        let requestCount = min(max(limit * 4, 80), 100)
        var components = URLComponents(url: endpoint, resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "action", value: "query"),
            URLQueryItem(name: "generator", value: "random"),
            URLQueryItem(name: "grnnamespace", value: "0"),
            URLQueryItem(name: "grnlimit", value: "\(requestCount)"),
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
            .filter(isPlayableTitle)
            .uniquedCaseInsensitive()
            .shuffled()

        let playableTitles = (titles + Self.fallbackPlayableTitles.shuffled())
            .uniquedCaseInsensitive()
            .prefix(targetCount)

        guard !playableTitles.isEmpty else {
            throw WikipediaServiceError.emptyResponse
        }

        return Array(playableTitles)
    }

    private func sanitizedTitle(_ title: String) -> String {
        title
            .replacingOccurrences(of: "_", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func isPlayableTitle(_ title: String) -> Bool {
        let blockedFragments = ["(", ")", ",", ":", ";", ".", "/", "\\", "'", "\"", "&"]
        guard !title.isEmpty,
              (4...10).contains(title.count),
              !blockedFragments.contains(where: title.contains),
              title.rangeOfCharacter(from: .decimalDigits) == nil,
              title.allSatisfy({ $0.isLetter })
        else {
            return false
        }

        return !Self.obscureSuffixes.contains { title.localizedCaseInsensitiveContains($0) }
    }

    private static let obscureSuffixes = [
        "idae",
        "inae",
        "aceae",
        "ales",
        "iformes"
    ]

    private static let fallbackPlayableTitles = [
        "Anchor",
        "Apron",
        "Apple",
        "Arrow",
        "Artist",
        "Avocado",
        "Balloon",
        "Banana",
        "Basket",
        "Beach",
        "Beard",
        "Blanket",
        "Bottle",
        "Broom",
        "Bicycle",
        "Bird",
        "Bridge",
        "Brush",
        "Bucket",
        "Button",
        "Candle",
        "Camera",
        "Canoe",
        "Castle",
        "Cave",
        "Chair",
        "Cheese",
        "Cloud",
        "Comet",
        "Cookie",
        "Crayon",
        "Crown",
        "Curtain",
        "Desert",
        "Doctor",
        "Dolphin",
        "Dragon",
        "Drum",
        "Eagle",
        "Engine",
        "Farmer",
        "Feather",
        "Flower",
        "Forest",
        "Fountain",
        "Garden",
        "Ghost",
        "Glacier",
        "Glove",
        "Hammer",
        "Helmet",
        "Igloo",
        "Jelly",
        "Jungle",
        "Guitar",
        "Island",
        "Jacket",
        "Kettle",
        "King",
        "Kite",
        "Ladder",
        "Lantern",
        "Leaf",
        "Lion",
        "Lizard",
        "Magnet",
        "Market",
        "Medal",
        "Mirror",
        "Monkey",
        "Mountain",
        "Noodle",
        "Ocean",
        "Octopus",
        "Painter",
        "Pencil",
        "Piano",
        "Pillow",
        "Pirate",
        "Pizza",
        "Planet",
        "Puzzle",
        "Queen",
        "Rainbow",
        "River",
        "Robot",
        "Rocket",
        "Sailor",
        "Sandwich",
        "Scarf",
        "School",
        "Shadow",
        "Shovel",
        "Skate",
        "Skull",
        "Snail",
        "Snowman",
        "Spider",
        "Statue",
        "Subway",
        "Tennis",
        "Tiger",
        "Toaster",
        "Trophy",
        "Tunnel",
        "Umbrella",
        "Unicorn",
        "Violin",
        "Volcano",
        "Wallet",
        "Whistle",
        "Window",
        "Wizard",
        "Yacht",
        "Zebra"
    ]
}

private extension Array where Element == String {
    func uniquedCaseInsensitive() -> [String] {
        var seen = Set<String>()

        return filter { title in
            let key = title.lowercased()
            guard !seen.contains(key) else { return false }
            seen.insert(key)
            return true
        }
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
