import SwiftUI

enum AppRoute: Hashable {
    case settings
    case deckEditor
    case gameSetup(deckName: String)
    case results(deckName: String)
}

struct ActiveGame: Identifiable, Equatable {
    let id = UUID()
    let deckName: String
}

@MainActor
final class AppRouter: ObservableObject {
    @Published var path = NavigationPath()
    @Published var activeGame: ActiveGame?

    private var pendingResultsDeckName: String?

    func open(_ route: AppRoute) {
        path.append(route)
    }

    func startGame(deckName: String) {
        activeGame = ActiveGame(deckName: deckName)
    }

    func finishGame(deckName: String) {
        pendingResultsDeckName = deckName
        activeGame = nil
    }

    func exitGame() {
        pendingResultsDeckName = nil
        activeGame = nil
        path = NavigationPath()
    }

    func handleGameDismissal() {
        guard let deckName = pendingResultsDeckName else { return }

        pendingResultsDeckName = nil
        path.append(AppRoute.results(deckName: deckName))
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
                deckName: game.deckName,
                onEndRound: { router.finishGame(deckName: game.deckName) },
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
        case let .gameSetup(deckName):
            GameSetupView(
                deckName: deckName,
                onStartRound: { router.startGame(deckName: deckName) }
            )
        case let .results(deckName):
            ResultsView(
                deckName: deckName,
                onPlayAgain: { router.startGame(deckName: deckName) },
                onChooseDeck: router.goHome
            )
        }
    }
}

