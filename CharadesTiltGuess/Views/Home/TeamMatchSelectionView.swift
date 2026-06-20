import SwiftUI

struct TeamMatchSelectionView: View {
    let settings: GameSettings

    @EnvironmentObject private var router: AppRouter
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedDeckIDs: Set<String> = []
    @State private var selectedRounds: Int = 3

    var body: some View {
        ZStack {
            DoodlePaperBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.roomy) {
                    header

                    if let loadErrorMessage = viewModel.loadErrorMessage {
                        loadError(message: loadErrorMessage)
                    } else {
                        roundsPicker

                        selectionControls

                        if !viewModel.customDecks.isEmpty {
                            deckSection(title: "Custom Decks", decks: viewModel.customDecks)
                        }

                        deckSection(title: "Built-In Decks", decks: viewModel.defaultDecks)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 4)
                .padding(.bottom, 96)
            }
            .scrollIndicators(.hidden)
        }
        .safeAreaInset(edge: .bottom) {
            startButton
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.light)
        .onAppear {
            viewModel.loadDecks()
            selectedDeckIDs = Set(viewModel.decks.map(\.id))
        }
    }

    private var header: some View {
        DoodlePanel(background: GameMode.teamVsTeam.accentColor) {
            VStack(alignment: .leading, spacing: 14) {
                Label(GameMode.teamVsTeam.purpose.uppercased(), systemImage: GameMode.teamVsTeam.symbolName)
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink.opacity(0.64))

                Text(GameMode.teamVsTeam.title)
                    .font(.system(size: 40, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink)

                Text(GameMode.teamVsTeam.description)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink.opacity(0.68))
            }
            .padding(22)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var roundsPicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Number of Rounds")
                .font(.system(size: 25, weight: .black, design: .rounded))
                .foregroundStyle(AppTheme.Colors.ink)

            HStack(spacing: 16) {
                ForEach([1, 3, 5, 7], id: \.self) { roundCount in
                    Button {
                        selectedRounds = roundCount
                    } label: {
                        Text("\(roundCount)")
                            .font(.system(size: 22, weight: .black, design: .rounded))
                            .foregroundStyle(selectedRounds == roundCount ? .white : AppTheme.Colors.ink)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(
                                selectedRounds == roundCount ? GameMode.teamVsTeam.accentColor : AppTheme.Colors.paperBright
                            )
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card))
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.Radius.card)
                                    .stroke(AppTheme.Colors.ink, lineWidth: selectedRounds == roundCount ? 0 : 3)
                            )
                    }
                    .buttonStyle(DoodlePressStyle(rotation: 0))
                }
            }
        }
    }

    private var selectionControls: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Choose your decks")
                    .font(.system(size: 25, weight: .black, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .foregroundStyle(AppTheme.Colors.ink)

                Text("\(selectedDeckIDs.count) of \(viewModel.decks.count) selected")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink.opacity(0.56))
            }

            Spacer(minLength: 8)

            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    toggleAllDecks()
                }
            } label: {
                ZStack {
                    VStack(spacing: 4) {
                        Image(systemName: "checkmark.square.fill")
                            .font(.system(size: 32, weight: .black))
                        Text("SELECT ALL")
                            .font(.system(size: 10, weight: .black, design: .rounded))
                    }
                    .hidden()

                    VStack(spacing: 4) {
                        Image(systemName: allDecksSelected ? "checkmark.square.fill" : "square")
                            .font(.system(size: 32, weight: .black))
                            .foregroundStyle(allDecksSelected ? GameMode.teamVsTeam.accentColor : AppTheme.Colors.ink.opacity(0.25))

                        Text(allDecksSelected ? "UNSELECT" : "SELECT ALL")
                            .font(.system(size: 10, weight: .black, design: .rounded))
                            .foregroundStyle(AppTheme.Colors.ink.opacity(allDecksSelected ? 0.6 : 0.4))
                    }
                }
            }
            .buttonStyle(DoodlePressStyle(rotation: 0))
        }
    }

    private func deckSection(title: String, decks: [Deck]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundStyle(AppTheme.Colors.ink)

            ForEach(decks) { deck in
                deckToggle(deck)
            }
        }
    }

    private func deckToggle(_ deck: Deck) -> some View {
        Button {
            if selectedDeckIDs.contains(deck.id) {
                selectedDeckIDs.remove(deck.id)
            } else {
                selectedDeckIDs.insert(deck.id)
            }
        } label: {
            HStack(spacing: 14) {
                Image(systemName: deck.symbolName)
                    .font(.system(size: 20, weight: .black))
                    .foregroundStyle(AppTheme.Colors.ink)
                    .frame(width: 44, height: 44)
                    .background(deck.color.displayColor, in: Circle())
                    .overlay(Circle().stroke(AppTheme.Colors.ink, lineWidth: 3))

                VStack(alignment: .leading, spacing: 3) {
                    Text(deck.name)
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.ink)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)

                    Text("\(deck.cards.count) cards")
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.ink.opacity(0.5))
                }

                Spacer(minLength: 8)

                Image(systemName: selectedDeckIDs.contains(deck.id) ? "checkmark.square.fill" : "square")
                    .font(.system(size: 26, weight: .black))
                    .foregroundStyle(selectedDeckIDs.contains(deck.id) ? GameMode.teamVsTeam.accentColor : AppTheme.Colors.ink.opacity(0.42))
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .frame(height: 72)
            .background {
                DoodlePanelBackground(background: AppTheme.Colors.paperBright, cornerRadius: AppTheme.Radius.card)
            }
        }
        .buttonStyle(DoodlePressStyle(rotation: 0))
    }

    private var startButton: some View {
        DoodleActionButton(
            title: selectedDeckIDs.isEmpty ? "Select at least one deck" : "Start Match",
            symbol: "play.fill",
            accent: selectedDeckIDs.isEmpty ? AppTheme.Colors.gray.opacity(0.42) : GameMode.teamVsTeam.accentColor
        ) {
            startMatch()
        }
        .disabled(selectedDeckIDs.isEmpty)
        .accessibilityIdentifier("teamMatchStartButton")
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(AppTheme.Colors.paper.opacity(0.96))
    }

    private var allDecksSelected: Bool {
        !viewModel.decks.isEmpty && selectedDeckIDs.count == viewModel.decks.count
    }

    private func toggleAllDecks() {
        if allDecksSelected {
            selectedDeckIDs.removeAll()
        } else {
            selectedDeckIDs = Set(viewModel.decks.map(\.id))
        }
    }

    private func startMatch() {
        let selectedDecks = viewModel.decks.filter { selectedDeckIDs.contains($0.id) }
        guard !selectedDecks.isEmpty else { return }

        let state = TeamMatchState(
            sourceDecks: selectedDecks,
            totalRounds: selectedRounds,
            duration: settings.defaultDuration
        )

        router.activeTeamMatch = state
        router.open(.teamMatchLobby(state: state))
    }

    private func loadError(message: String) -> some View {
        DoodlePanel {
            VStack(alignment: .leading, spacing: 14) {
                Text("Decks could not load")
                    .font(.system(size: 22, weight: .black, design: .rounded))

                Text(message)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink.opacity(0.6))

                DoodleActionButton(
                    title: "Try again",
                    symbol: "arrow.clockwise",
                    accent: GameMode.teamVsTeam.accentColor
                ) {
                    viewModel.loadDecks()
                    selectedDeckIDs = Set(viewModel.decks.map(\.id))
                }
            }
            .padding(18)
        }
    }
}
