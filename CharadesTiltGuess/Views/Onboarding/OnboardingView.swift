import SwiftUI

struct OnboardingView: View {
    let isPresentedModally: Bool
    let onDone: () -> Void

    @State private var page = 0
    @State private var tiltDemo = false

    private let pages = OnboardingPage.all

    var body: some View {
        ZStack {
            DoodlePaperBackground()

            VStack(spacing: 0) {
                HStack {
                    Text("How to play")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.ink)

                    Spacer()

                    DoodleIconButton(symbol: "xmark", size: 42, accessibilityLabel: "Close onboarding") {
                        finish()
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 18)

                TabView(selection: $page) {
                    ForEach(Array(pages.enumerated()), id: \.element.id) { index, item in
                        onboardingPage(item)
                            .tag(index)
                            .padding(.horizontal, 24)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                footer
                    .padding(24)
            }
        }
        .preferredColorScheme(.light)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.3).repeatForever(autoreverses: true)) {
                tiltDemo.toggle()
            }
        }
    }

    private func onboardingPage(_ item: OnboardingPage) -> some View {
        VStack(spacing: AppTheme.Spacing.roomy) {
            Spacer(minLength: 8)

            DoodlePanel(background: item.accent) {
                VStack(spacing: 18) {
                    PhoneMotionIllustration(kind: item.kind, isAnimating: tiltDemo)
                        .frame(height: 250)

                    VStack(spacing: 8) {
                        Text(item.title)
                            .font(.system(size: 34, weight: .black, design: .rounded))
                            .foregroundStyle(AppTheme.Colors.ink)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(item.caption)
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.Colors.ink.opacity(0.68))
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(24)
                .frame(maxWidth: .infinity)
            }

            Spacer(minLength: 8)
        }
    }

    private var footer: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                ForEach(pages.indices, id: \.self) { index in
                    Capsule()
                        .fill(index == page ? AppTheme.Colors.ink : AppTheme.Colors.ink.opacity(0.22))
                        .frame(width: index == page ? 28 : 9, height: 9)
                        .animation(.snappy(duration: 0.18), value: page)
                }
            }

            DoodleActionButton(
                title: page == pages.count - 1 ? "Start playing" : "Next",
                symbol: page == pages.count - 1 ? "checkmark" : "arrow.right",
                accent: pages[page].accent
            ) {
                if page == pages.count - 1 {
                    finish()
                } else {
                    withAnimation(.snappy(duration: 0.2)) {
                        page += 1
                    }
                }
            }
            .accessibilityIdentifier("onboardingPrimaryButton")
        }
    }

    private func finish() {
        onDone()
    }
}

private enum PhoneMotionKind {
    case hold
    case correct
    case pass
    case neutral
    case countdown
    case score
}

private struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let caption: String
    let accent: Color
    let kind: PhoneMotionKind

    static let all = [
        OnboardingPage(
            title: "Hold it high",
            caption: "Place the phone on your forehead with the word facing your team.",
            accent: AppTheme.Colors.yellow,
            kind: .hold
        ),
        OnboardingPage(
            title: "Tilt down for correct",
            caption: "When your team gets it, dip the top edge forward.",
            accent: AppTheme.Colors.mint,
            kind: .correct
        ),
        OnboardingPage(
            title: "Tilt up to pass",
            caption: "Stuck? Tilt the top edge back and move on.",
            accent: AppTheme.Colors.coral,
            kind: .pass
        ),
        OnboardingPage(
            title: "Return to neutral",
            caption: "Come back to center before the next gesture so the app reads it cleanly.",
            accent: AppTheme.Colors.blue,
            kind: .neutral
        ),
        OnboardingPage(
            title: "Countdown, then play",
            caption: "The round starts after the phone is in position and the 3-2-1 countdown finishes.",
            accent: AppTheme.Colors.orange,
            kind: .countdown
        ),
        OnboardingPage(
            title: "Score the streak",
            caption: "Correct cards score points. Passes are tracked separately for results.",
            accent: AppTheme.Colors.paperBright,
            kind: .score
        )
    ]
}

private struct PhoneMotionIllustration: View {
    let kind: PhoneMotionKind
    let isAnimating: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(AppTheme.Colors.paperBright.opacity(0.7))
                .frame(width: 210, height: 210)
                .overlay(Circle().stroke(AppTheme.Colors.ink.opacity(0.18), lineWidth: 3))

            phone
                .rotationEffect(.degrees(rotation))
                .offset(y: verticalOffset)

            if kind == .countdown {
                Text(isAnimating ? "2" : "3")
                    .font(.system(size: 64, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink)
                    .offset(x: 86, y: -78)
            }

            if kind == .score {
                scoreBubble(symbol: "checkmark", text: "+1", accent: AppTheme.Colors.mint)
                    .offset(x: -82, y: -70)

                scoreBubble(symbol: "arrow.uturn.forward", text: "Pass", accent: AppTheme.Colors.coral)
                    .offset(x: 82, y: 70)
            }
        }
    }

    private var phone: some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(AppTheme.Colors.ink)
            .frame(width: 112, height: 188)
            .overlay {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(AppTheme.Colors.paperBright)
                    .padding(9)
            }
            .overlay {
                VStack(spacing: 10) {
                    Image(systemName: symbol)
                        .font(.system(size: 34, weight: .black))

                    Text(label)
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .multilineTextAlignment(.center)
                }
                .foregroundStyle(AppTheme.Colors.ink)
                .padding(18)
            }
            .shadow(color: AppTheme.Colors.ink.opacity(0.22), radius: 0, x: 6, y: 7)
    }

    private var rotation: Double {
        switch kind {
        case .correct:
            return isAnimating ? 14 : 0
        case .pass:
            return isAnimating ? -14 : 0
        case .neutral:
            return isAnimating ? 2 : -2
        default:
            return isAnimating ? -2 : 2
        }
    }

    private var verticalOffset: CGFloat {
        kind == .hold ? (isAnimating ? -8 : 4) : 0
    }

    private var symbol: String {
        switch kind {
        case .hold:
            return "person.crop.circle"
        case .correct:
            return "checkmark"
        case .pass:
            return "arrow.uturn.forward"
        case .neutral:
            return "minus"
        case .countdown:
            return "3.circle.fill"
        case .score:
            return "chart.bar.fill"
        }
    }

    private var label: String {
        switch kind {
        case .hold:
            return "Forehead"
        case .correct:
            return "Correct"
        case .pass:
            return "Pass"
        case .neutral:
            return "Neutral"
        case .countdown:
            return "Ready"
        case .score:
            return "Score"
        }
    }

    private func scoreBubble(symbol: String, text: String, accent: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: symbol)
            Text(text)
        }
        .font(.system(size: 15, weight: .black, design: .rounded))
        .foregroundStyle(AppTheme.Colors.ink)
        .padding(.horizontal, 12)
        .frame(height: 38)
        .background(accent, in: Capsule())
        .overlay(Capsule().stroke(AppTheme.Colors.ink, lineWidth: 2))
    }
}
