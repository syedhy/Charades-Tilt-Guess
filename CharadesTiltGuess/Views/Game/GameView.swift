import SwiftUI

struct GameView: View {
    let deckName: String
    let onEndRound: () -> Void
    let onExit: () -> Void

    var body: some View {
        ZStack {
            DoodlePaperBackground()

            VStack(spacing: 24) {
                HStack {
                    Text("FULL-SCREEN GAME")
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .foregroundStyle(.black.opacity(0.58))

                    Spacer()

                    DoodleIconButton(
                        symbol: "xmark",
                        size: 48,
                        accessibilityLabel: "Exit game",
                        action: onExit
                    )
                }

                Spacer()

                Image(systemName: "iphone.gen3.radiowaves.left.and.right")
                    .font(.system(size: 66, weight: .black))

                Text("Game placeholder")
                    .font(.system(size: 40, weight: .black, design: .rounded))
                    .multilineTextAlignment(.center)
                    .accessibilityIdentifier("gamePlaceholderTitle")

                Text(deckName)
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundStyle(.black.opacity(0.56))

                Text("Landscape gameplay, timer, words, and tilt controls arrive in later phases.")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.black.opacity(0.58))
                    .multilineTextAlignment(.center)

                Spacer()

                DoodleActionButton(
                    title: "End placeholder round",
                    symbol: "flag.checkered",
                    accent: AppTheme.Colors.mint,
                    action: onEndRound
                )
            }
            .foregroundStyle(.black)
            .padding(24)
        }
        .preferredColorScheme(.light)
    }
}
