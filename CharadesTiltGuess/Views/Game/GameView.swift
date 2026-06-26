import SwiftUI
import UIKit

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
                finishedSplashView
            }

            if let feedback = viewModel.feedback {
                feedbackOverlay(for: feedback)
                feedbackPauseButton
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
        .animation(.easeInOut(duration: 0.18), value: viewModel.phase)
    }

    private var deck: Deck {
        configuration.deck
    }

    private var gameplayBackground: some View {
        ZStack {
            DoodlePaperBackground()

            Canvas { context, size in
                let lineColor = AppTheme.Colors.ink.opacity(0.018)

                for y in stride(from: 18.0, through: size.height, by: 32.0) {
                    var path = Path()
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: size.width, y: y))
                    context.stroke(path, with: .color(lineColor), lineWidth: 1)
                }

                for x in stride(from: 18.0, through: size.width, by: 32.0) {
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
                    .foregroundStyle(AppTheme.Colors.ink)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.62)
                    .accessibilityIdentifier("preparationTitle")

                Text(viewModel.preparationMessage)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink.opacity(0.62))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: 500)
            }

            Label(viewModel.tiltStatusText, systemImage: viewModel.isTiltAvailable ? "dot.radiowaves.left.and.right" : "hand.tap.fill")
                .font(.system(size: 14, weight: .black, design: .rounded))
                .foregroundStyle(AppTheme.Colors.ink.opacity(0.62))

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
                .padding(.horizontal, 56)
                .padding(.top, configuration.mode == .kids ? 24 : 70)

            if configuration.mode != .kids {
                Spacer(minLength: 0)
            }

            VStack(spacing: 12) {
                if let challenge = viewModel.currentChallenge {
                    challengeBanner(challenge)
                }

                wordCard
                    .offset(y: configuration.mode == .kids ? 0 : -18)
            }
            .padding(.horizontal, configuration.mode == .kids ? 8 : 56)

            if configuration.mode != .kids {
                Spacer(minLength: 0)
                tiltStatus
                    .padding(.horizontal, 56)
                    .padding(.bottom, 42)
            } else {
                Spacer(minLength: 0)
            }
        }
        .padding(.bottom, configuration.mode == .kids ? 24 : 0)
    }

    private var topBar: some View {
        HStack {
            pauseButton
                .padding(.leading, configuration.mode == .kids ? 16 : 0)

            Spacer()

            if configuration.mode != .kids {
                VStack(spacing: 0) {
                    Text(configuration.mode.title.uppercased())
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.ink.opacity(0.72))

                    Text(viewModel.timerText)
                        .font(.system(size: 58, weight: .black, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.ink)
                        .monospacedDigit()
                        .accessibilityIdentifier("gameTimer")
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                if configuration.mode != .kids {
                    Text("Score")
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.ink)

                    Text("\(viewModel.score)")
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .foregroundStyle(Color(red: 0.92, green: 0.33, blue: 0.52))
                        .monospacedDigit()
                } else {
                    Text(viewModel.timerText)
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.ink.opacity(0.4))
                        .monospacedDigit()
                        .accessibilityIdentifier("gameTimer")
                }
            }
            .frame(width: configuration.mode == .kids ? nil : 92, alignment: .trailing)
        }
    }

    private var pauseButton: some View {
        DoodleIconButton(
            symbol: viewModel.isPaused ? "play.fill" : "pause.fill",
            accent: AppTheme.Colors.paperBright.opacity(0.92),
            size: 66,
            accessibilityLabel: "Pause round"
        ) {
            viewModel.togglePause()
        }
    }

    private var feedbackPauseButton: some View {
        VStack {
            HStack {
                pauseButton
                    .padding(.leading, configuration.mode == .kids ? 16 : 0)
                Spacer()
            }

            Spacer()
        }
        .padding(.horizontal, 56)
        .padding(.top, configuration.mode == .kids ? 24 : 70)
        .padding(.bottom, configuration.mode == .kids ? 24 : 42)
    }

    private var wordCard: some View {
        ZStack {
            if let imageName = availableKidsImageName {
                VStack(spacing: 52) {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .scaleEffect(1.45)

                    Text(viewModel.currentWordText)
                        .font(.system(size: 44, weight: .black, design: .rounded))
                        .minimumScaleFactor(0.4)
                        .lineLimit(1)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(AppTheme.Colors.ink.opacity(0.85))
                        .accessibilityIdentifier("gameWord")
                }
            } else {
                HStack {
                    Text(viewModel.currentWordText)
                        .font(.system(size: 88, weight: .black, design: .rounded))
                        .minimumScaleFactor(0.28)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(AppTheme.Colors.ink)
                        .padding(.horizontal, 10)
                        .accessibilityIdentifier("gameWord")
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 170)
        .frame(maxHeight: configuration.mode == .kids ? .infinity : nil)
    }

    private var availableKidsImageName: String? {
        guard configuration.mode == .kids,
              let imageName = viewModel.currentImageName,
              UIImage(named: imageName) != nil
        else {
            return nil
        }

        return imageName
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

    private var tiltStatus: some View {
        Label(
            statusText,
            systemImage: viewModel.isTiltAvailable ? "iphone.gen3.radiowaves.left.and.right" : "hand.draw.fill"
        )
        .font(.system(size: 15, weight: .black, design: .rounded))
        .foregroundStyle(AppTheme.Colors.ink.opacity(0.62))
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
        .frame(height: 54)
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

    private var finishedSplashView: some View {
        ZStack {
            deck.color.displayColor
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "flag.checkered")
                    .font(.system(size: 52, weight: .black))
                    .foregroundStyle(AppTheme.Colors.ink)
                    .frame(width: 104, height: 104)
                    .background(AppTheme.Colors.paperBright, in: Circle())
                    .overlay(Circle().stroke(AppTheme.Colors.ink, lineWidth: AppTheme.Stroke.bold))
                    .shadow(color: .black.opacity(0.24), radius: 0, x: 5, y: 7)

                Text("Round complete")
                    .font(.system(size: 58, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink)
                    .minimumScaleFactor(0.58)
                    .lineLimit(1)

                Text("\(viewModel.score) score")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink.opacity(0.68))
                    .monospacedDigit()
            }
            .padding(.horizontal, 40)
            .transition(.scale(scale: 0.96).combined(with: .opacity))
        }
    }

    private var pauseOverlay: some View {
        ZStack {
            Color.black.opacity(0.62)
                .ignoresSafeArea()

            DoodlePanel {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Paused")
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.ink)

                    HStack(spacing: 14) {
                        pauseActionButton(title: "Resume", symbol: "play.fill", accent: AppTheme.Colors.mint, action: viewModel.resume)
                        pauseActionButton(title: "End", symbol: "flag.checkered", accent: AppTheme.Colors.yellow, action: viewModel.endRound)
                        pauseActionButton(title: "Home", symbol: "house.fill", accent: AppTheme.Colors.paperBright, action: onExit)
                    }
                }
                .padding(26)
                .frame(width: 430)
            }
        }
    }

    private func pauseActionButton(title: String, symbol: String, accent: Color, action: @escaping () -> Void) -> some View {
        VStack(spacing: 10) {
            DoodleIconButton(
                symbol: symbol,
                accent: accent,
                size: 82,
                accessibilityLabel: title == "End" ? "End Round" : title,
                accessibilityIdentifier: title == "End" ? "pauseEndRoundButton" : "pause\(title)Button",
                action: action
            )

            Text(title)
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundStyle(AppTheme.Colors.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
    }
}
