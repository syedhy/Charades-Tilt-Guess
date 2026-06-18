import SwiftUI

struct OnboardingView: View {
    let isPresentedModally: Bool
    let onDone: () -> Void

    @State private var page = 0
    @State private var isAnimating = false

    private let pages = OnboardingPage.all

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                DoodlePaperBackground()

                VStack(spacing: 0) {
                    header
                        .padding(.horizontal, 24)
                        .padding(.top, min(max(proxy.safeAreaInsets.top - 24, 20), 36))

                    TabView(selection: $page) {
                        ForEach(Array(pages.enumerated()), id: \.element.id) { index, item in
                            onboardingPage(item, index: index)
                                .tag(index)
                                .padding(.horizontal, 24)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .padding(.top, 8)

                    footer
                        .padding(.horizontal, 24)
                        .padding(.bottom, max(proxy.safeAreaInsets.bottom + 16, 28))
                }
            }
        }
        .preferredColorScheme(.light)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.15).repeatForever(autoreverses: true)) {
                isAnimating.toggle()
            }
        }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Charades")
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink)
                    .lineLimit(1)

                Text("THE POCKET PARTY GAME")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink.opacity(0.62))
                    .lineLimit(1)
            }

            Spacer()

            DoodleIconButton(
                symbol: isPresentedModally ? "xmark" : "chevron.left",
                size: 42,
                accessibilityLabel: isPresentedModally ? "Close onboarding" : "Back",
                accessibilityIdentifier: "onboardingDismissButton"
            ) {
                finish()
            }
        }
    }

    private func onboardingPage(_ item: OnboardingPage, index: Int) -> some View {
        ScrollView {
            VStack(spacing: 14) {
                VStack(spacing: 14) {
                    HStack {
                        Text("Step \(index + 1) of \(pages.count)")
                            .font(.system(size: 12, weight: .black, design: .rounded))
                            .foregroundStyle(AppTheme.Colors.ink.opacity(0.62))

                        Spacer()

                        Image(systemName: item.symbol)
                            .font(.system(size: 19, weight: .black))
                            .foregroundStyle(AppTheme.Colors.ink)
                    }

                    OnboardingIllustration(kind: item.kind, accent: item.accent, isAnimating: isAnimating)
                        .frame(height: 174)

                    VStack(spacing: 14) {
                        Text(item.title)
                            .font(.system(size: 29, weight: .black, design: .rounded))
                            .foregroundStyle(AppTheme.Colors.ink)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(item.caption)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.Colors.ink.opacity(0.68))
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity)
                .background(OnboardingCardBackground(background: item.accent))
                .padding(.horizontal, 10)
                .padding(.bottom, 6)

                VStack(spacing: 8) {
                    ForEach(item.tips) { tip in
                        OnboardingTipRow(tip: tip)
                    }
                }
            }
            .padding(.bottom, 10)
        }
        .scrollIndicators(.hidden)
    }

    private var footer: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                ForEach(pages.indices, id: \.self) { index in
                    Capsule()
                        .fill(index == page ? AppTheme.Colors.ink : AppTheme.Colors.ink.opacity(0.22))
                        .frame(width: index == page ? 30 : 9, height: 9)
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

private struct OnboardingCardBackground: View {
    let background: Color

    var body: some View {
        RoundedRectangle(cornerRadius: AppTheme.Radius.panel, style: .continuous)
            .fill(background)
            .overlay {
                RoundedRectangle(cornerRadius: AppTheme.Radius.panel, style: .continuous)
                    .stroke(AppTheme.Colors.ink, lineWidth: AppTheme.Stroke.standard)
            }
            .shadow(color: AppTheme.Colors.ink.opacity(0.16), radius: 0, x: 4, y: 5)
    }
}

private enum OnboardingIllustrationKind {
    case deck
    case hold
    case gesture
    case results
}

private struct OnboardingTip: Identifiable {
    let id = UUID()
    let symbol: String
    let text: String
}

private struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let caption: String
    let accent: Color
    let symbol: String
    let kind: OnboardingIllustrationKind
    let tips: [OnboardingTip]

    static let all = [
        OnboardingPage(
            title: "Pick a deck",
            caption: "Choose a built-in deck, make your own, paste a quick list, or start a Wikipedia round.",
            accent: AppTheme.Colors.yellow,
            symbol: "rectangle.stack.fill",
            kind: .deck,
            tips: [
                OnboardingTip(symbol: "plus", text: "Create custom decks anytime."),
                OnboardingTip(symbol: "doc.on.clipboard", text: "Paste a list when you want to play fast.")
            ]
        ),
        OnboardingPage(
            title: "Hold it up",
            caption: "Place the phone on your forehead with the word facing your team.",
            accent: AppTheme.Colors.blue,
            symbol: "iphone.gen3.radiowaves.left.and.right",
            kind: .hold,
            tips: [
                OnboardingTip(symbol: "hand.raised.fill", text: "Keep the phone steady before the countdown."),
                OnboardingTip(symbol: "speaker.wave.2.fill", text: "The start sound tells everyone the round is live.")
            ]
        ),
        OnboardingPage(
            title: "Tilt to score",
            caption: "Tilt down when your team guesses it. Tilt up when you want to pass.",
            accent: AppTheme.Colors.mint,
            symbol: "arrow.up.and.down",
            kind: .gesture,
            tips: [
                OnboardingTip(symbol: "checkmark", text: "Down means correct."),
                OnboardingTip(symbol: "arrow.uturn.forward", text: "Up means pass.")
            ]
        ),
        OnboardingPage(
            title: "See the round",
            caption: "After the splash, results show your score and every card you played.",
            accent: DeckColor.pink.displayColor,
            symbol: "flag.checkered",
            kind: .results,
            tips: [
                OnboardingTip(symbol: "checkmark.circle.fill", text: "Correct cards stay clean and bold."),
                OnboardingTip(symbol: "xmark.circle.fill", text: "Passed cards are crossed out.")
            ]
        )
    ]
}

private struct OnboardingTipRow: View {
    let tip: OnboardingTip

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: tip.symbol)
                .font(.system(size: 15, weight: .black))
                .foregroundStyle(AppTheme.Colors.ink)
                .frame(width: 34, height: 34)
                .background(AppTheme.Colors.paperBright, in: Circle())
                .overlay(Circle().stroke(AppTheme.Colors.ink, lineWidth: 2))

            Text(tip.text)
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundStyle(AppTheme.Colors.ink.opacity(0.72))
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .frame(minHeight: 46)
        .background(AppTheme.Colors.paperBright.opacity(0.68), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct OnboardingIllustration: View {
    let kind: OnboardingIllustrationKind
    let accent: Color
    let isAnimating: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(AppTheme.Colors.paperBright.opacity(0.55))
                .overlay {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(AppTheme.Colors.ink.opacity(0.18), lineWidth: 3)
                }

            switch kind {
            case .deck:
                deckStack
            case .hold:
                phone(symbol: "person.crop.circle.fill", label: "Ready")
                    .offset(y: isAnimating ? -8 : 3)
            case .gesture:
                HStack(spacing: 30) {
                    phone(symbol: "checkmark", label: "Down")
                        .rotationEffect(.degrees(isAnimating ? 12 : 0))
                    phone(symbol: "arrow.uturn.forward", label: "Up")
                        .rotationEffect(.degrees(isAnimating ? -12 : 0))
                }
            case .results:
                resultList
            }
        }
    }

    private var deckStack: some View {
        ZStack {
            miniCard(color: AppTheme.Colors.coral, symbol: "sparkles")
                .rotationEffect(.degrees(-10))
                .offset(x: -44, y: 16)
            miniCard(color: AppTheme.Colors.yellow, symbol: "film")
                .rotationEffect(.degrees(3))
                .offset(x: 0, y: -4)
            miniCard(color: AppTheme.Colors.mint, symbol: "sportscourt")
                .rotationEffect(.degrees(10))
                .offset(x: 46, y: 18)
        }
    }

    private var resultList: some View {
        VStack(alignment: .leading, spacing: 12) {
            resultRow(text: "rocket", isCorrect: true)
            resultRow(text: "castle", isCorrect: true)
            resultRow(text: "harbor", isCorrect: false)
            resultRow(text: "puzzle", isCorrect: true)
        }
        .padding(20)
        .frame(maxWidth: 250)
    }

    private func phone(symbol: String, label: String) -> some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(AppTheme.Colors.ink)
            .frame(width: 106, height: 172)
            .overlay {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(AppTheme.Colors.paperBright)
                    .padding(9)
            }
            .overlay {
                VStack(spacing: 10) {
                    Image(systemName: symbol)
                        .font(.system(size: 31, weight: .black))

                    Text(label)
                        .font(.system(size: 15, weight: .black, design: .rounded))
                }
                .foregroundStyle(AppTheme.Colors.ink)
            }
            .shadow(color: AppTheme.Colors.ink.opacity(0.2), radius: 0, x: 6, y: 7)
    }

    private func miniCard(color: Color, symbol: String) -> some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(color)
            .frame(width: 82, height: 112)
            .overlay {
                Image(systemName: symbol)
                    .font(.system(size: 30, weight: .black))
                    .foregroundStyle(AppTheme.Colors.ink)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(AppTheme.Colors.ink, lineWidth: AppTheme.Stroke.standard)
            }
            .shadow(color: AppTheme.Colors.ink.opacity(0.18), radius: 0, x: 5, y: 6)
    }

    private func resultRow(text: String, isCorrect: Bool) -> some View {
        HStack(spacing: 10) {
            Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 22, weight: .black))
                .foregroundStyle(isCorrect ? AppTheme.Colors.mint : AppTheme.Colors.coral)

            Text(text)
                .font(.system(size: 25, weight: .black, design: .rounded))
                .strikethrough(!isCorrect, color: AppTheme.Colors.coral)
                .foregroundStyle(AppTheme.Colors.ink.opacity(isCorrect ? 1 : 0.55))
        }
    }
}
