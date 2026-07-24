import SwiftUI

struct RandomModeView: View {
    let settings: GameSettings
    let onStart: (GameConfiguration) -> Void

    @EnvironmentObject private var router: AppRouter
    @StateObject private var viewModel = HomeViewModel()

    @State private var includeDefaultDecks = true
    @State private var includeCustomDecks = true

    @State private var rolledMode: GameMode = .normal
    @State private var rolledDecks: [Deck] = []
    @State private var rolledPlayersPerTeam: Int = 4
    @State private var spinDegree: Double = 0

    var body: some View {
        ZStack {
            DoodlePaperBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.roomy) {
                    header
                    filterPanel
                    rolledSetupCard
                }
                .padding(.horizontal, 24)
                .padding(.top, 4)
                .padding(.bottom, 110)
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
            reroll()
        }
    }

    private var header: some View {
        DoodlePanel(background: GameMode.randomMode.accentColor) {
            VStack(alignment: .leading, spacing: 8) {
                Label(GameMode.randomMode.purpose.uppercased(), systemImage: GameMode.randomMode.symbolName)
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink.opacity(0.64))

                Text(GameMode.randomMode.title)
                    .font(.system(size: 40, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink)
            }
            .padding(22)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var filterPanel: some View {
        DoodlePanel(background: AppTheme.Colors.paperBright) {
            VStack(alignment: .leading, spacing: 14) {
                Text("RANDOM POOL OPTIONS")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink.opacity(0.6))

                Toggle(isOn: $includeDefaultDecks) {
                    Label("Include Built-In Decks", systemImage: "rectangle.stack.fill")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.ink)
                }
                .tint(GameMode.randomMode.accentColor)

                Toggle(isOn: $includeCustomDecks) {
                    Label("Include Custom Decks", systemImage: "person.crop.square.fill")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.ink)
                }
                .tint(GameMode.randomMode.accentColor)
            }
            .padding(20)
        }
        .onChange(of: includeDefaultDecks) { _, _ in ensureFiltersAndReroll() }
        .onChange(of: includeCustomDecks) { _, _ in ensureFiltersAndReroll() }
    }

    private var rolledSetupCard: some View {
        DoodlePanel(background: AppTheme.Colors.paperBright) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("MODE SELECTED")
                            .font(.system(size: 12, weight: .black, design: .rounded))
                            .foregroundStyle(AppTheme.Colors.ink.opacity(0.55))

                        HStack(spacing: 8) {
                            Image(systemName: rolledMode.symbolName)
                                .font(.system(size: 22, weight: .black))
                                .foregroundStyle(rolledMode.accentColor)

                            Text(rolledMode.title)
                                .font(.system(size: 26, weight: .black, design: .rounded))
                                .foregroundStyle(AppTheme.Colors.ink)
                        }
                    }

                    Spacer()

                    DoodleIconButton(
                        symbol: "die.face.5.fill",
                        accent: GameMode.randomMode.accentColor,
                        size: 54,
                        accessibilityLabel: "Refresh random setup"
                    ) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                            spinDegree += 360
                            reroll()
                        }
                    }
                    .rotationEffect(.degrees(spinDegree))
                }

                Divider()

                if !rolledDecks.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("SELECTED DECKS (\(rolledDecks.count))")
                                .font(.system(size: 12, weight: .black, design: .rounded))
                                .foregroundStyle(AppTheme.Colors.ink.opacity(0.55))

                            Spacer()

                            Text("\(totalCardsCount) cards total")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundStyle(AppTheme.Colors.ink.opacity(0.55))
                        }

                        ForEach(rolledDecks) { deck in
                            compactDeckRow(deck)
                        }
                    }
                } else {
                    Text("No decks match your filter options. Enable built-in or custom decks above.")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.coral)
                        .padding(12)
                }
            }
            .padding(20)
        }
    }

    private func compactDeckRow(_ deck: Deck) -> some View {
        HStack(spacing: 12) {
            Image(systemName: deck.symbolName)
                .font(.system(size: 16, weight: .black))
                .foregroundStyle(AppTheme.Colors.ink)
                .frame(width: 38, height: 38)
                .background(deck.color.displayColor, in: Circle())
                .overlay(Circle().stroke(AppTheme.Colors.ink, lineWidth: 2.5))

            Text(deck.name)
                .font(.system(size: 17, weight: .black, design: .rounded))
                .foregroundStyle(AppTheme.Colors.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Spacer(minLength: 8)

            Text("\(deck.cards.count) cards")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.Colors.ink.opacity(0.55))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(AppTheme.Colors.paper, in: RoundedRectangle(cornerRadius: AppTheme.Radius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.card, style: .continuous)
                .stroke(AppTheme.Colors.ink, lineWidth: 2)
        )
    }

    private var startButton: some View {
        DoodleActionButton(
            title: rolledDecks.isEmpty ? "Enable a deck pool" : "Start Game",
            symbol: "play.fill",
            accent: rolledDecks.isEmpty ? AppTheme.Colors.gray.opacity(0.42) : GameMode.randomMode.accentColor
        ) {
            startGame()
        }
        .disabled(rolledDecks.isEmpty)
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(AppTheme.Colors.paper.opacity(0.96))
    }

    private var totalCardsCount: Int {
        rolledDecks.reduce(0) { $0 + $1.cards.count }
    }

    private func ensureFiltersAndReroll() {
        if !includeDefaultDecks && !includeCustomDecks {
            includeDefaultDecks = true
        }
        reroll()
    }

    private func reroll() {
        var availableDecks: [Deck] = []
        if includeDefaultDecks {
            availableDecks.append(contentsOf: viewModel.defaultDecks)
        }
        if includeCustomDecks {
            availableDecks.append(contentsOf: viewModel.customDecks)
        }

        guard !availableDecks.isEmpty else {
            rolledDecks = []
            return
        }

        let playableModes: [GameMode] = [.normal, .emoji, .infinite, .teamVsTeam]
        let newMode = playableModes.randomElement() ?? .normal
        rolledMode = newMode

        let candidateDecks: [Deck]
        if newMode == .emoji {
            candidateDecks = availableDecks.filter { $0.isEmojiDeck }
        } else {
            candidateDecks = availableDecks.filter { !$0.isEmojiDeck }
        }

        let finalPool = candidateDecks.isEmpty ? availableDecks : candidateDecks
        let deckCountToPick = min(Int.random(in: 1...5), finalPool.count)
        rolledDecks = Array(finalPool.shuffled().prefix(deckCountToPick))
        rolledPlayersPerTeam = Int.random(in: 2...5)
    }

    private func startGame() {
        guard !rolledDecks.isEmpty else { return }

        if rolledMode == .teamVsTeam {
            let state = TeamMatchState(
                sourceDecks: rolledDecks,
                totalRounds: rolledPlayersPerTeam,
                duration: settings.defaultDuration
            )
            router.activeTeamMatch = state
            router.open(.teamMatchLobby(state: state))
            return
        }

        let finalDeck: Deck
        if rolledDecks.count == 1 {
            finalDeck = rolledDecks[0]
        } else {
            var combinedWords: [GameWord] = []
            for deck in rolledDecks {
                combinedWords.append(contentsOf: deck.cards)
            }
            finalDeck = Deck(
                id: "random-mix",
                name: rolledDecks.map(\.name).joined(separator: " + "),
                description: "Randomly combined deck mix",
                cards: combinedWords.shuffled(),
                type: .custom,
                color: .coral,
                symbolName: "die.face.5.fill",
                isEmoji: rolledMode == .emoji
            )
        }

        let config = GameConfiguration(
            mode: rolledMode,
            deck: finalDeck,
            duration: rolledMode == .infinite ? nil : settings.defaultDuration
        )
        onStart(config)
    }
}
