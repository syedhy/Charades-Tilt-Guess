import Foundation

enum CustomDeckStoreError: Error, Equatable {
    case invalidData
    case invalidDeckType(String)
    case duplicateDeckID(String)
    case emptyDeckName(String)
    case emptyWord(deckID: String, wordID: String)
    case deckLimitReached(Int)
    case cardLimitReached(deckID: String, limit: Int)
}

struct CustomDeckStore {
    private let fileURL: URL
    private let fileManager: FileManager

    init(
        fileManager: FileManager = .default,
        fileURL: URL? = nil
    ) {
        self.fileManager = fileManager
        self.fileURL = fileURL ?? Self.defaultFileURL(fileManager: fileManager)
    }

    func loadDecks() throws -> [Deck] {
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return []
        }

        do {
            let data = try Data(contentsOf: fileURL)
            let decks = try JSONDecoder().decode([Deck].self, from: data)
            try validate(decks)
            return decks.sorted { lhs, rhs in
                (lhs.updatedDate ?? lhs.createdDate ?? .distantPast) >
                (rhs.updatedDate ?? rhs.createdDate ?? .distantPast)
            }
        } catch let error as CustomDeckStoreError {
            throw error
        } catch {
            throw CustomDeckStoreError.invalidData
        }
    }

    func saveDecks(_ decks: [Deck]) throws {
        try validate(decks)
        try fileManager.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        let data = try encoder.encode(decks)
        try data.write(to: fileURL, options: .atomic)
    }

    func upsert(_ deck: Deck) throws {
        var decks = try loadDecks()

        if let existingIndex = decks.firstIndex(where: { $0.id == deck.id }) {
            decks[existingIndex] = deck
        } else {
            decks.append(deck)
        }

        try saveDecks(decks)
    }

    func deleteDeck(id: String) throws {
        var decks = try loadDecks()
        decks.removeAll { $0.id == id }
        try saveDecks(decks)
    }

    private func validate(_ decks: [Deck]) throws {
        let maxDecks = 20
        let maxCards = 1500

        guard decks.count <= maxDecks else {
            throw CustomDeckStoreError.deckLimitReached(maxDecks)
        }

        var deckIDs = Set<String>()

        for deck in decks {
            guard deckIDs.insert(deck.id).inserted else {
                throw CustomDeckStoreError.duplicateDeckID(deck.id)
            }

            guard deck.type == .custom else {
                throw CustomDeckStoreError.invalidDeckType(deck.id)
            }

            guard !deck.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw CustomDeckStoreError.emptyDeckName(deck.id)
            }

            guard deck.cards.count <= maxCards else {
                throw CustomDeckStoreError.cardLimitReached(deckID: deck.id, limit: maxCards)
            }

            for word in deck.cards {
                guard !word.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                    throw CustomDeckStoreError.emptyWord(deckID: deck.id, wordID: word.id)
                }
            }
        }
    }

    private static func defaultFileURL(fileManager: FileManager) -> URL {
        let baseURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first ?? fileManager.temporaryDirectory
        return baseURL
            .appendingPathComponent("CharadesTiltGuess", isDirectory: true)
            .appendingPathComponent("CustomDecks.json")
    }
}
