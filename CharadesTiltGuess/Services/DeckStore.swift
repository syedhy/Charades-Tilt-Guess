struct DeckStore {
    private let defaultDeckLoader: DefaultDeckLoader
    private let customDeckStore: CustomDeckStore

    init(
        defaultDeckLoader: DefaultDeckLoader = DefaultDeckLoader(),
        customDeckStore: CustomDeckStore = CustomDeckStore()
    ) {
        self.defaultDeckLoader = defaultDeckLoader
        self.customDeckStore = customDeckStore
    }

    func loadDefaultDecks() throws -> [Deck] {
        try defaultDeckLoader.load()
    }

    func loadCustomDecks() throws -> [Deck] {
        try customDeckStore.loadDecks()
    }

    func loadDecks() throws -> [Deck] {
        try loadCustomDecks() + loadDefaultDecks()
    }

    func saveCustomDeck(_ deck: Deck) throws {
        try customDeckStore.upsert(deck)
    }

    func deleteCustomDeck(id: String) throws {
        try customDeckStore.deleteDeck(id: id)
    }
}
