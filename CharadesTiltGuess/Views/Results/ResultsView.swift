import SwiftUI

struct ResultsView: View {
    let result: RoundResult
    let onPlayAgain: () -> Void
    let onChooseDeck: () -> Void

    var body: some View {
        ZStack {
            DoodlePaperBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.roomy) {
                    scoreHeader
                    statGrid
                    wordSection(title: "Correct", words: result.correctWords, accent: AppTheme.Colors.mint)
                    wordSection(title: "Passed", words: result.passedWords, accent: AppTheme.Colors.coral)

                    VStack(spacing: 12) {
                        DoodleActionButton(
                            title: "Play again",
                            symbol: "arrow.clockwise",
                            accent: result.deck.color.displayColor,
                            action: onPlayAgain
                        )

                        DoodleActionButton(
                            title: "Choose another deck",
                            symbol: "rectangle.stack.fill",
                            accent: AppTheme.Colors.paperBright,
                            action: onChooseDeck
                        )
                    }
                }
                .padding(24)
            }
            .scrollIndicators(.hidden)
        }
        .navigationBarBackButtonHidden(true)
        .preferredColorScheme(.light)
    }

    private var scoreHeader: some View {
        DoodlePanel(background: result.deck.color.displayColor) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Round complete")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink.opacity(0.62))

                Text("\(result.finalScore)")
                    .font(.system(size: 86, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink)
                    .monospacedDigit()
                    .accessibilityIdentifier("finalScore")

                Text(result.deck.name)
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var statGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
            statCard(title: "Correct", value: result.correctWords.count, accent: AppTheme.Colors.mint)
            statCard(title: "Passed", value: result.passedWords.count, accent: AppTheme.Colors.coral)
            statCard(title: "Tried", value: result.totalAttempted, accent: AppTheme.Colors.yellow)
        }
    }

    private func statCard(title: String, value: Int, accent: Color) -> some View {
        DoodlePanel(background: AppTheme.Colors.paperBright, cornerRadius: 18) {
            VStack(alignment: .leading, spacing: 6) {
                Text("\(value)")
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundStyle(accent)
                    .monospacedDigit()

                Text(title)
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink.opacity(0.58))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
        }
    }

    private func wordSection(title: String, words: [GameWord], accent: Color) -> some View {
        DoodlePanel {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text(title)
                        .font(.system(size: 26, weight: .black, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.ink)

                    Spacer()

                    Text("\(words.count)")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundStyle(accent)
                        .monospacedDigit()
                }

                if words.isEmpty {
                    Text("Nothing here yet.")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.ink.opacity(0.54))
                } else {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(words) { word in
                            Text(word.text)
                                .font(.system(size: 15, weight: .black, design: .rounded))
                                .foregroundStyle(AppTheme.Colors.ink)
                                .lineLimit(1)
                                .minimumScaleFactor(0.65)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 9)
                                .padding(.horizontal, 12)
                                .background(accent.opacity(0.24), in: Capsule())
                                .overlay {
                                    Capsule()
                                        .stroke(AppTheme.Colors.ink.opacity(0.28), lineWidth: 2)
                                }
                        }
                    }
                }
            }
            .padding(18)
        }
    }
}
