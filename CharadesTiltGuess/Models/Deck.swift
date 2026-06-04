import Foundation

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
