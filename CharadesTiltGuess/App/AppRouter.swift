import SwiftUI

enum AppRoute: Hashable {
    case settings
    case deckEditor
    case customDeckDetail(deck: Deck)
    case gameSetup(deck: Deck)
    case results(result: RoundResult)
}

struct ActiveGame: Identifiable, Equatable {
    let id = UUID()
    let deck: Deck
    let duration: Int
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

    func startGame(deck: Deck, duration: Int) {
        orientationTransitionTask?.cancel()
        activeGame = ActiveGame(deck: deck, duration: duration)
        OrientationController.shared.useGameplayLandscape()
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
                    deck: game.deck,
                    duration: game.duration,
                    settings: settingsViewModel.settings,
                    onRoundFinished: router.finishGame,
                    onExit: router.exitGame
                )
                .ignoresSafeArea()
                .zIndex(1)
                .transition(.opacity)
            }
        }
    }

    @ViewBuilder
    private func destination(for route: AppRoute) -> some View {
        switch route {
        case .settings:
            SettingsView()
        case .deckEditor:
            DeckEditorView()
        case let .customDeckDetail(deck):
            CustomDeckDetailView(deck: deck)
        case let .gameSetup(deck):
            GameSetupView(
                deck: deck,
                settings: settingsViewModel.settings,
                onStartRound: { duration in router.startGame(deck: deck, duration: duration) }
            )
        case let .results(result):
            ResultsView(
                result: result,
                onPlayAgain: { router.startGame(deck: result.deck, duration: result.duration) },
                onChooseDeck: router.goHome
            )
        }
    }
}
