import Foundation

@MainActor
final class DeckEditorViewModel: ObservableObject {
    @Published var deckName = ""
    @Published var selectedColor: DeckColor = .mint
    @Published private(set) var cards: [GameWord] = []
    @Published private(set) var cardErrorMessage: String?
    @Published private(set) var saveErrorMessage: String?

    private let deckStore: DeckStore
    private let idProvider: () -> String
    private let wordIDProvider: () -> String
    private let dateProvider: () -> Date

    let availableColors: [DeckColor] = [.mint, .yellow, .coral, .blue, .purple, .pink, .gray]

    init(
        deckStore: DeckStore = DeckStore(),
        idProvider: @escaping () -> String = { "custom-\(UUID().uuidString)" },
        wordIDProvider: @escaping () -> String = { "word-\(UUID().uuidString)" },
        dateProvider: @escaping () -> Date = Date.init
    ) {
        self.deckStore = deckStore
        self.idProvider = idProvider
        self.wordIDProvider = wordIDProvider
        self.dateProvider = dateProvider
    }

    var trimmedDeckName: String {
        deckName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var nameCharacterCountText: String {
        "\(min(deckName.count, Self.maxNameLength)) / \(Self.maxNameLength)"
    }

    var cardCountText: String {
        "\(cards.count) \(cards.count == 1 ? "prompt" : "prompts")"
    }

    var canSave: Bool {
        !trimmedDeckName.isEmpty && deckName.count <= Self.maxNameLength && !cards.isEmpty
    }

    func cardCharacterCountText(for text: String) -> String {
        "\(min(text.count, Self.maxCardTextLength)) / \(Self.maxCardTextLength)"
    }

    func canAddCard(text: String) -> Bool {
        cardValidationMessage(for: text) == nil
    }

    func cardValidationMessage(for text: String) -> String? {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedText.isEmpty {
            return "Type a card first."
        }

        if trimmedText.count > Self.maxCardTextLength {
            return "Keep cards under \(Self.maxCardTextLength) characters."
        }

        if cards.contains(where: { $0.text.localizedCaseInsensitiveCompare(trimmedText) == .orderedSame }) {
            return "That card is already in this deck."
        }

        return nil
    }

    @discardableResult
    func addCard(text: String) -> Bool {
        if let message = cardValidationMessage(for: text) {
            cardErrorMessage = message
            return false
        }

        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        cards.append(GameWord(id: wordIDProvider(), text: trimmedText))
        cardErrorMessage = nil
        saveErrorMessage = nil
        return true
    }

    func deleteCard(id: String) {
        cards.removeAll { $0.id == id }
    }

    func clearCardError() {
        cardErrorMessage = nil
    }

    @discardableResult
    func saveDeck() -> Deck? {
        guard canSave else {
            saveErrorMessage = trimmedDeckName.isEmpty ? "Give your deck a name first." : "Add at least one card first."
            return nil
        }

        let now = dateProvider()
        let deck = Deck(
            id: idProvider(),
            name: trimmedDeckName,
            description: nil,
            cards: cards,
            type: .custom,
            color: selectedColor,
            symbolName: "rectangle.stack",
            createdDate: now,
            updatedDate: now
        )

        do {
            try deckStore.saveCustomDeck(deck)
            saveErrorMessage = nil
            return deck
        } catch {
            saveErrorMessage = "The deck could not be saved. Please try again."
            return nil
        }
    }
}

extension DeckEditorViewModel {
    static let maxNameLength = 20
    static let maxCardTextLength = 50
}
