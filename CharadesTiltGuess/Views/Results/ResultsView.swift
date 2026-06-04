import SwiftUI

struct ResultsView: View {
    let deckName: String
    let onPlayAgain: () -> Void
    let onChooseDeck: () -> Void

    var body: some View {
        PlaceholderScreen(
            eyebrow: "ROUND COMPLETE",
            title: "Results placeholder",
            message: "The final score and correct or passed words for \(deckName) will appear here.",
            symbol: "trophy",
            accent: Color(red: 1.00, green: 0.82, blue: 0.23),
            primaryActionTitle: "Play placeholder again",
            primaryAction: onPlayAgain,
            secondaryActionTitle: "Choose another deck",
            secondaryAction: onChooseDeck
        )
        .navigationTitle("Results")
    }
}

