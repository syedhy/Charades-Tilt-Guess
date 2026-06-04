import SwiftUI

struct DeckGridView: View {
    let decks: [Deck]
    let onSelect: (Deck) -> Void

    private let rotations = [-1.2, 1.0, 0.8, -0.9, 0.6]

    var body: some View {
        LazyVGrid(
            columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible())],
            spacing: AppTheme.Spacing.standard
        ) {
            ForEach(Array(decks.enumerated()), id: \.element.id) { index, deck in
                let rotation = rotations[index % rotations.count]

                Button {
                    onSelect(deck)
                } label: {
                    DeckCardView(
                        name: deck.name,
                        detail: "\(deck.cards.count) prompts",
                        symbol: deck.symbolName,
                        accent: deck.color.displayColor,
                        rotation: rotation
                    )
                }
                .buttonStyle(DoodlePressStyle(rotation: rotation))
                .accessibilityLabel("\(deck.name), \(deck.cards.count) prompts")
            }
        }
    }
}

#Preview {
    DeckGridView(
        decks: [
            Deck(
                id: "preview-tech",
                name: "Tech",
                cards: [GameWord(id: "preview-ai", text: "AI")],
                type: .default,
                color: .mint,
                symbolName: "laptopcomputer"
            )
        ],
        onSelect: { _ in }
    )
    .padding()
    .background(DoodlePaperBackground())
}
