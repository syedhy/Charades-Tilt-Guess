import SwiftUI

struct DeckEditorView: View {
    var body: some View {
        PlaceholderScreen(
            eyebrow: "CUSTOM DECK",
            title: "Create a custom deck",
            message: "Deck naming, color selection, manual cards, and clipboard import arrive in dedicated phases.",
            symbol: "rectangle.stack.badge.plus",
            accent: AppTheme.Colors.coral
        )
        .navigationTitle("New Deck")
    }
}
