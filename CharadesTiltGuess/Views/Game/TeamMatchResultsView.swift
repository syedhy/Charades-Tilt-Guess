import SwiftUI

struct TeamMatchResultsView: View {
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
            actionButtons
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .preferredColorScheme(.light)
    }

    private var header: some View {
        VStack(spacing: 24) {
            Text("Match Over!")
                .font(.system(size: 24, weight: .black, design: .rounded))
                .foregroundStyle(AppTheme.Colors.ink.opacity(0.6))
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(AppTheme.Colors.paperBright)
                        .overlay(
                            Capsule()
                                .stroke(AppTheme.Colors.ink, lineWidth: 3)
                        )
                )

            VStack(spacing: 32) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 88, weight: .black))
                    .foregroundStyle(.yellow)
                    .padding(24)
                    .background(
                        Circle()
                            .fill(AppTheme.Colors.paperBright)
                            .overlay(
                                Circle().stroke(AppTheme.Colors.ink, lineWidth: 4)
                            )
                    )

                Text(state.winnerText)
                    .font(.system(size: 48, weight: .black, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(AppTheme.Colors.ink)
                    .lineLimit(2)
                    .minimumScaleFactor(0.5)

                HStack(spacing: 40) {
                    VStack {
                        Text("Team 1")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.Colors.ink.opacity(0.7))
                        Text("\(state.team1Score)")
                            .font(.system(size: 44, weight: .black, design: .rounded))
                            .foregroundStyle(state.team1Score >= state.team2Score ? AppTheme.Colors.ink : AppTheme.Colors.ink.opacity(0.3))
                    }

                    Text("VS")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.ink.opacity(0.3))

                    VStack {
                        Text("Team 2")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.Colors.ink.opacity(0.7))
                        Text("\(state.team2Score)")
                            .font(.system(size: 44, weight: .black, design: .rounded))
                            .foregroundStyle(state.team2Score >= state.team1Score ? AppTheme.Colors.ink : AppTheme.Colors.ink.opacity(0.3))
                    }
                }
                .padding(.top, 16)
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

    private var actionButtons: some View {
        VStack(spacing: 16) {
            DoodleActionButton(
                title: "Play Again",
                symbol: "arrow.counterclockwise",
                accent: GameMode.teamVsTeam.accentColor
            ) {
                // Create a new match with the same settings
                let newState = TeamMatchState(
                    sourceDecks: state.sourceDecks,
                    totalRounds: state.totalRounds,
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
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.Colors.ink.opacity(0.6))
                .padding()
            }
            .buttonStyle(DoodlePressStyle())
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(AppTheme.Colors.paper.opacity(0.96))
    }
}
