import SwiftUI

struct TeamMatchLobbyView: View {
    @ObservedObject var state: TeamMatchState
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        ZStack {
            DoodlePaperBackground()

            ScrollView {
                VStack(spacing: AppTheme.Spacing.roomy) {
                    header
                    turnSplashCard
                    standingsPanel
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 96)
            }
            .scrollIndicators(.hidden)
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
        HStack(spacing: 16) {
            DoodleIconButton(
                symbol: "xmark",
                accent: AppTheme.Colors.paperBright,
                size: 44,
                accessibilityLabel: "Exit Game"
            ) {
                router.goHome()
            }

            Spacer()

            Text("Round \(state.currentRound) of \(state.playersPerTeam)")
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundStyle(AppTheme.Colors.ink.opacity(0.7))
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(AppTheme.Colors.paperBright)
                        .overlay(
                            Capsule().stroke(AppTheme.Colors.ink, lineWidth: 3)
                        )
                )
        }
    }

    private var turnSplashCard: some View {
        let team = state.currentTeamInfo

        return DoodlePanel(background: team.color.displayColor.opacity(0.35)) {
            VStack(spacing: 24) {
                Text(team.icon)
                    .font(.system(size: 88))
                    .padding(20)
                    .background(
                        Circle()
                            .fill(AppTheme.Colors.paperBright)
                            .overlay(
                                Circle().stroke(AppTheme.Colors.ink, lineWidth: 4)
                            )
                    )

                VStack(spacing: 8) {
                    Text("\(team.name.uppercased())'S TURN")
                        .font(.system(size: 38, weight: .black, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(AppTheme.Colors.ink)
                        .lineLimit(2)
                        .minimumScaleFactor(0.6)
                        .accessibilityIdentifier("teamMatchTurnTitle")

                    Text("Player \(state.currentRound) of \(state.playersPerTeam) is up!")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.ink.opacity(0.7))
                }

                Text("Pass the device to \(team.name) to begin!")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(AppTheme.Colors.ink.opacity(0.6))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(AppTheme.Colors.paperBright, in: Capsule())
                    .overlay(Capsule().stroke(AppTheme.Colors.ink, lineWidth: 2))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 36)
            .frame(maxWidth: .infinity)
        }
    }

    private var standingsPanel: some View {
        DoodlePanel(background: AppTheme.Colors.paperBright) {
            VStack(alignment: .leading, spacing: 14) {
                Text("CURRENT STANDINGS")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink.opacity(0.55))

                VStack(spacing: 10) {
                    ForEach(state.teams) { team in
                        HStack(spacing: 12) {
                            Text(team.icon)
                                .font(.system(size: 20))

                            Text(team.name)
                                .font(.system(size: 18, weight: .black, design: .rounded))
                                .foregroundStyle(AppTheme.Colors.ink)

                            if team.id == state.currentTeamInfo.id {
                                Text("UP NOW")
                                    .font(.system(size: 10, weight: .black, design: .rounded))
                                    .foregroundStyle(AppTheme.Colors.ink)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(GameMode.teamVsTeam.accentColor, in: Capsule())
                            }

                            Spacer()

                            Text("\(team.score) pts")
                                .font(.system(size: 20, weight: .black, design: .rounded))
                                .foregroundStyle(AppTheme.Colors.ink)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            team.id == state.currentTeamInfo.id ? team.color.displayColor.opacity(0.2) : AppTheme.Colors.paper,
                            in: RoundedRectangle(cornerRadius: AppTheme.Radius.card, style: .continuous)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.Radius.card, style: .continuous)
                                .stroke(AppTheme.Colors.ink, lineWidth: 2)
                        )
                    }
                }
            }
            .padding(18)
        }
    }

    private var startButton: some View {
        DoodleActionButton(
            title: "Ready! Start Turn",
            symbol: "play.fill",
            accent: state.currentTeamInfo.color.displayColor
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
