import SwiftUI

struct ModeDeckSelectionView: View {
    @EnvironmentObject private var router: AppRouter
    @StateObject private var viewModel = HomeViewModel()

    let mode: GameMode

    var body: some View {
        ZStack {
            DoodlePaperBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.roomy) {
                    header

                    if let loadErrorMessage = viewModel.loadErrorMessage {
                        deckLoadError(message: loadErrorMessage)
                    } else {
                        deckSections
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 4)
                .padding(.bottom, 32)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.light)
        .onAppear {
            viewModel.loadDecks()
        }
    }

    private var header: some View {
        DoodlePanel(background: mode.accentColor) {
            VStack(alignment: .leading, spacing: 14) {
                Label(mode.purpose.uppercased(), systemImage: mode.symbolName)
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink.opacity(0.64))

                Text("Choose a deck")
                    .font(.system(size: 40, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink)

                Text(mode.description)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink.opacity(0.68))
            }
            .padding(22)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var deckSections: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.roomy) {
            if !viewModel.customDecks.isEmpty && mode != .kids {
                deckSection(title: "Custom Decks", decks: viewModel.customDecks)
            }

            deckSection(title: "Built-In Decks", decks: mode == .kids ? viewModel.defaultDecks.filter { $0.id.hasPrefix("kids-") } : viewModel.defaultDecks.filter { !$0.id.hasPrefix("kids-") })

            if mode != .kids {
                DoodleActionButton(title: "Add custom deck", symbol: "plus", accent: AppTheme.Colors.paperBright) {
                    router.openImmediately(.deckEditor)
                }
            }
        }
    }

    private func deckSection(title: String, decks: [Deck]) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.system(size: 25, weight: .black, design: .rounded))
                .foregroundStyle(AppTheme.Colors.ink)

            if decks.isEmpty {
                DoodlePanel {
                    Text(title == "Custom Decks" ? "Create a deck to see it here." : "Built-in decks could not be loaded.")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.ink.opacity(0.58))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(18)
                }
            } else {
                DeckGridView(decks: decks) { deck in
                    router.open(.customDeckDetail(deck: deck, mode: mode))
                }
            }
        }
    }

    private func deckLoadError(message: String) -> some View {
        DoodlePanel(cornerRadius: AppTheme.Radius.card) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.standard) {
                Text("Decks took a wrong turn")
                    .font(.system(size: 19, weight: .black, design: .rounded))

                Text(message)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink.opacity(0.62))

                DoodleActionButton(
                    title: "Try loading again",
                    symbol: "arrow.clockwise",
                    accent: AppTheme.Colors.yellow,
                    action: viewModel.loadDecks
                )
            }
            .foregroundStyle(AppTheme.Colors.ink)
            .padding(AppTheme.Spacing.standard)
        }
    }
}

struct MixAndMatchSelectionView: View {
    let settings: GameSettings
    let onStart: (GameConfiguration) -> Void

    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedDeckIDs: Set<String> = []

    var body: some View {
        ZStack {
            DoodlePaperBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.roomy) {
                    header

                    if let loadErrorMessage = viewModel.loadErrorMessage {
                        loadError(message: loadErrorMessage)
                    } else {
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
        DoodlePanel(background: GameMode.mixAndMatch.accentColor) {
            VStack(alignment: .leading, spacing: 14) {
                Label(GameMode.mixAndMatch.purpose.uppercased(), systemImage: GameMode.mixAndMatch.symbolName)
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink.opacity(0.64))

                Text(GameMode.mixAndMatch.title)
                    .font(.system(size: 40, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink)

                Text(GameMode.mixAndMatch.description)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink.opacity(0.68))
            }
            .padding(22)
            .frame(maxWidth: .infinity, alignment: .leading)
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
                    // Hidden max-width layout to keep button size completely fixed
                    VStack(spacing: 4) {
                        Image(systemName: "checkmark.square.fill")
                            .font(.system(size: 32, weight: .black))
                        Text("SELECT ALL")
                            .font(.system(size: 10, weight: .black, design: .rounded))
                    }
                    .hidden()

                    // Visible layout
                    VStack(spacing: 4) {
                        Image(systemName: allDecksSelected ? "checkmark.square.fill" : "square")
                            .font(.system(size: 32, weight: .black))
                            .foregroundStyle(allDecksSelected ? GameMode.mixAndMatch.accentColor : AppTheme.Colors.ink.opacity(0.25))

                        Text(allDecksSelected ? "UNSELECT" : "SELECT ALL")
                            .font(.system(size: 10, weight: .black, design: .rounded))
                            .foregroundStyle(AppTheme.Colors.ink.opacity(allDecksSelected ? 0.6 : 0.4))
                    }
                }
            }
            .buttonStyle(DoodlePressStyle(rotation: 0))
            .accessibilityIdentifier("mixAndMatchSelectAllButton")
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
                    .foregroundStyle(selectedDeckIDs.contains(deck.id) ? GameMode.mixAndMatch.accentColor : AppTheme.Colors.ink.opacity(0.42))
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .frame(height: 72)
            .background {
                DoodlePanelBackground(background: AppTheme.Colors.paperBright, cornerRadius: AppTheme.Radius.card)
            }
        }
        .buttonStyle(DoodlePressStyle(rotation: 0))
        .accessibilityIdentifier("mixAndMatchDeck-\(deck.id)")
    }

    private var startButton: some View {
        DoodleActionButton(
            title: selectedDeckIDs.isEmpty ? "Select at least one deck" : "Start Mix & Match",
            symbol: "play.fill",
            accent: selectedDeckIDs.isEmpty ? AppTheme.Colors.gray.opacity(0.42) : GameMode.mixAndMatch.accentColor,
            action: startGame
        )
        .disabled(selectedDeckIDs.isEmpty)
        .accessibilityIdentifier("mixAndMatchStartButton")
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

    private func startGame() {
        let selectedDecks = viewModel.decks.filter { selectedDeckIDs.contains($0.id) }
        guard let deck = MixAndMatchDeckFactory().makeDeck(from: selectedDecks) else { return }

        onStart(
            .mixAndMatch(
                deck: deck,
                duration: settings.defaultDuration,
                sourceDeckIDs: selectedDeckIDs
            )
        )
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
                    accent: GameMode.mixAndMatch.accentColor
                ) {
                    viewModel.loadDecks()
                    selectedDeckIDs = Set(viewModel.decks.map(\.id))
                }
            }
            .padding(18)
        }
    }
}

#Preview {
    NavigationStack {
        ModeDeckSelectionView(mode: .normal)
            .environmentObject(AppRouter())
    }
}
