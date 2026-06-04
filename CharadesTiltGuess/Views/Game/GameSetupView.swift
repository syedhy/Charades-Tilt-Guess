import SwiftUI

struct GameSetupView: View {
    let deckName: String
    let onStartRound: () -> Void

    var body: some View {
        PlaceholderScreen(
            eyebrow: "GAME SETUP",
            title: "\(deckName) setup",
            message: "Round duration, deck details, and tilt instructions will be added in a later phase.",
            symbol: "timer",
            accent: AppTheme.Colors.yellow,
            primaryActionTitle: "Start placeholder round",
            primaryAction: onStartRound
        )
        .navigationTitle(deckName)
    }
}
