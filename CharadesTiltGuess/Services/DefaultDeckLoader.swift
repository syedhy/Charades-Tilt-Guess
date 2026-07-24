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
    
    // Maintain the desired display order of default decks
    private let defaultDeckIDs = [
        "emoji-movies", "emoji-animals", "emoji-pop", "emoji-food", "emoji-places",
        "default-tech", "default-movies", "default-food", "default-sports", 
        "default-animals", "default-countries", "default-celebrities", 
        "default-tv-shows", "default-cartoons", "default-science", 
        "default-school", "default-history", "default-easy", "default-hard"
    ]

    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }

    func load() throws -> [Deck] {
        var allDecks: [Deck] = []
        
        for id in defaultDeckIDs {
            // Because they are in an Xcode group and not a folder reference, they are flattened in the bundle.
            guard let url = bundle.url(forResource: id, withExtension: "json") else {
                throw DefaultDeckLoaderError.resourceNotFound(id)
            }
            
            do {
                let data = try Data(contentsOf: url)
                let decks = try load(from: data)
                allDecks.append(contentsOf: decks)
            } catch let error as DefaultDeckLoaderError {
                throw error
            } catch {
                throw DefaultDeckLoaderError.invalidData
            }
        }
        
        try validate(allDecks)
        return allDecks
    }

    func load(from data: Data) throws -> [Deck] {
        let decks: [Deck]

        do {
            decks = try JSONDecoder().decode([Deck].self, from: data)
            try validate(decks)
        } catch let error as DefaultDeckLoaderError {
            throw error
        } catch {
            throw DefaultDeckLoaderError.invalidData
        }

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
