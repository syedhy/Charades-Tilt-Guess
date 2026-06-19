import Foundation

struct GameWord: Codable, Hashable, Identifiable {
    let id: String
    let text: String
    var imageName: String? = nil
}

enum DeckType: String, Codable {
    case `default`
    case custom
}

enum DeckColor: String, Codable {
    case yellow, mint, coral, blue, purple, pink, orange, gray
}

struct Deck: Codable, Hashable, Identifiable {
    let id: String
    var name: String
    var description: String?
    var cards: [GameWord]
    let type: DeckType
    var color: DeckColor
    var symbolName: String
    var createdDate: Date?
    var updatedDate: Date?
}

let url = URL(fileURLWithPath: "CharadesTiltGuess/Resources/DefaultDecks.json")
do {
    let data = try Data(contentsOf: url)
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .secondsSince1970
    let decks = try decoder.decode([Deck].self, from: data)
    print("Success: loaded \(decks.count) decks")
} catch {
    print("Error: \(error)")
}
