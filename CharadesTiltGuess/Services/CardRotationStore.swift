import Foundation

struct CardRotationState: Codable, Equatable {
    var seenWordIDsByDeckID: [String: [String]] = [:]
}

struct CardRotationStore {
    private let userDefaults: UserDefaults
    private let key: String

    init(
        userDefaults: UserDefaults = .standard,
        key: String = "CharadesTiltGuess.CardRotationState"
    ) {
        self.userDefaults = userDefaults
        self.key = key
    }

    func orderedCards(for deck: Deck) -> [GameWord] {
        let state = loadState()
        let validIDs = Set(deck.cards.map(\.id))
        let seenIDs = Set((state.seenWordIDsByDeckID[deck.id] ?? []).filter { validIDs.contains($0) })
        let unseen = deck.cards.filter { !seenIDs.contains($0.id) }

        guard !unseen.isEmpty else {
            return deck.cards.shuffled()
        }

        let previouslySeen = deck.cards.filter { seenIDs.contains($0.id) }
        return unseen.shuffled() + previouslySeen.shuffled()
    }

    func recordSeenCards(_ words: [GameWord], for deck: Deck) {
        guard !deck.cards.isEmpty, !words.isEmpty else { return }

        var state = loadState()
        let validIDs = Set(deck.cards.map(\.id))
        var seen = (state.seenWordIDsByDeckID[deck.id] ?? []).filter { validIDs.contains($0) }
        var seenSet = Set(seen)

        for word in words where validIDs.contains(word.id) && seenSet.insert(word.id).inserted {
            seen.append(word.id)
        }

        if seenSet.count >= validIDs.count {
            state.seenWordIDsByDeckID[deck.id] = []
        } else {
            state.seenWordIDsByDeckID[deck.id] = seen
        }

        saveState(state)
    }

    func reset(deckID: String) {
        var state = loadState()
        state.seenWordIDsByDeckID[deckID] = []
        saveState(state)
    }

    func loadState() -> CardRotationState {
        guard let data = userDefaults.data(forKey: key),
              let state = try? JSONDecoder().decode(CardRotationState.self, from: data)
        else {
            return CardRotationState()
        }

        return state
    }

    private func saveState(_ state: CardRotationState) {
        guard let data = try? JSONEncoder().encode(state) else { return }
        userDefaults.set(data, forKey: key)
    }
}
