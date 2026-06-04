import SwiftUI

enum AppRoute: Hashable {
    case settings
    case deckEditor
    case gameSetup(deck: Deck)
    case results(deck: Deck)
}

struct ActiveGame: Identifiable, Equatable {
    let id = UUID()
    let deck: Deck
}

@MainActor
final class AppRouter: ObservableObject {
    @Published var path = NavigationPath()
    @Published var activeGame: ActiveGame?

    private var pendingResultsDeck: Deck?

    func open(_ route: AppRoute) {
        path.append(route)
    }

    func startGame(deck: Deck) {
        activeGame = ActiveGame(deck: deck)
    }

    func finishGame(deck: Deck) {
        pendingResultsDeck = deck
        activeGame = nil
    }

    func exitGame() {
        pendingResultsDeck = nil
        activeGame = nil
        path = NavigationPath()
    }

    func handleGameDismissal() {
        guard let deck = pendingResultsDeck else { return }

        pendingResultsDeck = nil
        path.append(AppRoute.results(deck: deck))
    }

    func goHome() {
        path = NavigationPath()
    }
}

struct AppShellView: View {
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        NavigationStack(path: $router.path) {
            HomeView()
                .navigationDestination(for: AppRoute.self) { route in
                    destination(for: route)
                }
        }
        .fullScreenCover(item: $router.activeGame, onDismiss: router.handleGameDismissal) { game in
            GameView(
                deckName: game.deck.name,
                onEndRound: { router.finishGame(deck: game.deck) },
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
        case let .gameSetup(deck):
            GameSetupView(
                deckName: deck.name,
                onStartRound: { router.startGame(deck: deck) }
            )
        case let .results(deck):
            ResultsView(
                deckName: deck.name,
                onPlayAgain: { router.startGame(deck: deck) },
                onChooseDeck: router.goHome
            )
        }
    }
}
