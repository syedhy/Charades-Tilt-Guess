import SwiftUI

struct TeamMatchSelectionView: View {
    let settings: GameSettings

    enum SetupStep {
        case teamSetup
        case deckSelection
    }

    @EnvironmentObject private var router: AppRouter
    @StateObject private var viewModel = HomeViewModel()

    @State private var currentStep: SetupStep = .teamSetup
    @State private var numberOfTeams: Int = 2
    @State private var playersPerTeam: Int = 4
    @State private var isCustomPlayers: Bool = false
    @State private var selectedDeckIDs: Set<String> = []
    @State private var currentTeamPresets: [TeamInfo] = TeamInfo.randomPresets(count: 2)

    var body: some View {
        ZStack {
            DoodlePaperBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.roomy) {
                    if currentStep == .teamSetup {
                        header
                        teamsCountPicker
                            .padding(.bottom, 8)
                        playersPicker
                        teamsPreviewGrid
                    } else {
                        deckSelectionHeader
                        selectionControls

                        if !standardCustomDecks.isEmpty {
                            deckSection(title: "Custom Decks", decks: standardCustomDecks)
                        }

                        deckSection(title: "Built-In Decks", decks: standardDefaultDecks)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 4)
                .padding(.bottom, 96)
            }
            .scrollIndicators(.hidden)
        }
        .safeAreaInset(edge: .bottom) {
            bottomActionButton
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.light)
        .onAppear {
            viewModel.loadDecks()
            selectedDeckIDs = Set(allStandardDecks.map(\.id))
        }
    }

    private var header: some View {
        DoodlePanel(background: GameMode.teamVsTeam.accentColor) {
            VStack(alignment: .leading, spacing: 8) {
                Label("STEP 1 OF 2 • TEAM SETUP", systemImage: GameMode.teamVsTeam.symbolName)
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink.opacity(0.64))

                Text(GameMode.teamVsTeam.title)
                    .font(.system(size: 40, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink)
            }
            .padding(22)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var teamsCountPicker: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("How many teams?")
                .font(.system(size: 26, weight: .black, design: .rounded))
                .foregroundStyle(AppTheme.Colors.ink)

            HStack(spacing: 12) {
                ForEach([2, 3, 4, 5], id: \.self) { count in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            numberOfTeams = count
                            currentTeamPresets = TeamInfo.randomPresets(count: count)
                        }
                    } label: {
                        Text("\(count)")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundStyle(numberOfTeams == count ? .white : AppTheme.Colors.ink)
                            .frame(maxWidth: .infinity)
                            .frame(height: 64)
                            .background(
                                numberOfTeams == count ? GameMode.teamVsTeam.accentColor : AppTheme.Colors.paperBright
                            )
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.Radius.card, style: .continuous)
                                    .stroke(AppTheme.Colors.ink, lineWidth: numberOfTeams == count ? 3.5 : 3)
                            )
                    }
                    .buttonStyle(DoodlePressStyle(rotation: 0))
                }
            }
        }
    }

    private var playersPicker: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Players per team")
                .font(.system(size: 26, weight: .black, design: .rounded))
                .foregroundStyle(AppTheme.Colors.ink)

            HStack(spacing: 10) {
                ForEach([1, 2, 3, 4, 5], id: \.self) { count in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            playersPerTeam = count
                            isCustomPlayers = false
                        }
                    } label: {
                        Text("\(count)")
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundStyle((!isCustomPlayers && playersPerTeam == count) ? .white : AppTheme.Colors.ink)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                (!isCustomPlayers && playersPerTeam == count) ? GameMode.teamVsTeam.accentColor : AppTheme.Colors.paperBright
                            )
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.Radius.card, style: .continuous)
                                    .stroke(AppTheme.Colors.ink, lineWidth: (!isCustomPlayers && playersPerTeam == count) ? 3.5 : 3)
                            )
                    }
                    .buttonStyle(DoodlePressStyle(rotation: 0))
                }
            }

            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isCustomPlayers.toggle()
                    if isCustomPlayers && playersPerTeam <= 5 {
                        playersPerTeam = 6
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 16, weight: .black))
                    Text(isCustomPlayers || playersPerTeam > 5 ? "Custom Player Count (\(playersPerTeam))" : "Custom Player Count")
                        .font(.system(size: 16, weight: .black, design: .rounded))
                }
                .foregroundStyle((isCustomPlayers || playersPerTeam > 5) ? .white : AppTheme.Colors.ink)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    (isCustomPlayers || playersPerTeam > 5) ? GameMode.teamVsTeam.accentColor : AppTheme.Colors.paperBright
                )
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.Radius.card, style: .continuous)
                        .stroke(AppTheme.Colors.ink, lineWidth: (isCustomPlayers || playersPerTeam > 5) ? 3.5 : 3)
                )
            }
            .buttonStyle(DoodlePressStyle(rotation: 0))

            if isCustomPlayers || playersPerTeam > 5 {
                DoodlePanel(background: AppTheme.Colors.paperBright) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("CUSTOM PLAYER COUNT")
                                .font(.system(size: 12, weight: .black, design: .rounded))
                                .foregroundStyle(AppTheme.Colors.ink.opacity(0.55))

                            Spacer()

                            Text("\(playersPerTeam) Players / Team")
                                .font(.system(size: 18, weight: .black, design: .rounded))
                                .foregroundStyle(GameMode.teamVsTeam.accentColor)
                        }

                        Slider(
                            value: Binding(
                                get: { Double(playersPerTeam) },
                                set: { playersPerTeam = Int($0) }
                            ),
                            in: 1...15,
                            step: 1
                        )
                        .tint(GameMode.teamVsTeam.accentColor)

                        HStack {
                            Text("1 player")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundStyle(AppTheme.Colors.ink.opacity(0.5))
                            Spacer()
                            Text("15 players max")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundStyle(AppTheme.Colors.ink.opacity(0.5))
                        }
                    }
                    .padding(16)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
    }

    private var teamsPreviewGrid: some View {
        DoodlePanel(background: AppTheme.Colors.paperBright) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("TEAMS IN MATCH")
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.ink.opacity(0.55))

                    Spacer()

                    Text("\(numberOfTeams * playersPerTeam) Total Turns")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.ink.opacity(0.55))
                }

                let columns = [
                    GridItem(.flexible(), spacing: 10),
                    GridItem(.flexible(), spacing: 10)
                ]

                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(currentTeamPresets) { team in
                        HStack(spacing: 10) {
                            Text(team.icon)
                                .font(.system(size: 26))

                            Text(team.name)
                                .font(.system(size: 18, weight: .black, design: .rounded))
                                .foregroundStyle(AppTheme.Colors.ink)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)

                            Spacer(minLength: 0)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(team.color.displayColor.opacity(0.35), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(AppTheme.Colors.ink, lineWidth: 2.5)
                        )
                    }
                }
            }
            .padding(18)
        }
    }

    private var deckSelectionHeader: some View {
        DoodlePanel(background: GameMode.teamVsTeam.accentColor) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Button {
                        withAnimation {
                            currentStep = .teamSetup
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Edit Teams")
                        }
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.ink)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(AppTheme.Colors.paperBright, in: Capsule())
                        .overlay(Capsule().stroke(AppTheme.Colors.ink, lineWidth: 2))
                    }

                    Spacer()

                    Text("STEP 2 OF 2")
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.ink.opacity(0.6))
                }

                Text("Choose Decks")
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink)

                Text("\(numberOfTeams) Teams • \(playersPerTeam) Players each (\(numberOfTeams * playersPerTeam) Total Turns)")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink.opacity(0.7))
            }
            .padding(22)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var selectionControls: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Select Deck Pool")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink)

                Text("\(selectedDeckIDs.count) of \(allStandardDecks.count) selected")
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

    private var bottomActionButton: some View {
        Group {
            if currentStep == .teamSetup {
                DoodleActionButton(
                    title: "Next: Select Decks",
                    symbol: "arrow.right",
                    accent: GameMode.teamVsTeam.accentColor
                ) {
                    withAnimation {
                        currentStep = .deckSelection
                    }
                }
            } else {
                DoodleActionButton(
                    title: selectedDeckIDs.isEmpty ? "Select at least one deck" : "Start Match",
                    symbol: "play.fill",
                    accent: selectedDeckIDs.isEmpty ? AppTheme.Colors.gray.opacity(0.42) : GameMode.teamVsTeam.accentColor
                ) {
                    startMatch()
                }
                .disabled(selectedDeckIDs.isEmpty)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(AppTheme.Colors.paper.opacity(0.96))
    }

    private var standardCustomDecks: [Deck] {
        viewModel.customDecks.filter { !$0.isEmojiDeck }
    }

    private var standardDefaultDecks: [Deck] {
        viewModel.defaultDecks.filter { !$0.isEmojiDeck }
    }

    private var allStandardDecks: [Deck] {
        standardCustomDecks + standardDefaultDecks
    }

    private var allDecksSelected: Bool {
        !allStandardDecks.isEmpty && selectedDeckIDs.count == allStandardDecks.count
    }

    private func toggleAllDecks() {
        if allDecksSelected {
            selectedDeckIDs.removeAll()
        } else {
            selectedDeckIDs = Set(allStandardDecks.map(\.id))
        }
    }

    private func startMatch() {
        let selectedDecks = allStandardDecks.filter { selectedDeckIDs.contains($0.id) }
        guard !selectedDecks.isEmpty else { return }

        let state = TeamMatchState(
            numberOfTeams: numberOfTeams,
            playersPerTeam: playersPerTeam,
            sourceDecks: selectedDecks,
            duration: settings.defaultDuration,
            customTeams: currentTeamPresets
        )

        router.activeTeamMatch = state
        router.open(.teamMatchLobby(state: state))
    }
}
