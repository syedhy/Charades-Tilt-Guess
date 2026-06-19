import Foundation

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

struct MixAndMatchDeckFactory {
    static let cardLimit = 50

    func makeDeck(from decks: [Deck]) -> Deck? {
        var generator = SystemRandomNumberGenerator()
        return makeDeck(from: decks, using: &generator)
    }

    func makeDeck<Generator: RandomNumberGenerator>(
        from decks: [Deck],
        using generator: inout Generator
    ) -> Deck? {
        let availableCards = uniqueCards(from: decks)

        guard !availableCards.isEmpty else { return nil }

        return Deck(
            id: "temp-mix-\(UUID().uuidString)",
            name: "Mix & Match",
            description: "A fresh mix from every deck.",
            cards: Array(availableCards.shuffled(using: &generator).prefix(Self.cardLimit)),
            type: .custom,
            color: .orange,
            symbolName: "square.stack.3d.up.fill"
        )
    }

    func availableCardCount(from decks: [Deck]) -> Int {
        uniqueCards(from: decks).count
    }

    private func uniqueCards(from decks: [Deck]) -> [GameWord] {
        var seenWords = Set<String>()
        return decks
            .flatMap(\.cards)
            .filter { card in
                seenWords.insert(normalized(card.text)).inserted
            }
    }

    private func normalized(_ text: String) -> String {
        text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(
                options: [.caseInsensitive, .diacriticInsensitive],
                locale: Locale(identifier: "en_US_POSIX")
            )
    }
}
