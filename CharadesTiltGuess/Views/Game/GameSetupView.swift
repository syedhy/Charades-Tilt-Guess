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
            accent: Color(red: 1.00, green: 0.82, blue: 0.23),
            primaryActionTitle: "Start placeholder round",
            primaryAction: onStartRound
        )
        .navigationTitle(deckName)
    }
}

