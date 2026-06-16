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
    @State private var selectedDuration = 60
    @State private var isShowingInstructions = false

    var body: some View {
        ZStack {
            DoodlePaperBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.roomy) {
                    header
                    durationPicker
                    content
                }
                .padding(24)
                .padding(.bottom, 32)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle(GameMode.wikipedia.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isShowingInstructions = true
                } label: {
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 18, weight: .black))
                        .foregroundStyle(AppTheme.Colors.ink)
                }
                .accessibilityLabel("Wikipedia Mode instructions")
            }
        }
        .sheet(isPresented: $isShowingInstructions) {
            ModeInstructionsView(mode: .wikipedia)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .preferredColorScheme(.light)
        .onAppear {
            selectedDuration = settings.defaultDuration
            if case .idle = viewModel.state {
                viewModel.load()
            }
        }
    }

    private var header: some View {
        DoodlePanel(background: GameMode.wikipedia.accentColor) {
            VStack(alignment: .leading, spacing: 12) {
                Label("RANDOM ARTICLES", systemImage: GameMode.wikipedia.symbolName)
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink.opacity(0.62))

                Text("The internet\nmade the deck.")
                    .font(.system(size: 40, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink)
                    .fixedSize(horizontal: false, vertical: true)

                Text("A fresh pack of public Wikipedia article titles, ready for ridiculous clues.")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink.opacity(0.66))
            }
            .padding(22)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var durationPicker: some View {
        DoodlePanel {
            VStack(alignment: .leading, spacing: 14) {
                Text("Round length")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                    ForEach(GameSettings.availableDurations, id: \.self) { duration in
                        Button {
                            selectedDuration = duration
                        } label: {
                            Text("\(duration)s")
                                .font(.system(size: 19, weight: .black, design: .rounded))
                                .foregroundStyle(AppTheme.Colors.ink)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    selectedDuration == duration ? GameMode.wikipedia.accentColor : AppTheme.Colors.paper,
                                    in: RoundedRectangle(cornerRadius: AppTheme.Radius.button, style: .continuous)
                                )
                                .overlay {
                                    RoundedRectangle(cornerRadius: AppTheme.Radius.button, style: .continuous)
                                        .stroke(AppTheme.Colors.ink, lineWidth: AppTheme.Stroke.standard)
                                }
                        }
                        .buttonStyle(DoodlePressStyle())
                    }
                }
            }
            .padding(18)
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
                onStart(.wikipedia(deck: makeTemporaryDeck(titles: titles), duration: selectedDuration))
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
