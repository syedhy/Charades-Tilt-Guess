import SwiftUI

struct TeamMatchResultsView: View {
    @ObservedObject var state: TeamMatchState
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        ZStack {
            DoodlePaperBackground()

            ScrollView {
                VStack(spacing: AppTheme.Spacing.roomy) {
                    header
                    leaderboardPanel
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 120)
            }
            .scrollIndicators(.hidden)
        }
        .safeAreaInset(edge: .bottom) {
            actionButtons
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .preferredColorScheme(.light)
    }

    private var header: some View {
        VStack(spacing: 20) {
            Text("Match Over!")
                .font(.system(size: 20, weight: .black, design: .rounded))
                .foregroundStyle(AppTheme.Colors.ink.opacity(0.6))
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(AppTheme.Colors.paperBright)
                        .overlay(
                            Capsule().stroke(AppTheme.Colors.ink, lineWidth: 3)
                        )
                )

            DoodlePanel(background: AppTheme.Colors.paperBright) {
                VStack(spacing: 18) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 72, weight: .black))
                        .foregroundStyle(.yellow)
                        .padding(20)
                        .background(
                            Circle()
                                .fill(AppTheme.Colors.paper)
                                .overlay(Circle().stroke(AppTheme.Colors.ink, lineWidth: 4))
                        )

                    Text(state.winnerText)
                        .font(.system(size: 40, weight: .black, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(AppTheme.Colors.ink)
                        .lineLimit(2)
                        .minimumScaleFactor(0.5)
                }
                .padding(24)
                .frame(maxWidth: .infinity)
            }
        }
    }

    private var leaderboardPanel: some View {
        DoodlePanel(background: AppTheme.Colors.paperBright) {
            VStack(alignment: .leading, spacing: 14) {
                Text("FINAL LEADERBOARD")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink.opacity(0.55))

                VStack(spacing: 12) {
                    let sortedTeams = state.leaderboard
                    ForEach(Array(sortedTeams.enumerated()), id: \.element.id) { index, team in
                        HStack(spacing: 14) {
                            Text(rankBadgeText(index: index))
                                .font(.system(size: 22))
                                .frame(width: 36)

                            Text(team.icon)
                                .font(.system(size: 24))

                            VStack(alignment: .leading, spacing: 2) {
                                Text(team.name)
                                    .font(.system(size: 20, weight: .black, design: .rounded))
                                    .foregroundStyle(AppTheme.Colors.ink)
                            }

                            Spacer()

                            Text("\(team.score) pts")
                                .font(.system(size: 24, weight: .black, design: .rounded))
                                .foregroundStyle(index == 0 ? AppTheme.Colors.ink : AppTheme.Colors.ink.opacity(0.5))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            index == 0 ? team.color.displayColor.opacity(0.3) : AppTheme.Colors.paper,
                            in: RoundedRectangle(cornerRadius: AppTheme.Radius.card, style: .continuous)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.Radius.card, style: .continuous)
                                .stroke(AppTheme.Colors.ink, lineWidth: index == 0 ? 3 : 2)
                        )
                    }
                }
            }
            .padding(20)
        }
    }

    private func rankBadgeText(index: Int) -> String {
        switch index {
        case 0: return "🥇"
        case 1: return "🥈"
        case 2: return "🥉"
        default: return "#\(index + 1)"
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            DoodleActionButton(
                title: "Play Again",
                symbol: "arrow.counterclockwise",
                accent: GameMode.teamVsTeam.accentColor
            ) {
                let newState = TeamMatchState(
                    numberOfTeams: state.numberOfTeams,
                    playersPerTeam: state.playersPerTeam,
                    sourceDecks: state.sourceDecks,
                    duration: state.duration
                )
                router.activeTeamMatch = newState
                router.openImmediately(.teamMatchLobby(state: newState))
            }

            Button {
                router.activeTeamMatch = nil
                router.goHome()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "house.fill")
                    Text("Main Menu")
                }
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.Colors.ink.opacity(0.6))
                .padding(.vertical, 6)
            }
            .buttonStyle(DoodlePressStyle())
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(AppTheme.Colors.paper.opacity(0.96))
    }
}
