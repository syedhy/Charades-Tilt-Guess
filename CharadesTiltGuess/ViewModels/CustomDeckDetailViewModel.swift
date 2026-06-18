import Foundation

@MainActor
final class CustomDeckDetailViewModel: ObservableObject {
    @Published private(set) var deck: Deck
    @Published var draftName: String
    @Published var draftColor: DeckColor
    @Published private(set) var draftCards: [GameWord]
    @Published private(set) var cardErrorMessage: String?
    @Published private(set) var importPreview = ClipboardImportPreview(
        cards: [],
        blankLineCount: 0,
        duplicateCount: 0,
        tooLongLines: [],
        overDeckLimitCount: 0,
        maxCardLength: CustomDeckDetailViewModel.maxCardTextLength
    )
    @Published private(set) var saveErrorMessage: String?
    @Published private(set) var deleteErrorMessage: String?

    private let deckStore: DeckStore
    private let importService: ClipboardImportService
    private let wordIDProvider: () -> String
    private let dateProvider: () -> Date

    let availableColors: [DeckColor] = [.mint, .yellow, .coral, .blue, .purple, .pink, .orange, .gray]

    init(
        deck: Deck,
        deckStore: DeckStore = DeckStore(),
        importService: ClipboardImportService = ClipboardImportService(maxCardLength: 30),
        wordIDProvider: @escaping () -> String = { "word-\(UUID().uuidString)" },
        dateProvider: @escaping () -> Date = Date.init
    ) {
        self.deck = deck
        self.draftName = deck.name
        self.draftColor = deck.color
        self.draftCards = deck.cards
        self.deckStore = deckStore
        self.importService = importService
        self.wordIDProvider = wordIDProvider
        self.dateProvider = dateProvider
    }

    var trimmedDraftName: String {
        draftName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var draftCardCountText: String {
        "\(draftCards.count) \(draftCards.count == 1 ? "card" : "cards")"
    }

    var nameCharacterCountText: String {
        "\(min(draftName.count, Self.maxNameLength)) / \(Self.maxNameLength)"
    }

    var canSaveDraft: Bool {
        !trimmedDraftName.isEmpty && draftName.count <= Self.maxNameLength
    }

    var hasUnsavedChanges: Bool {
        trimmedDraftName != deck.name || draftColor != deck.color || draftCards != deck.cards
    }

    func resetDraft() {
        draftName = deck.name
        draftColor = deck.color
        draftCards = deck.cards
        cardErrorMessage = nil
        saveErrorMessage = nil
        importPreview = importService.previewCards(from: "", existingCards: draftCards)
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

        if draftCards.count >= Self.maxCustomDeckCardCount {
            return "Custom decks can have up to \(Self.maxCustomDeckCardCount) cards."
        }

        if draftCards.contains(where: { $0.text.localizedCaseInsensitiveCompare(trimmedText) == .orderedSame }) {
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
        draftCards.insert(GameWord(id: wordIDProvider(), text: trimmedText), at: 0)
        cardErrorMessage = nil
        saveErrorMessage = nil
        refreshImportPreview(from: "")
        return true
    }

    func deleteDraftCard(id: String) {
        draftCards.removeAll { $0.id == id }
        cardErrorMessage = nil
    }

    func refreshImportPreview(from text: String) {
        importPreview = importPreviewLimitedToRemainingSlots(
            importService.previewCards(from: text, existingCards: draftCards)
        )
    }

    @discardableResult
    func importCards(from text: String) -> Int {
        let preview = importPreviewLimitedToRemainingSlots(
            importService.previewCards(from: text, existingCards: draftCards)
        )
        importPreview = preview

        guard preview.hasImportableCards else {
            cardErrorMessage = draftCards.count >= Self.maxCustomDeckCardCount
                ? "Custom decks can have up to \(Self.maxCustomDeckCardCount) cards."
                : "Paste one card per line to import."
            return 0
        }

        let newCards = preview.cards.map { GameWord(id: wordIDProvider(), text: $0) }
        draftCards.insert(contentsOf: newCards, at: 0)
        cardErrorMessage = nil
        saveErrorMessage = nil
        refreshImportPreview(from: "")
        return newCards.count
    }

    @discardableResult
    func saveDraft() -> Deck? {
        guard canSaveDraft else {
            saveErrorMessage = trimmedDraftName.isEmpty ? "Give your deck a name first." : "Keep the name under \(Self.maxNameLength) characters."
            return nil
        }

        guard draftCards.count <= Self.maxCustomDeckCardCount else {
            saveErrorMessage = "Custom decks can have up to \(Self.maxCustomDeckCardCount) cards."
            return nil
        }

        var updatedDeck = deck
        updatedDeck.name = trimmedDraftName
        updatedDeck.color = draftColor
        updatedDeck.cards = draftCards
        updatedDeck.updatedDate = dateProvider()

        do {
            try deckStore.saveCustomDeck(updatedDeck)
            deck = updatedDeck
            saveErrorMessage = nil
            cardErrorMessage = nil
            return updatedDeck
        } catch {
            saveErrorMessage = "The deck could not be saved. Please try again."
            return nil
        }
    }

    @discardableResult
    func deleteDeck() -> Bool {
        do {
            try deckStore.deleteCustomDeck(id: deck.id)
            deleteErrorMessage = nil
            return true
        } catch {
            deleteErrorMessage = "The deck could not be deleted. Please try again."
            return false
        }
    }

    private func importPreviewLimitedToRemainingSlots(_ preview: ClipboardImportPreview) -> ClipboardImportPreview {
        let remainingSlots = max(Self.maxCustomDeckCardCount - draftCards.count, 0)
        guard preview.cards.count > remainingSlots else { return preview }

        return ClipboardImportPreview(
            cards: Array(preview.cards.prefix(remainingSlots)),
            blankLineCount: preview.blankLineCount,
            duplicateCount: preview.duplicateCount,
            tooLongLines: preview.tooLongLines,
            overDeckLimitCount: preview.overDeckLimitCount + preview.cards.count - remainingSlots,
            maxCardLength: preview.maxCardLength
        )
    }
}

extension CustomDeckDetailViewModel {
    static let maxNameLength = 20
    static let maxCardTextLength = 30
    static let maxCustomDeckCardCount = 200
}
