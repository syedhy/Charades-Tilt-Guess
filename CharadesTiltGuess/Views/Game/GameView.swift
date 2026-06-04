import SwiftUI

struct GameView: View {
    let deckName: String
    let onEndRound: () -> Void
    let onExit: () -> Void

    var body: some View {
        ZStack {
            PlaceholderPaperBackground()

            VStack(spacing: 24) {
                HStack {
                    Text("FULL-SCREEN GAME")
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .foregroundStyle(.black.opacity(0.58))

                    Spacer()

                    Button(action: onExit) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .black))
                            .foregroundStyle(.black)
                            .frame(width: 48, height: 48)
                            .background(.white, in: Circle())
                            .overlay(Circle().stroke(.black, lineWidth: 3))
                    }
                    .accessibilityLabel("Exit game")
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

                Button(action: onEndRound) {
                    Text("End placeholder round")
                        .font(.system(size: 17, weight: .black, design: .rounded))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 58)
                        .background(
                            Color(red: 0.39, green: 0.82, blue: 0.62),
                            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(.black, lineWidth: 3)
                        }
                        .shadow(color: .black.opacity(0.16), radius: 0, x: 4, y: 5)
                }
                .buttonStyle(.plain)
            }
            .foregroundStyle(.black)
            .padding(24)
        }
        .preferredColorScheme(.light)
    }
}

