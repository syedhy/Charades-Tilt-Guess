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
                VStack(alignment: .leading, spacing: AppTheme.Spacing.section) {
                    header
                    hero
                    quickActions
                    modeSection
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
            startHeroAnimationIfNeeded()
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
        DoodlePanel(background: AppTheme.Colors.paperBright) {
            ZStack {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("PICK\nA MODE")
                            .font(.system(size: 34, weight: .black, design: .rounded))
                            .foregroundStyle(AppTheme.Colors.ink)
                            .lineSpacing(-2)

                        Text("Classic rounds, quick pasted lists, hidden timers, and surprise challenges.")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.Colors.ink.opacity(0.66))
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)

                    heroDeck
                }
                .padding(20)
            }
        }
        .frame(height: 226)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Pick a game mode.")
    }

    private var heroDeck: some View {
        ZStack {
            DoodleGameCard(accent: AppTheme.Colors.coral, symbol: "timer", rotation: -14)
                .offset(x: -26, y: 12)

            DoodleGameCard(accent: AppTheme.Colors.yellow, symbol: "doc.on.clipboard", rotation: -2)
                .offset(x: -3, y: -9)

            DoodleGameCard(accent: AppTheme.Colors.mint, symbol: "sparkles", rotation: 13)
                .offset(x: 28, y: 9)
        }
        .frame(width: 150, height: 170)
        .offset(y: isHeroFloating ? -4 : 4)
    }

    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Quick actions")
                .font(.system(size: 24, weight: .black, design: .rounded))
                .foregroundStyle(AppTheme.Colors.ink)

            HStack(spacing: 12) {
                quickAction(title: "Add Deck", symbol: "plus", accent: AppTheme.Colors.paperBright) {
                    router.openImmediately(.deckEditor)
                }

                quickAction(title: "Random", symbol: "shuffle", accent: AppTheme.Colors.paperBright) {
                    guard let deck = viewModel.randomDeck else { return }
                    router.open(.gameSetup(mode: .normal, deck: deck))
                }
            }

            DoodleActionButton(
                title: "Paste & Play",
                symbol: GameMode.pasteAndPlay.symbolName,
                accent: GameMode.pasteAndPlay.accentColor
            ) {
                router.open(.pasteAndPlay)
            }
            .accessibilityIdentifier("pasteAndPlayHomeButton")
        }
    }

    private func quickAction(title: String, symbol: String, accent: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: symbol)
                    .font(.system(size: 23, weight: .black))
                    .frame(width: 48, height: 48)
                    .background(accent, in: Circle())
                    .overlay(Circle().stroke(AppTheme.Colors.ink, lineWidth: AppTheme.Stroke.standard))

                Text(title)
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
            .foregroundStyle(AppTheme.Colors.ink)
            .frame(maxWidth: .infinity)
            .frame(height: 112)
            .background {
                DoodlePanelBackground(background: AppTheme.Colors.paperBright, cornerRadius: AppTheme.Radius.card)
            }
        }
        .buttonStyle(DoodlePressStyle())
    }

    private var modeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Game Modes")
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink)

                Text("Choose the rhythm for this round.")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink.opacity(0.56))
            }

            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible())],
                spacing: AppTheme.Spacing.standard
            ) {
                ForEach(GameMode.allCases) { mode in
                    Button {
                        open(mode)
                    } label: {
                        GameModeCardView(mode: mode)
                    }
                    .buttonStyle(DoodlePressStyle(rotation: 0))
                    .accessibilityLabel("\(mode.title), \(mode.description)")
                    .accessibilityIdentifier("modeButton-\(mode.rawValue)")
                }
            }
        }
    }

    private func open(_ mode: GameMode) {
        switch mode {
        case .pasteAndPlay:
            router.open(.pasteAndPlay)
        case .wikipedia:
            router.open(.wikipediaMode)
        case .normal, .infinite, .hotPotato, .challengeCards:
            router.open(.modeDeckSelection(mode: mode))
        }
    }

    private func startHeroAnimationIfNeeded() {
        guard !didStartHeroAnimation else { return }

        didStartHeroAnimation = true
        withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
            isHeroFloating.toggle()
        }
    }
}

private struct GameModeCardView: View {
    let mode: GameMode

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: mode.symbolName)
                    .font(.system(size: 22, weight: .black))
                    .foregroundStyle(AppTheme.Colors.ink)
                    .frame(width: 46, height: 46)
                    .background(mode.accentColor, in: Circle())
                    .overlay(Circle().stroke(AppTheme.Colors.ink, lineWidth: 3))

                Spacer()
            }

            Spacer(minLength: 0)

            VStack(alignment: .leading, spacing: 6) {
                Text(mode.title)
                    .font(.system(size: 21, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink)
                    .lineLimit(2)
                    .minimumScaleFactor(0.76)

                Text(mode.description)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink.opacity(0.58))
                    .lineLimit(3)
                    .minimumScaleFactor(0.78)

                Text(mode.purpose.uppercased())
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink.opacity(0.48))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 196)
        .background {
            DoodlePanelBackground(background: AppTheme.Colors.paperBright, cornerRadius: AppTheme.Radius.card)
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
