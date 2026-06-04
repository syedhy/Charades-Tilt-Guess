import SwiftUI

struct DeckEditorView: View {
    var body: some View {
        PlaceholderScreen(
            eyebrow: "CUSTOM DECK",
            title: "Create a custom deck",
            message: "Deck naming, color selection, manual cards, and clipboard import arrive in dedicated phases.",
            symbol: "rectangle.stack.badge.plus",
            accent: Color(red: 0.96, green: 0.42, blue: 0.36)
        )
        .navigationTitle("New Deck")
    }
}

