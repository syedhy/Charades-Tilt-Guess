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

    private var pendingResult: RoundResult?

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
        OrientationController.shared.useGameplayLandscape()
        activeGame = ActiveGame(deck: deck, duration: duration)
    }

    func finishGame(result: RoundResult) {
        pendingResult = result
        activeGame = nil
        OrientationController.shared.useMenuPortrait()
    }

    func exitGame() {
        pendingResult = nil
        activeGame = nil
        OrientationController.shared.useMenuPortrait()
        path = NavigationPath()
    }

    func handleGameDismissal() {
        guard let result = pendingResult else { return }

        pendingResult = nil
        path.append(AppRoute.results(result: result))
    }

    func goHome() {
        OrientationController.shared.useMenuPortrait()
        path = NavigationPath()
    }

    func goBack() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
}

struct AppShellView: View {
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var settingsViewModel: SettingsViewModel

    var body: some View {
        NavigationStack(path: $router.path) {
            HomeView()
                .navigationDestination(for: AppRoute.self) { route in
                    destination(for: route)
                }
        }
        .fullScreenCover(item: $router.activeGame, onDismiss: router.handleGameDismissal) { game in
            GameView(
                deck: game.deck,
                duration: game.duration,
                settings: settingsViewModel.settings,
                onRoundFinished: router.finishGame,
                onExit: router.exitGame
            )
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
