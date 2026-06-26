import SwiftUI

struct TeamMatchLobbyView: View {
    @ObservedObject var state: TeamMatchState
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        ZStack {
            DoodlePaperBackground()

            VStack(spacing: AppTheme.Spacing.roomy) {
                Spacer()

                header

                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .safeAreaInset(edge: .bottom) {
            startButton
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .preferredColorScheme(.light)
    }

    private var header: some View {
        VStack(spacing: 32) {
            HStack(spacing: 16) {
                DoodleIconButton(
                    symbol: "xmark",
                    accent: AppTheme.Colors.paperBright,
                    size: 48,
                    accessibilityLabel: "Exit Game"
                ) {
                    router.goHome()
                }

                Text("Round \(state.currentRound) of \(state.totalRounds)")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink.opacity(0.6))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(AppTheme.Colors.paperBright)
                            .overlay(
                                Capsule()
                                    .stroke(AppTheme.Colors.ink, lineWidth: 4)
                            )
                    )
            }

            VStack(spacing: 32) {
                Image(systemName: "hand.point.right.fill")
                    .font(.system(size: 88, weight: .black))
                    .foregroundStyle(GameMode.teamVsTeam.accentColor)
                    .padding(24)
                    .background(
                        Circle()
                            .fill(AppTheme.Colors.paperBright)
                            .overlay(
                                Circle().stroke(AppTheme.Colors.ink, lineWidth: 4)
                            )
                    )

                Text("Team \(state.currentTeam)'s\nTurn")
                    .font(.system(size: 56, weight: .black, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(AppTheme.Colors.ink)
                    .lineLimit(2)
                    .minimumScaleFactor(0.5)
                    .accessibilityIdentifier("teamMatchTurnTitle")

                Text("Pass the device to Team \(state.currentTeam) to begin!")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(AppTheme.Colors.ink.opacity(0.7))
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 48)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(AppTheme.Colors.paperBright)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .stroke(AppTheme.Colors.ink, lineWidth: 4)
            )
        }
    }

    private var startButton: some View {
        DoodleActionButton(
            title: "Ready!",
            symbol: "play.fill",
            accent: GameMode.teamVsTeam.accentColor
        ) {
            guard let deck = state.currentDeck else { return }

            router.startGame(
                configuration: .teamVsTeam(
                    deck: deck,
                    duration: state.duration
                )
            )
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(AppTheme.Colors.paper.opacity(0.96))
    }
}
