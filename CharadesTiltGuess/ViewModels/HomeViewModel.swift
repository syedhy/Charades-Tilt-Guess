import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var defaultDecks: [Deck] = []
    @Published private(set) var customDecks: [Deck] = []
    @Published private(set) var loadErrorMessage: String?

    private let deckStore: DeckStore
    init(deckStore: DeckStore = DeckStore()) {
        self.deckStore = deckStore
        loadDecks()
    }

    func loadDecks() {
        do {
            defaultDecks = try deckStore.loadDefaultDecks()
            customDecks = try deckStore.loadCustomDecks()
            loadErrorMessage = nil
        } catch {
            defaultDecks = []
            customDecks = []
            loadErrorMessage = "The decks could not be loaded."
        }
    }

    var canCreateNewDeck: Bool {
        customDecks.count < 20
    }

    var decks: [Deck] {
        customDecks + defaultDecks
    }

    var randomDeck: Deck? {
        decks.randomElement()
    }

}
