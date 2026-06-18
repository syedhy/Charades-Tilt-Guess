import SwiftUI

enum AppRoute: Hashable {
    case settings
    case onboarding
    case deckEditor
    case customDeckDetail(deck: Deck, mode: GameMode)
    case modeDeckSelection(mode: GameMode)
    case gameSetup(mode: GameMode, deck: Deck)
    case pasteAndPlay
    case wikipediaMode
    case results(result: RoundResult)
}

struct ActiveGame: Identifiable, Equatable {
    let id = UUID()
    let configuration: GameConfiguration
}

@MainActor
final class AppRouter: ObservableObject {
    @Published var path = NavigationPath()
    @Published var activeGame: ActiveGame?

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

    func startGame(configuration: GameConfiguration) {
        orientationTransitionTask?.cancel()
        activeGame = ActiveGame(configuration: configuration)
        OrientationController.shared.useGameplayLandscape()
    }

    func startGame(deck: Deck, duration: Int) {
        startGame(configuration: .normal(deck: deck, duration: duration))
    }

    func finishGame(result: RoundResult) {
        dismissGameAfterPortraitTransition {
            self.path.append(AppRoute.results(result: result))
        }
    }

    func exitGame() {
        dismissGameAfterPortraitTransition {
            self.path = NavigationPath()
        }
    }

    func goHome() {
        OrientationController.shared.useMenuPortrait()
        path = NavigationPath()
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
            OnboardingView(isPresentedModally: true) {
                hasSeenOnboarding = true
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
            OnboardingView(isPresentedModally: false) {
                router.goBack()
            }
        case .deckEditor:
            DeckEditorView()
        case let .customDeckDetail(deck, mode):
            CustomDeckDetailView(deck: deck, mode: mode)
        case let .modeDeckSelection(mode):
            ModeDeckSelectionView(mode: mode)
        case let .gameSetup(mode, deck):
            GameSetupView(
                mode: mode,
                deck: deck,
                settings: settingsViewModel.settings,
                onStartRound: { configuration in router.startGame(configuration: configuration) }
            )
        case .pasteAndPlay:
            PasteAndPlayView(settings: settingsViewModel.settings) { configuration in
                router.startGame(configuration: configuration)
            }
        case .wikipediaMode:
            WikipediaModeView(settings: settingsViewModel.settings) { configuration in
                router.startGame(configuration: configuration)
            }
        case let .results(result):
            ResultsView(
                result: result,
                onPlayAgain: {
                    router.startGame(
                        configuration: GameConfiguration(
                            mode: result.mode,
                            deck: result.deck,
                            duration: result.mode == .infinite || result.mode == .hotPotato ? nil : result.duration,
                            hiddenDuration: result.mode == .hotPotato ? result.duration : nil,
                            isTemporaryDeck: result.deck.type == .custom && result.deck.id.hasPrefix("temp-")
                        )
                    )
                },
                onChooseDeck: router.goHome
            )
        }
    }
}
