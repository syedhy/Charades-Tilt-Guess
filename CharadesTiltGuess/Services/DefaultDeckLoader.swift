import Foundation

enum DefaultDeckLoaderError: Error, Equatable {
    case resourceNotFound(String)
    case invalidData
    case duplicateDeckID(String)
    case emptyDeck(String)
    case invalidDeckType(String)
    case duplicateWordID(deckID: String, wordID: String)
    case emptyWord(deckID: String, wordID: String)
}

struct DefaultDeckLoader {
    private let bundle: Bundle
    private let resourceName: String

    init(bundle: Bundle = .main, resourceName: String = "DefaultDecks") {
        self.bundle = bundle
        self.resourceName = resourceName
    }

    func load() throws -> [Deck] {
        guard let url = bundle.url(forResource: resourceName, withExtension: "json") else {
            throw DefaultDeckLoaderError.resourceNotFound(resourceName)
        }

        do {
            return try load(from: Data(contentsOf: url))
        } catch let error as DefaultDeckLoaderError {
            throw error
        } catch {
            throw DefaultDeckLoaderError.invalidData
        }
    }

    func load(from data: Data) throws -> [Deck] {
        let decks: [Deck]

        do {
            decks = try JSONDecoder().decode([Deck].self, from: data)
        } catch {
            throw DefaultDeckLoaderError.invalidData
        }

        try validate(decks)
        return decks
    }

    private func validate(_ decks: [Deck]) throws {
        var deckIDs = Set<String>()

        for deck in decks {
            guard deckIDs.insert(deck.id).inserted else {
                throw DefaultDeckLoaderError.duplicateDeckID(deck.id)
            }

            guard deck.type == .default else {
                throw DefaultDeckLoaderError.invalidDeckType(deck.id)
            }

            guard !deck.cards.isEmpty else {
                throw DefaultDeckLoaderError.emptyDeck(deck.id)
            }

            var wordIDs = Set<String>()

            for word in deck.cards {
                guard wordIDs.insert(word.id).inserted else {
                    throw DefaultDeckLoaderError.duplicateWordID(deckID: deck.id, wordID: word.id)
                }

                guard !word.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                    throw DefaultDeckLoaderError.emptyWord(deckID: deck.id, wordID: word.id)
                }
            }
        }
    }
}
