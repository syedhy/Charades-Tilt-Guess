import SwiftUI

struct GameView: View {
    let deck: Deck
    let duration: Int
    let settings: GameSettings
    let onRoundFinished: (RoundResult) -> Void
    let onExit: () -> Void

    @StateObject private var viewModel: GameViewModel

    init(
        deck: Deck,
        duration: Int,
        settings: GameSettings,
        onRoundFinished: @escaping (RoundResult) -> Void,
        onExit: @escaping () -> Void
    ) {
        self.deck = deck
        self.duration = duration
        self.settings = settings
        self.onRoundFinished = onRoundFinished
        self.onExit = onExit
        _viewModel = StateObject(
            wrappedValue: GameViewModel(
                deck: deck,
                duration: duration,
                settings: settings,
                onFinish: onRoundFinished
            )
        )
    }

    var body: some View {
        ZStack {
            gameplayBackground

            VStack(spacing: 18) {
                topBar

                Spacer(minLength: 0)

                wordCard

                Spacer(minLength: 0)

                tiltStatus
                actionButtons
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 22)

            if let feedback = viewModel.feedback {
                feedbackOverlay(for: feedback)
            }

            if viewModel.isPaused {
                pauseOverlay
            }
        }
        .preferredColorScheme(.light)
        .onAppear {
            viewModel.startRoundSystemsIfNeeded()
        }
    }

    private var gameplayBackground: some View {
        ZStack {
            Color(red: 0.08, green: 0.11, blue: 0.14)
                .ignoresSafeArea()

            Canvas { context, size in
                let lineColor = Color.white.opacity(0.025)

                for y in stride(from: 20.0, through: size.height, by: 24.0) {
                    var path = Path()
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: size.width, y: y))
                    context.stroke(path, with: .color(lineColor), lineWidth: 1)
                }

                for x in stride(from: 20.0, through: size.width, by: 24.0) {
                    var path = Path()
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: size.height))
                    context.stroke(path, with: .color(lineColor), lineWidth: 1)
                }
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)
        }
    }

    private var topBar: some View {
        HStack {
            DoodleIconButton(
                symbol: viewModel.isPaused ? "play.fill" : "pause.fill",
                accent: Color.white.opacity(0.32),
                size: 54,
                accessibilityLabel: "Pause round"
            ) {
                viewModel.togglePause()
            }

            Spacer()

            Text("\(viewModel.timeRemaining)")
                .font(.system(size: 56, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .monospacedDigit()
                .accessibilityIdentifier("gameTimer")

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("Score")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(.white.opacity(0.56))

                Text("\(viewModel.score)")
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundStyle(deck.color.displayColor)
                    .monospacedDigit()
            }
            .frame(width: 74, alignment: .trailing)
        }
    }

    private var wordCard: some View {
        RoundedRectangle(cornerRadius: 30, style: .continuous)
            .fill(Color(red: 0.12, green: 0.17, blue: 0.22))
            .overlay {
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .stroke(deck.color.displayColor.opacity(0.9), lineWidth: 6)
            }
            .overlay {
                Text(viewModel.currentWordText)
                    .font(.system(size: 74, weight: .black, design: .rounded))
                    .minimumScaleFactor(0.28)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 36)
                    .accessibilityIdentifier("gameWord")
            }
            .shadow(color: .black.opacity(0.28), radius: 0, x: 6, y: 8)
    }

    private var actionButtons: some View {
        HStack(spacing: 16) {
            Button {
                viewModel.mark(.passed)
            } label: {
                gameActionLabel(title: "Pass", symbol: "arrow.uturn.forward", color: AppTheme.Colors.coral)
            }
            .accessibilityIdentifier("passButton")

            Button {
                viewModel.mark(.correct)
            } label: {
                gameActionLabel(title: "Correct", symbol: "checkmark", color: AppTheme.Colors.mint)
            }
            .accessibilityIdentifier("correctButton")
        }
        .buttonStyle(DoodlePressStyle())
    }

    private var tiltStatus: some View {
        Label(
            viewModel.tiltStatusText,
            systemImage: viewModel.isTiltAvailable ? "iphone.gen3.radiowaves.left.and.right" : "hand.tap.fill"
        )
        .font(.system(size: 13, weight: .black, design: .rounded))
        .foregroundStyle(.white.opacity(0.68))
        .lineLimit(1)
        .minimumScaleFactor(0.72)
        .accessibilityIdentifier("tiltStatus")
    }

    private func gameActionLabel(title: String, symbol: String, color: Color) -> some View {
        HStack {
            Image(systemName: symbol)
                .font(.system(size: 22, weight: .black))

            Text(title)
                .font(.system(size: 24, weight: .black, design: .rounded))
        }
        .foregroundStyle(AppTheme.Colors.ink)
        .frame(maxWidth: .infinity)
        .frame(height: 64)
        .background(color, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(AppTheme.Colors.ink, lineWidth: AppTheme.Stroke.standard)
        }
        .shadow(color: .black.opacity(0.26), radius: 0, x: 4, y: 5)
    }

    private func feedbackOverlay(for feedback: WordStatus) -> some View {
        let color = feedback == .correct ? AppTheme.Colors.mint : AppTheme.Colors.coral
        let title = feedback == .correct ? "Correct" : "Pass"

        return color
            .ignoresSafeArea()
            .overlay {
                Text(title)
                    .font(.system(size: 74, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink)
            }
            .transition(.opacity)
    }

    private var pauseOverlay: some View {
        Color.black.opacity(0.58)
            .ignoresSafeArea()
            .overlay {
                DoodlePanel {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Paused")
                            .font(.system(size: 36, weight: .black, design: .rounded))
                            .foregroundStyle(AppTheme.Colors.ink)

                        DoodleActionButton(
                            title: "Resume",
                            symbol: "play.fill",
                            accent: AppTheme.Colors.mint,
                            action: viewModel.resume
                        )

                        DoodleActionButton(
                            title: "End round",
                            symbol: "flag.checkered",
                            accent: AppTheme.Colors.yellow,
                            action: viewModel.endRound
                        )

                        DoodleActionButton(
                            title: "Exit to decks",
                            symbol: "house.fill",
                            accent: AppTheme.Colors.paperBright,
                            action: onExit
                        )
                    }
                    .padding(24)
                    .frame(width: 360)
                }
            }
    }
}
