import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var decks: [Deck] = []
    @Published private(set) var loadErrorMessage: String?

    private let deckStore: DeckStore

    init(deckStore: DeckStore = DeckStore()) {
        self.deckStore = deckStore
        loadDecks()
    }

    func loadDecks() {
        do {
            decks = try deckStore.loadDefaultDecks()
            loadErrorMessage = nil
        } catch {
            decks = []
            loadErrorMessage = "The premade decks could not be loaded."
        }
    }

    var randomDeck: Deck? {
        decks.randomElement()
    }
}
