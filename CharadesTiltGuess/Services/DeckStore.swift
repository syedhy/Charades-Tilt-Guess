struct DeckStore {
    private let defaultDeckLoader: DefaultDeckLoader

    init(defaultDeckLoader: DefaultDeckLoader = DefaultDeckLoader()) {
        self.defaultDeckLoader = defaultDeckLoader
    }

    func loadDefaultDecks() throws -> [Deck] {
        try defaultDeckLoader.load()
    }
}
