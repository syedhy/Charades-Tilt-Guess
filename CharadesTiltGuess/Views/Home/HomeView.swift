import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var router: AppRouter
    @State private var isHeroFloating = false

    private let sampleDecks = [
        DoodleDeck(name: "Tech", detail: "36 prompts", symbol: "laptopcomputer", accent: DoodleTheme.mint, rotation: -1.2),
        DoodleDeck(name: "Movies", detail: "42 prompts", symbol: "popcorn", accent: DoodleTheme.yellow, rotation: 1.0),
        DoodleDeck(name: "Food", detail: "40 prompts", symbol: "fork.knife", accent: DoodleTheme.coral, rotation: 0.8),
        DoodleDeck(name: "Sports", detail: "34 prompts", symbol: "figure.run", accent: DoodleTheme.blue, rotation: -0.9)
    ]

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
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                isHeroFloating = true
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 7) {
                Text(AppMetadata.displayName)
                    .font(.system(size: 37, weight: .black, design: .rounded))
                    .foregroundStyle(DoodleTheme.ink)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("appTitle")

                Text("THE POCKET PARTY GAME")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(DoodleTheme.ink.opacity(0.68))

                ScribbleUnderline()
                    .stroke(DoodleTheme.coral, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .frame(width: 188, height: 10)
            }

            Spacer(minLength: 8)

            DoodleIconButton(symbol: "gearshape", accessibilityLabel: "Settings") {
                router.open(.settings)
            }
        }
    }

    private var hero: some View {
        DoodlePanel(background: DoodleTheme.paperBright, cornerRadius: 24) {
            ZStack {
                DoodleConfetti()
                    .foregroundStyle(DoodleTheme.ink.opacity(0.72))

                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("READY\nSET\nGUESS!")
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .foregroundStyle(DoodleTheme.ink)
                            .lineSpacing(-2)

                        Text("Pick a deck and\nhold the phone up.")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(DoodleTheme.ink.opacity(0.68))

                        HStack(spacing: 6) {
                            Image(systemName: "arrow.turn.down.right")
                                .font(.system(size: 16, weight: .black))

                            Text("tilt to score")
                                .font(.system(size: 13, weight: .black, design: .rounded))
                        }
                        .foregroundStyle(DoodleTheme.ink)
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
            DoodleGameCard(accent: DoodleTheme.coral, symbol: "xmark", rotation: -14)
                .offset(x: -25, y: 10)

            DoodleGameCard(accent: DoodleTheme.yellow, symbol: "questionmark", rotation: -2)
                .offset(x: -4, y: -8)

            DoodleGameCard(accent: DoodleTheme.mint, symbol: "checkmark", rotation: 13)
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
                        .foregroundStyle(DoodleTheme.ink)

                    Text("Start with one of these")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(DoodleTheme.ink.opacity(0.56))
                }

                Spacer()

                DoodleIconButton(symbol: "shuffle", accessibilityLabel: "Choose a random deck") {
                    router.open(.gameSetup(deckName: "Surprise Mix"))
                }

                DoodleIconButton(
                    symbol: "plus",
                    accent: DoodleTheme.yellow,
                    accessibilityLabel: "Create deck"
                ) {
                    router.open(.deckEditor)
                }
            }

            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible())],
                spacing: 16
            ) {
                ForEach(sampleDecks) { deck in
                    Button {
                        router.open(.gameSetup(deckName: deck.name))
                    } label: {
                        DoodleDeckCard(deck: deck)
                    }
                    .buttonStyle(DoodlePressStyle(rotation: deck.rotation))
                    .accessibilityLabel("\(deck.name), \(deck.detail)")
                }
            }

            createDeckPrompt
        }
    }

    private var createDeckPrompt: some View {
        Button {
            router.open(.deckEditor)
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "plus")
                    .font(.system(size: 21, weight: .black))
                    .frame(width: 42, height: 42)
                    .background(DoodleTheme.yellow, in: Circle())
                    .overlay(Circle().stroke(DoodleTheme.ink, lineWidth: 3))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Make your own deck")
                        .font(.system(size: 17, weight: .black, design: .rounded))

                    Text("Type cards or paste a whole list")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(DoodleTheme.ink.opacity(0.58))
                }

                Spacer()

                Image(systemName: "arrow.right")
                    .font(.system(size: 18, weight: .black))
            }
            .foregroundStyle(DoodleTheme.ink)
            .padding(16)
            .background {
                DoodlePanelBackground(background: DoodleTheme.paperBright, cornerRadius: 18)
            }
        }
        .buttonStyle(DoodlePressStyle(rotation: 0))
        .accessibilityLabel("Make your own deck")
    }
}

private struct DoodleDeck: Identifiable {
    let name: String
    let detail: String
    let symbol: String
    let accent: Color
    let rotation: Double

    var id: String { name }
}

private struct DoodleDeckCard: View {
    let deck: DoodleDeck

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            DoodlePanelBackground(background: DoodleTheme.paperBright, cornerRadius: 18)

            Rectangle()
                .fill(deck.accent)
                .frame(height: 14)
                .clipShape(
                    UnevenRoundedRectangle(
                        bottomLeadingRadius: 15,
                        bottomTrailingRadius: 15
                    )
                )
                .padding(4)

            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    Image(systemName: deck.symbol)
                        .font(.system(size: 22, weight: .black))

                    Spacer()

                    Image(systemName: "sparkle")
                        .font(.system(size: 15, weight: .black))
                        .rotationEffect(.degrees(14))
                }

                Spacer()

                Text(deck.name)
                    .font(.system(size: 22, weight: .black, design: .rounded))

                Text(deck.detail.uppercased())
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundStyle(DoodleTheme.ink.opacity(0.56))
            }
            .foregroundStyle(DoodleTheme.ink)
            .padding(16)
            .padding(.bottom, 8)
        }
        .frame(height: 148)
        .rotationEffect(.degrees(deck.rotation))
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
                    .stroke(DoodleTheme.ink, lineWidth: 4)
            }
            .overlay {
                Image(systemName: symbol)
                    .font(.system(size: 31, weight: .black))
                    .foregroundStyle(DoodleTheme.ink)
            }
            .shadow(color: DoodleTheme.ink.opacity(0.18), radius: 0, x: 4, y: 5)
            .rotationEffect(.degrees(rotation))
    }
}

private struct DoodleIconButton: View {
    let symbol: String
    var accent: Color = DoodleTheme.paperBright
    let accessibilityLabel: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 19, weight: .black))
                .foregroundStyle(DoodleTheme.ink)
                .frame(width: 46, height: 46)
                .background(accent, in: Circle())
                .overlay {
                    Circle()
                        .stroke(DoodleTheme.ink, lineWidth: 3)
                        .rotationEffect(.degrees(-3))
                }
                .shadow(color: DoodleTheme.ink.opacity(0.16), radius: 0, x: 3, y: 3)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }
}

private struct DoodlePanel<Content: View>: View {
    let background: Color
    let cornerRadius: CGFloat
    @ViewBuilder let content: Content

    var body: some View {
        content
            .background {
                DoodlePanelBackground(background: background, cornerRadius: cornerRadius)
            }
    }
}

private struct DoodlePanelBackground: View {
    let background: Color
    let cornerRadius: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(background)

            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(DoodleTheme.ink.opacity(0.25), lineWidth: 2)
                .offset(x: 2, y: -1)
                .rotationEffect(.degrees(0.35))

            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(DoodleTheme.ink, lineWidth: 3)
        }
        .shadow(color: DoodleTheme.ink.opacity(0.15), radius: 0, x: 5, y: 6)
    }
}

private struct DoodlePaperBackground: View {
    var body: some View {
        ZStack {
            DoodleTheme.paper
                .ignoresSafeArea()

            Canvas { context, size in
                let lineColor = DoodleTheme.ink.opacity(0.045)

                for y in stride(from: 22.0, through: size.height, by: 28.0) {
                    var path = Path()
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: size.width, y: y))
                    context.stroke(path, with: .color(lineColor), lineWidth: 1)
                }

                for x in stride(from: 22.0, through: size.width, by: 28.0) {
                    var path = Path()
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: size.height))
                    context.stroke(path, with: .color(lineColor), lineWidth: 1)
                }
            }
            .ignoresSafeArea()
        }
    }
}

private struct DoodleConfetti: View {
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Image(systemName: "sparkles")
                    .font(.system(size: 18, weight: .black))
                    .position(x: proxy.size.width * 0.88, y: proxy.size.height * 0.20)

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

private struct DoodlePressStyle: ButtonStyle {
    let rotation: Double

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .rotationEffect(.degrees(configuration.isPressed ? rotation * -0.4 : 0))
            .animation(.spring(response: 0.24, dampingFraction: 0.68), value: configuration.isPressed)
    }
}

private enum DoodleTheme {
    static let ink = Color(red: 0.10, green: 0.10, blue: 0.11)
    static let paper = Color(red: 0.94, green: 0.92, blue: 0.86)
    static let paperBright = Color(red: 1.00, green: 0.99, blue: 0.95)
    static let yellow = Color(red: 1.00, green: 0.82, blue: 0.23)
    static let mint = Color(red: 0.39, green: 0.82, blue: 0.62)
    static let coral = Color(red: 0.96, green: 0.42, blue: 0.36)
    static let blue = Color(red: 0.37, green: 0.68, blue: 0.92)
}

#Preview {
    HomeView()
        .environmentObject(AppRouter())
}
