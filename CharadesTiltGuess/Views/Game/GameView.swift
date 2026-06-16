import SwiftUI

struct GameView: View {
    let configuration: GameConfiguration
    let settings: GameSettings
    let onRoundFinished: (RoundResult) -> Void
    let onExit: () -> Void

    @StateObject private var viewModel: GameViewModel

    init(
        configuration: GameConfiguration,
        settings: GameSettings,
        onRoundFinished: @escaping (RoundResult) -> Void,
        onExit: @escaping () -> Void
    ) {
        self.configuration = configuration
        self.settings = settings
        self.onRoundFinished = onRoundFinished
        self.onExit = onExit
        _viewModel = StateObject(
            wrappedValue: GameViewModel(
                configuration: configuration,
                settings: settings,
                onFinish: onRoundFinished
            )
        )
    }

    var body: some View {
        ZStack {
            gameplayBackground

            switch viewModel.phase {
            case .preparing:
                preparationView
            case .countdown:
                countdownView
            case .playing, .paused:
                gameplayContent
            case .timeUp:
                timeUpView
            case .finished:
                gameplayContent
            }

            if let feedback = viewModel.feedback {
                feedbackOverlay(for: feedback)
            }

            if viewModel.isPaused {
                pauseOverlay
            }
        }
        .preferredColorScheme(.light)
        .gesture(
            DragGesture(minimumDistance: 35)
                .onEnded { value in
                    viewModel.handleSwipe(translation: value.translation)
                }
        )
        .onAppear {
            viewModel.startRoundSystemsIfNeeded()
        }
    }

    private var deck: Deck {
        configuration.deck
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

    private var preparationView: some View {
        VStack(spacing: 22) {
            Spacer(minLength: 0)

            Image(systemName: settings.motionControlsEnabled ? "iphone.gen3.radiowaves.left.and.right" : "hand.draw.fill")
                .font(.system(size: 58, weight: .black))
                .foregroundStyle(AppTheme.Colors.ink)
                .frame(width: 120, height: 120)
                .background(deck.color.displayColor, in: Circle())
                .overlay(Circle().stroke(AppTheme.Colors.ink, lineWidth: AppTheme.Stroke.bold))
                .shadow(color: .black.opacity(0.26), radius: 0, x: 6, y: 8)

            VStack(spacing: 8) {
                Text(viewModel.preparationTitle)
                    .font(.system(size: 44, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.62)
                    .accessibilityIdentifier("preparationTitle")

                Text(viewModel.preparationMessage)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.68))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: 500)
            }

            Label(viewModel.tiltStatusText, systemImage: viewModel.isTiltAvailable ? "dot.radiowaves.left.and.right" : "hand.tap.fill")
                .font(.system(size: 14, weight: .black, design: .rounded))
                .foregroundStyle(.white.opacity(0.72))

            if viewModel.shouldShowManualReadyButton {
                Button {
                    viewModel.beginCountdownManually()
                } label: {
                    gameActionLabel(title: "Ready", symbol: "play.fill", color: deck.color.displayColor)
                        .frame(width: 260)
                }
                .buttonStyle(DoodlePressStyle())
                .accessibilityIdentifier("manualReadyButton")
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 34)
        .padding(.vertical, 24)
    }

    private var countdownView: some View {
        ZStack {
            deck.color.displayColor
                .opacity(0.96)
                .ignoresSafeArea()

            VStack(spacing: 18) {
                Text("Get ready")
                    .font(.system(size: 26, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink.opacity(0.66))

                Text("\(viewModel.countdownValue ?? 1)")
                    .font(.system(size: 142, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink)
                    .monospacedDigit()
                    .scaleEffect(viewModel.countdownValue == nil ? 0.9 : 1)
                    .animation(.spring(response: 0.25, dampingFraction: 0.58), value: viewModel.countdownValue)
                    .accessibilityIdentifier("countdownValue")
            }
        }
    }

    private var gameplayContent: some View {
        VStack(spacing: 16) {
            topBar

            Spacer(minLength: 0)

            VStack(spacing: 12) {
                if let challenge = viewModel.currentChallenge {
                    challengeBanner(challenge)
                }

                wordCard
            }

            Spacer(minLength: 0)

            tiltStatus
            actionButtons
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 22)
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

            VStack(spacing: 0) {
                Text(configuration.mode.title.uppercased())
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundStyle(.white.opacity(0.46))

                Text(viewModel.timerText)
                    .font(.system(size: 56, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .monospacedDigit()
                    .accessibilityIdentifier("gameTimer")
            }

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

    private func challengeBanner(_ challenge: ChallengeCard) -> some View {
        HStack(spacing: 10) {
            Image(systemName: challenge.symbolName)
                .font(.system(size: 18, weight: .black))

            VStack(alignment: .leading, spacing: 1) {
                Text(challenge.title)
                    .font(.system(size: 17, weight: .black, design: .rounded))

                Text(challenge.description)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .opacity(0.66)
            }

            Spacer(minLength: 0)
        }
        .foregroundStyle(AppTheme.Colors.ink)
        .padding(.horizontal, 16)
        .frame(maxWidth: 520)
        .frame(height: 60)
        .background(AppTheme.Colors.orange, in: RoundedRectangle(cornerRadius: AppTheme.Radius.button, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: AppTheme.Radius.button, style: .continuous)
                .stroke(AppTheme.Colors.ink, lineWidth: AppTheme.Stroke.standard)
        }
        .shadow(color: .black.opacity(0.24), radius: 0, x: 4, y: 5)
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
        .opacity(viewModel.phase == .playing ? 1 : 0.55)
        .disabled(viewModel.phase != .playing)
    }

    private var tiltStatus: some View {
        Label(
            statusText,
            systemImage: viewModel.isTiltAvailable ? "iphone.gen3.radiowaves.left.and.right" : "hand.draw.fill"
        )
        .font(.system(size: 13, weight: .black, design: .rounded))
        .foregroundStyle(.white.opacity(0.68))
        .lineLimit(1)
        .minimumScaleFactor(0.72)
        .accessibilityIdentifier("tiltStatus")
    }

    private var statusText: String {
        if viewModel.shouldShowSwipeControls {
            return "\(viewModel.tiltStatusText) - Swipe up to pass, down for correct"
        }

        return viewModel.tiltStatusText
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

    private var timeUpView: some View {
        ZStack {
            AppTheme.Colors.coral
                .ignoresSafeArea()

            VStack(spacing: 10) {
                Text("TIME UP")
                    .font(.system(size: 86, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink)
                    .minimumScaleFactor(0.6)

                Text(configuration.mode == .hotPotato ? "Current holder loses" : "Pencils down")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink.opacity(0.72))
            }
            .scaleEffect(viewModel.isTimeUp ? 1 : 0.92)
            .animation(.spring(response: 0.28, dampingFraction: 0.58), value: viewModel.isTimeUp)
        }
    }

    private var pauseOverlay: some View {
        Color.black.opacity(0.62)
            .ignoresSafeArea()
            .overlay {
                DoodlePanel {
                    VStack(alignment: .leading, spacing: 18) {
                        Text("Paused")
                            .font(.system(size: 42, weight: .black, design: .rounded))
                            .foregroundStyle(AppTheme.Colors.ink)

                        DoodleActionButton(
                            title: "Resume",
                            symbol: "play.fill",
                            accent: AppTheme.Colors.mint,
                            action: viewModel.resume
                        )

                        DoodleActionButton(
                            title: "End Round",
                            symbol: "flag.checkered",
                            accent: AppTheme.Colors.yellow,
                            action: viewModel.endRound
                        )

                        DoodleActionButton(
                            title: "Exit To Main Menu",
                            symbol: "house.fill",
                            accent: AppTheme.Colors.paperBright,
                            action: onExit
                        )
                    }
                    .padding(26)
                    .frame(width: 390)
                }
            }
    }
}
