import SwiftUI

enum AppRoute: Hashable {
    case settings
    case onboarding
    case deckEditor(isEmoji: Bool = false)
    case myDecks
    case customDeckDetail(deck: Deck, mode: GameMode, fromMyDecks: Bool = false)
    case modeDeckSelection(mode: GameMode)
    case pasteAndPlay
    case mixAndMatch
    case wikipediaMode
    case teamMatchSelection
    case teamMatchLobby(state: TeamMatchState)
    case teamMatchResults(state: TeamMatchState)
    case results(result: RoundResult)
    case buyMeACoffee
}

struct ActiveGame: Identifiable, Equatable {
    let id = UUID()
    let configuration: GameConfiguration
}

@MainActor
final class AppRouter: ObservableObject {
    @Published var path = NavigationPath()
    @Published var activeGame: ActiveGame?
    @Published var activeTeamMatch: TeamMatchState?

    private var orientationTransitionTask: Task<Void, Never>?

    func open(_ route: AppRoute) {
        path.append(route)
    }

    func openImmediately(_ route: AppRoute) {
        var transaction = Transaction()
        transaction.animation = nil

        withTransaction(transaction) {
            path.append(route)
        }
    }

    func replaceCurrent(with route: AppRoute) {
        if !path.isEmpty {
            path.removeLast()
        }
        path.append(route)
    }

    func startGame(configuration: GameConfiguration) {
        orientationTransitionTask?.cancel()
        activeGame = ActiveGame(configuration: configuration)
        OrientationController.shared.useGameplayLandscape()
    }

    func startGame(deck: Deck, duration: Int) {
        startGame(configuration: .normal(deck: deck, duration: duration))
    }

    func startGame(mode: GameMode, deck: Deck, settings: GameSettings) {
        switch mode {
        case .normal:
            startGame(configuration: .normal(deck: deck, duration: settings.defaultDuration))
        case .emoji:
            startGame(configuration: .emoji(deck: deck, duration: settings.defaultDuration))
        case .infinite:
            startGame(configuration: .infinite(deck: deck))
        case .pasteAndPlay:
            startGame(configuration: .pasteAndPlay(deck: deck, duration: settings.defaultDuration))
        case .mixAndMatch:
            startGame(
                configuration: .mixAndMatch(
                    deck: deck,
                    duration: settings.defaultDuration,
                    sourceDeckIDs: [deck.id]
                )
            )
        case .wikipedia:
            startGame(configuration: .wikipedia(deck: deck, duration: settings.defaultDuration))
        case .teamVsTeam:
            startGame(configuration: .teamVsTeam(deck: deck, duration: settings.defaultDuration))
        }
    }

    func finishGame(result: RoundResult) {
        dismissGameAfterPortraitTransition {
            if let matchState = self.activeTeamMatch, result.mode == .teamVsTeam {
                matchState.recordResult(result)
                if matchState.isGameOver {
                    self.path.append(AppRoute.teamMatchResults(state: matchState))
                } else {
                    self.path.append(AppRoute.teamMatchLobby(state: matchState))
                }
            } else {
                self.path.append(AppRoute.results(result: result))
            }
        }
    }

    func exitGame() {
        dismissGameAfterPortraitTransition {
            self.activeTeamMatch = nil
            self.path = NavigationPath()
        }
    }

    func goHome() {
        OrientationController.shared.useMenuPortrait()
        activeTeamMatch = nil
        path = NavigationPath()
    }

    func dismissOnboarding(completion: @escaping @MainActor () -> Void) {
        OrientationController.shared.useMenuPortrait()
        orientationTransitionTask?.cancel()
        orientationTransitionTask = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(360))
            guard !Task.isCancelled else { return }
            completion()
        }
    }

    func goBack() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    private func dismissGameAfterPortraitTransition(afterDismiss: @escaping @MainActor () -> Void) {
        OrientationController.shared.useMenuPortrait()
        orientationTransitionTask?.cancel()
        orientationTransitionTask = Task { @MainActor [weak self] in
            try? await Task.sleep(for: .milliseconds(360))
            guard !Task.isCancelled else { return }
            self?.activeGame = nil
            afterDismiss()
        }
    }
}

struct AppShellView: View {
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var settingsViewModel: SettingsViewModel
    @AppStorage("CharadesTiltGuess.HasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some View {
        ZStack {
            NavigationStack(path: $router.path) {
                HomeView()
                    .navigationDestination(for: AppRoute.self) { route in
                        destination(for: route)
                    }
            }

            if let game = router.activeGame {
                GameView(
                    configuration: game.configuration,
                    settings: settingsViewModel.settings,
                    onRoundFinished: router.finishGame,
                    onExit: router.exitGame
                )
                .ignoresSafeArea()
                .zIndex(1)
                .transition(.opacity)
            }
        }
        .fullScreenCover(isPresented: onboardingBinding) {
            OnboardingCoordinatorView {
                router.dismissOnboarding {
                    hasSeenOnboarding = true
                }
            }
        }
    }

    private var onboardingBinding: Binding<Bool> {
        Binding(
            get: { !hasSeenOnboarding },
            set: { isPresented in
                if !isPresented {
                    hasSeenOnboarding = true
                }
            }
        )
    }

    @ViewBuilder
    private func destination(for route: AppRoute) -> some View {
        switch route {
        case .settings:
            SettingsView()
        case .onboarding:
            OnboardingCoordinatorView {
                router.dismissOnboarding {
                    router.goBack()
                }
            }
        case let .deckEditor(isEmoji):
            DeckEditorView(isEmoji: isEmoji)
        case .myDecks:
            MyDecksListView()
        case let .customDeckDetail(deck, mode, fromMyDecks):
            CustomDeckDetailView(deck: deck, mode: mode, fromMyDecks: fromMyDecks)
        case let .modeDeckSelection(mode):
            ModeDeckSelectionView(mode: mode)
        case .pasteAndPlay:
            PasteAndPlayView(settings: settingsViewModel.settings) { configuration in
                router.startGame(configuration: configuration)
            }
        case .mixAndMatch:
            MixAndMatchSelectionView(settings: settingsViewModel.settings) { configuration in
                router.startGame(configuration: configuration)
            }
        case .wikipediaMode:
            WikipediaModeView(settings: settingsViewModel.settings) { configuration in
                router.startGame(configuration: configuration)
            }
        case .teamMatchSelection:
            TeamMatchSelectionView(settings: settingsViewModel.settings)
        case let .teamMatchLobby(state):
            TeamMatchLobbyView(state: state)
        case let .teamMatchResults(state):
            TeamMatchResultsView(state: state)
        case let .results(result):
            ResultsView(
                result: result,
                onPlayAgain: {
                    router.replay(result: result)
                },
                onChooseDeck: router.goHome
            )
        case .buyMeACoffee:
            BuyMeACoffeeView()
        }
    }
}

private extension AppRouter {
    func replay(result: RoundResult) {
        if result.mode == .mixAndMatch {
            let decks = (try? DeckStore().loadDecks()) ?? [result.deck]
            let selectedDecks = decks.filter { result.sourceDeckIDs.contains($0.id) }
            let sourceDecks = selectedDecks.isEmpty ? decks : selectedDecks
            let deck = MixAndMatchDeckFactory().makeDeck(from: sourceDecks) ?? result.deck
            startGame(
                configuration: .mixAndMatch(
                    deck: deck,
                    duration: result.duration,
                    sourceDeckIDs: result.sourceDeckIDs
                )
            )
            return
        }

        startGame(
            configuration: GameConfiguration(
                mode: result.mode,
                deck: result.deck,
                duration: result.mode == .infinite ? nil : result.duration,
                hiddenDuration: nil,
                isTemporaryDeck: result.deck.type == .custom && result.deck.id.hasPrefix("temp-"),
                sourceDeckIDs: result.sourceDeckIDs
            )
        )
    }
}
