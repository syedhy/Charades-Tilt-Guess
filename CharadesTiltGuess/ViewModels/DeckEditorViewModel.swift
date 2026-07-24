import Foundation

@MainActor
final class DeckEditorViewModel: ObservableObject {
    @Published var deckName = ""
    @Published var selectedColor: DeckColor = .mint
    @Published private(set) var saveErrorMessage: String?
    let isEmoji: Bool

    private let deckStore: DeckStore
    private let idProvider: () -> String
    private let dateProvider: () -> Date

    let availableColors: [DeckColor] = [.mint, .yellow, .coral, .blue, .purple, .pink, .orange, .gray]

    init(
        isEmoji: Bool = false,
        deckStore: DeckStore = DeckStore(),
        idProvider: @escaping () -> String = { "custom-\(UUID().uuidString)" },
        dateProvider: @escaping () -> Date = Date.init
    ) {
        self.isEmoji = isEmoji
        self.selectedColor = isEmoji ? .yellow : .mint
        self.deckStore = deckStore
        self.idProvider = idProvider
        self.dateProvider = dateProvider
    }

    var trimmedDeckName: String {
        deckName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var nameCharacterCountText: String {
        "\(min(deckName.count, Self.maxNameLength)) / \(Self.maxNameLength)"
    }

    var canSave: Bool {
        !trimmedDeckName.isEmpty && deckName.count <= Self.maxNameLength
    }

    @discardableResult
    func saveDeck() -> Deck? {
        guard canSave else {
            saveErrorMessage = "Give your deck a name first."
            return nil
        }

        let now = dateProvider()
        let prefix = isEmoji ? "emoji-custom-" : "custom-"
        let rawID = idProvider()
        let deckID = rawID.hasPrefix("custom-") ? rawID.replacingOccurrences(of: "custom-", with: prefix) : prefix + rawID

        let deck = Deck(
            id: deckID,
            name: trimmedDeckName,
            description: nil,
            cards: [],
            type: .custom,
            color: selectedColor,
            symbolName: isEmoji ? "face.smiling.fill" : "rectangle.stack",
            isEmoji: isEmoji,
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
}
