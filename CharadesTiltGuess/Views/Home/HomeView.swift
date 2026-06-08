import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var router: AppRouter
    @StateObject private var viewModel: HomeViewModel
    @State private var isHeroFloating = false
    @State private var didStartHeroAnimation = false

    @MainActor
    init() {
        _viewModel = StateObject(wrappedValue: HomeViewModel())
    }

    @MainActor
    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            DoodlePaperBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    header
                    hero
                    deckSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 42)
            }
            .scrollIndicators(.hidden)
        }
        .preferredColorScheme(.light)
        .onAppear {
            viewModel.loadDecks()

            guard !didStartHeroAnimation else { return }

            didStartHeroAnimation = true
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                isHeroFloating.toggle()
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 7) {
                Text(AppMetadata.displayName)
                    .font(.system(size: 37, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("appTitle")

                Text("THE POCKET PARTY GAME")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink.opacity(0.68))

                ScribbleUnderline()
                    .stroke(AppTheme.Colors.coral, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .frame(width: 188, height: 10)
            }

            Spacer(minLength: 8)

            DoodleIconButton(symbol: "gearshape", accessibilityLabel: "Settings") {
                router.open(.settings)
            }
        }
    }

    private var hero: some View {
        DoodlePanel {
            ZStack {
                DoodleConfetti()
                    .foregroundStyle(AppTheme.Colors.ink.opacity(0.72))

                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("READY\nSET\nGUESS!")
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .foregroundStyle(AppTheme.Colors.ink)
                            .lineSpacing(-2)

                        Text("Pick a deck and\nhold the phone up.")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.Colors.ink.opacity(0.68))

                        HStack(spacing: 6) {
                            Image(systemName: "arrow.turn.down.right")
                                .font(.system(size: 16, weight: .black))

                            Text("tilt to score")
                                .font(.system(size: 13, weight: .black, design: .rounded))
                        }
                        .foregroundStyle(AppTheme.Colors.ink)
                    }

                    Spacer(minLength: 0)

                    heroDeck
                }
                .padding(20)
            }
        }
        .frame(height: 235)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Pick a deck and hold the phone up. Tilt to score.")
    }

    private var heroDeck: some View {
        ZStack {
            DoodleGameCard(accent: AppTheme.Colors.coral, symbol: "xmark", rotation: -14)
                .offset(x: -25, y: 10)

            DoodleGameCard(accent: AppTheme.Colors.yellow, symbol: "questionmark", rotation: -2)
                .offset(x: -4, y: -8)

            DoodleGameCard(accent: AppTheme.Colors.mint, symbol: "checkmark", rotation: 13)
                .offset(x: 27, y: 9)
        }
        .frame(width: 150, height: 170)
        .offset(y: isHeroFloating ? -4 : 4)
    }

    private var deckSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Pick a deck")
                        .font(.system(size: 29, weight: .black, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.ink)

                    Text("Start with one of these")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.ink.opacity(0.56))
                }

                Spacer()

                DoodleIconButton(symbol: "shuffle", accessibilityLabel: "Choose a random deck") {
                    guard let deck = viewModel.randomDeck else { return }
                    router.open(.gameSetup(deck: deck))
                }

                DoodleIconButton(
                    symbol: "plus",
                    accent: AppTheme.Colors.yellow,
                    accessibilityLabel: "Create deck"
                ) {
                    router.openImmediately(.deckEditor)
                }
            }

            if let loadErrorMessage = viewModel.loadErrorMessage {
                deckLoadError(message: loadErrorMessage)
            } else {
                DeckGridView(decks: viewModel.decks) { deck in
                    if deck.type == .custom {
                        router.open(.customDeckDetail(deck: deck))
                    } else {
                        router.open(.gameSetup(deck: deck))
                    }
                }
            }

            createDeckPrompt
        }
    }

    private var createDeckPrompt: some View {
        Button {
            router.openImmediately(.deckEditor)
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "plus")
                    .font(.system(size: 21, weight: .black))
                    .frame(width: 42, height: 42)
                    .background(AppTheme.Colors.yellow, in: Circle())
                    .overlay(Circle().stroke(AppTheme.Colors.ink, lineWidth: 3))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Make your own deck")
                        .font(.system(size: 17, weight: .black, design: .rounded))

                    Text("Name it now, fill it after")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.ink.opacity(0.58))
                }

                Spacer()

                Image(systemName: "arrow.right")
                    .font(.system(size: 18, weight: .black))
            }
            .foregroundStyle(AppTheme.Colors.ink)
            .padding(16)
            .background {
                DoodlePanelBackground(background: AppTheme.Colors.paperBright, cornerRadius: AppTheme.Radius.card)
            }
        }
        .buttonStyle(DoodlePressStyle(rotation: 0))
        .accessibilityLabel("Make your own deck")
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

private struct DoodleGameCard: View {
    let accent: Color
    let symbol: String
    let rotation: Double

    var body: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(accent)
            .frame(width: 88, height: 126)
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(AppTheme.Colors.ink, lineWidth: 4)
            }
            .overlay {
                Image(systemName: symbol)
                    .font(.system(size: 31, weight: .black))
                    .foregroundStyle(AppTheme.Colors.ink)
            }
            .shadow(color: AppTheme.Colors.ink.opacity(0.18), radius: 0, x: 4, y: 5)
            .rotationEffect(.degrees(rotation))
    }
}

private struct DoodleConfetti: View {
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Image(systemName: "scribble.variable")
                    .font(.system(size: 28, weight: .black))
                    .position(x: proxy.size.width * 0.85, y: proxy.size.height * 0.82)
                    .rotationEffect(.degrees(18))

            }
        }
        .allowsHitTesting(false)
    }
}

private struct ScribbleUnderline: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + 2, y: rect.midY - 1))
        path.addCurve(
            to: CGPoint(x: rect.maxX - 2, y: rect.midY + 1),
            control1: CGPoint(x: rect.width * 0.30, y: rect.maxY),
            control2: CGPoint(x: rect.width * 0.68, y: rect.minY)
        )
        return path
    }
}

#Preview {
    HomeView()
        .environmentObject(AppRouter())
}
