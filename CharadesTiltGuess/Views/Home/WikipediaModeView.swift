import SwiftUI

@MainActor
final class WikipediaModeViewModel: ObservableObject {
    enum LoadState: Equatable {
        case idle
        case loading
        case loaded([String])
        case failed(String)
    }

    @Published private(set) var state: LoadState = .idle

    private let service: WikipediaService

    init(service: WikipediaService = WikipediaService()) {
        self.service = service
    }

    var titles: [String] {
        if case let .loaded(titles) = state {
            return titles
        }

        return []
    }

    func load() {
        guard state != .loading else { return }
        state = .loading

        Task {
            do {
                let titles = try await service.loadRandomTitles(limit: 45)
                state = titles.isEmpty ? .failed("Wikipedia did not return any playable titles.") : .loaded(titles)
            } catch {
                state = .failed("Could not load Wikipedia titles. Check your connection and try again.")
            }
        }
    }
}

struct WikipediaModeView: View {
    let settings: GameSettings
    let onStart: (GameConfiguration) -> Void

    @StateObject private var viewModel = WikipediaModeViewModel()

    var body: some View {
        ZStack {
            DoodlePaperBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.roomy) {
                    header
                    content
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
            if case .idle = viewModel.state {
                viewModel.load()
            }
        }
    }

    private var header: some View {
        DoodlePanel(background: GameMode.wikipedia.accentColor) {
            HStack(alignment: .center, spacing: 16) {
                Image(systemName: GameMode.wikipedia.symbolName)
                    .font(.system(size: 22, weight: .black))
                    .foregroundStyle(AppTheme.Colors.ink)
                    .frame(width: 46, height: 46)
                    .background(AppTheme.Colors.paperBright.opacity(0.72), in: Circle())
                    .overlay(Circle().stroke(AppTheme.Colors.ink, lineWidth: AppTheme.Stroke.standard))

                VStack(alignment: .leading, spacing: 5) {
                    Text("Wikipedia")
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.ink)

                    Text("Short single-word prompts for charades.")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.ink.opacity(0.66))
                }
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            statePanel(title: "Loading titles", message: "Fetching a fresh set from Wikipedia.", symbol: "arrow.triangle.2.circlepath") {
                ProgressView()
                    .tint(AppTheme.Colors.ink)
                    .scaleEffect(1.2)
            }
        case let .failed(message):
            statePanel(title: "Could not load", message: message, symbol: "wifi.exclamationmark") {
                DoodleActionButton(title: "Try again", symbol: "arrow.clockwise", accent: GameMode.wikipedia.accentColor) {
                    viewModel.load()
                }
            }
        case let .loaded(titles):
            loadedPanel(titles: titles)
        }
    }

    private func statePanel<Content: View>(
        title: String,
        message: String,
        symbol: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        DoodlePanel {
            VStack(alignment: .leading, spacing: 16) {
                Image(systemName: symbol)
                    .font(.system(size: 34, weight: .black))
                    .foregroundStyle(AppTheme.Colors.ink)

                Text(title)
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink)

                Text(message)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink.opacity(0.62))

                content()
            }
            .padding(22)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func loadedPanel(titles: [String]) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.roomy) {
            DoodlePanel(background: AppTheme.Colors.paperBright) {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.standard) {
                    HStack {
                        Text("\(titles.count) titles loaded")
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundStyle(AppTheme.Colors.ink)

                        Spacer()

                        DoodleIconButton(symbol: "arrow.clockwise", accent: GameMode.wikipedia.accentColor, size: 44, accessibilityLabel: "Refresh Wikipedia titles") {
                            viewModel.load()
                        }
                    }

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 132), spacing: 10)], alignment: .leading, spacing: 10) {
                        ForEach(titles.prefix(15), id: \.self) { title in
                            WikipediaTitlePill(text: title)
                        }
                    }
                }
                .padding(18)
            }

            DoodleActionButton(title: "Play Wikipedia", symbol: "play.fill", accent: GameMode.wikipedia.accentColor) {
                onStart(.wikipedia(deck: makeTemporaryDeck(titles: titles), duration: settings.defaultDuration))
            }
            .accessibilityIdentifier("playWikipediaButton")
        }
    }

    private func makeTemporaryDeck(titles: [String]) -> Deck {
        Deck(
            id: "temp-wikipedia-\(UUID().uuidString)",
            name: "Wikipedia Mode",
            description: "Temporary random Wikipedia titles",
            cards: titles.enumerated().map { index, title in
                GameWord(id: "wiki-\(index)-\(UUID().uuidString)", text: title)
            },
            type: .custom,
            color: .purple,
            symbolName: GameMode.wikipedia.symbolName
        )
    }
}

private struct WikipediaTitlePill: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 15, weight: .black, design: .rounded))
            .foregroundStyle(AppTheme.Colors.ink)
            .lineLimit(1)
            .minimumScaleFactor(0.72)
            .padding(.horizontal, 13)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(AppTheme.Colors.paper, in: Capsule())
            .overlay {
                Capsule()
                    .stroke(AppTheme.Colors.ink.opacity(0.42), lineWidth: 2)
            }
    }
}
