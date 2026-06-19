import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var settingsViewModel: SettingsViewModel
    @StateObject private var viewModel: HomeViewModel

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
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 7) {
                Text("Charades")
                    .font(.system(size: 37, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.68)
                    .accessibilityIdentifier("appTitle")

                Text("THE POCKET PARTY GAME")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink.opacity(0.62))
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                ScribbleUnderline()
                    .stroke(AppTheme.Colors.coral, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .frame(width: 190, height: 10)
            }
            .layoutPriority(1)

            Spacer(minLength: 8)

            DoodleIconButton(symbol: "gearshape", accessibilityLabel: "Settings") {
                router.open(.settings)
            }
        }
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
                    router.startGame(mode: .normal, deck: deck, settings: settingsViewModel.settings)
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
                ForEach(GameMode.homeModes) { mode in
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
        case .mixAndMatch:
            router.open(.mixAndMatch)
        case .normal, .infinite:
            router.open(.modeDeckSelection(mode: mode))
        case .hotPotato, .challengeCards:
            break
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

                Text(mode.purpose.uppercased())
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink.opacity(0.48))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 148)
        .background {
            DoodlePanelBackground(background: AppTheme.Colors.paperBright, cornerRadius: AppTheme.Radius.card)
        }
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
