import SwiftUI

struct OnboardingView: View {
    let onDone: () -> Void

    @StateObject private var viewModel = OnboardingViewModel()
    @State private var warningShake = false

    var body: some View {
        ZStack {
            gameplayBackground

            VStack(spacing: 16) {
                topBar

                Spacer(minLength: 0)

                VStack(spacing: 0) {
                    wordCard
                        .modifier(ShakeEffect(animatableData: warningShake ? 1 : 0))
                }

                Spacer(minLength: 0)

                tiltStatus
            }
            .padding(.horizontal, 56)
            .padding(.top, 32)
            .padding(.bottom, 42)

            if let feedback = viewModel.feedback {
                feedbackOverlay(for: feedback)
            }

            if viewModel.showWrongWayWarning {
                wrongWayOverlay
            }

            if viewModel.currentStep == 3 {
                finishedSplashView
            }
        }
        .preferredColorScheme(.light)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            OrientationController.shared.useGameplayLandscape()
            viewModel.startInteractiveTutorial()
        }
        .onDisappear {
            viewModel.stopInteractiveTutorial()
        }
        .onChange(of: viewModel.showWrongWayWarning) { _, show in
            if show {
                withAnimation(.default) {
                    warningShake.toggle()
                }
            }
        }
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

    private var topBar: some View {
        HStack {
            Button(action: {
                OrientationController.shared.useMenuPortrait()
                onDone()
            }) {
                Text("Skip")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink.opacity(0.5))
            }
            .frame(width: 92, alignment: .leading)
            .accessibilityIdentifier("onboardingDismissButton")

            Spacer()

            VStack(spacing: 0) {
                Text("\(min(viewModel.currentStep + 1, 3))/3")
                    .font(.system(size: 58, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink)
                    .monospacedDigit()
                    .accessibilityIdentifier("onboardingStepCounter")
            }

            Spacer()

            Text("Skip")
                .font(.system(size: 24, weight: .black, design: .rounded))
                .foregroundStyle(.clear)
                .frame(width: 92, alignment: .trailing)
        }
    }

    private var wordCard: some View {
        ZStack {
            HStack {
                Text(viewModel.instructionText)
                    .font(.system(size: viewModel.currentStep == 0 ? 56 : 52, weight: .black, design: .rounded))
                    .minimumScaleFactor(0.2)
                    .lineLimit(viewModel.currentStep == 0 ? 2 : 1)
                    .multilineTextAlignment(.center)
                    .lineSpacing(12)
                    .foregroundStyle(viewModel.showWrongWayWarning ? AppTheme.Colors.coral : viewModel.instructionColor)
                    .padding(.horizontal, 10)
                    .accessibilityIdentifier("onboardingInstruction")
            }
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 170)
    }

    private var tiltStatus: some View {
        VStack(spacing: 8) {
            Text("Tilt Match: \(viewModel.progressPercentage)%")
                .font(.system(size: 24, weight: .black, design: .rounded))
                .foregroundStyle(AppTheme.Colors.ink.opacity(0.72))
                .monospacedDigit()

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AppTheme.Colors.ink.opacity(0.1))
                    Capsule()
                        .fill(viewModel.instructionColor)
                        .frame(width: max(0, min(geo.size.width, geo.size.width * CGFloat(viewModel.progressPercentage) / 100)))
                        .animation(.linear(duration: 0.1), value: viewModel.progressPercentage)
                }
            }
            .frame(width: 280, height: 16)
        }
    }

    private func feedbackOverlay(for feedback: WordStatus) -> some View {
        let color = feedback == .correct ? AppTheme.Colors.mint : AppTheme.Colors.coral
        let title = feedback == .correct ? "Great!" : "Perfect!"

        return color
            .ignoresSafeArea()
            .overlay {
                Text(title)
                    .font(.system(size: 74, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink)
            }
            .transition(.opacity)
    }

    private var wrongWayOverlay: some View {
        AppTheme.Colors.coral.opacity(0.95)
            .ignoresSafeArea()
            .overlay {
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 80, weight: .black))
                    Text("Wrong Way!")
                        .font(.system(size: 64, weight: .black, design: .rounded))
                    Text("Tilt the opposite direction")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                }
                .foregroundStyle(AppTheme.Colors.ink)
            }
            .transition(.opacity)
    }

    private var finishedSplashView: some View {
        ZStack {
            AppTheme.Colors.yellow
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "flag.checkered")
                    .font(.system(size: 52, weight: .black))
                    .foregroundStyle(AppTheme.Colors.ink)
                    .frame(width: 104, height: 104)
                    .background(AppTheme.Colors.paperBright, in: Circle())
                    .overlay(Circle().stroke(AppTheme.Colors.ink, lineWidth: AppTheme.Stroke.bold))
                    .shadow(color: .black.opacity(0.24), radius: 0, x: 5, y: 7)

                Text("You're Ready!")
                    .font(.system(size: 58, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink)
                    .minimumScaleFactor(0.58)
                    .lineLimit(1)

                Text("You know how to play")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink.opacity(0.68))

                DoodleActionButton(title: "Let's Play", symbol: "play.fill", accent: AppTheme.Colors.mint) {
                    OrientationController.shared.useMenuPortrait()
                    onDone()
                }
                .frame(width: 280)
                .padding(.top, 20)
            }
            .padding(.horizontal, 40)
            .transition(.scale(scale: 0.96).combined(with: .opacity))
        }
    }
}

// Custom shake effect for the word card
struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)), y: 0))
    }
}

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var currentStep: Int = 0 // 0 = Hold upright, 1 = Tilt Down, 2 = Tilt Up, 3 = Finished
    @Published var feedback: WordStatus? = nil
    @Published var showWrongWayWarning = false
    @Published var currentAngle: Double = 0.0

    private var motionManager: MotionManager?

    var instructionText: String {
        switch currentStep {
        case 0: return "Hold phone in LANDSCAPE\n& keep it upright"
        case 1: return "Tilt DOWN for Correct"
        case 2: return "Tilt UP for Pass"
        default: return "Ready!"
        }
    }

    var instructionColor: Color {
        switch currentStep {
        case 0: return AppTheme.Colors.ink
        case 1: return AppTheme.Colors.mint.opacity(0.9)
        case 2: return AppTheme.Colors.coral.opacity(0.9)
        default: return AppTheme.Colors.ink
        }
    }

    var progressPercentage: Int {
        let angle = currentAngle * 180 / .pi // degrees

        switch currentStep {
        case 0:
            // Neutral (around 0 degrees, within +- 18)
            let distance = abs(angle)
            if distance <= 18 { return 100 }
            let prog = 100 - ((distance - 18) / (90 - 18) * 100)
            return max(0, min(100, Int(prog)))

        case 1:
            // Tilt down    (positive angle, target >= 34)
            if angle >= 34 { return 100 }
            if angle <= 0 { return 0 }
            return max(0, min(100, Int((angle / 34) * 100)))

        case 2:
            // Tilt up (negative angle, target <= -34)
            if angle <= -34 { return 100 }
            if angle >= 0 { return 0 }
            return max(0, min(100, Int((abs(angle) / 34) * 100)))

        default:
            return 100
        }
    }

    func startInteractiveTutorial() {
        motionManager = MotionManager(sensitivity: .relaxed)
        motionManager?.start(
            onAction: { [weak self] action in
                self?.handleAction(action)
            },
            onNeutralDetected: { [weak self] in
                self?.handleNeutral()
            },
            onAngleUpdated: { [weak self] angle in
                self?.currentAngle = angle
            }
        )
    }

    func stopInteractiveTutorial() {
        motionManager?.stop()
        motionManager = nil
    }

    private func handleNeutral() {
        if currentStep == 0 {
            SoundService.shared.play(.startCountdown, enabled: true)
            withAnimation(.snappy(duration: 0.4)) {
                currentStep = 1
            }
        }
    }

    private func handleAction(_ action: TiltAction) {
        guard !showWrongWayWarning && feedback == nil else { return }

        if currentStep == 1 {
            if action == .correct {
                triggerSuccess(status: .correct) {
                    self.currentStep = 2
                }
            } else if action == .pass {
                triggerWrongWay()
            }
        } else if currentStep == 2 {
            if action == .pass {
                triggerSuccess(status: .passed) {
                    self.currentStep = 3
                }
            } else if action == .correct {
                triggerWrongWay()
            }
        }
    }

    private func triggerWrongWay() {
        SoundService.shared.play(.pass, enabled: true) // Play pass sound for wrong way in onboarding
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            showWrongWayWarning = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.snappy(duration: 0.4)) {
                self.showWrongWayWarning = false
            }
        }
    }

    private func triggerSuccess(status: WordStatus, completion: @escaping () -> Void) {
        SoundService.shared.play(.correct, enabled: true) // Always play correct sound for completing a step

        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            feedback = status
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.snappy(duration: 0.4)) {
                self.feedback = nil
                completion()
            }
        }
    }
}
