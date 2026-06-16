import SwiftUI

struct ResultsView: View {
    let result: RoundResult
    let onPlayAgain: () -> Void
    let onChooseDeck: () -> Void

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                DoodlePaperBackground()

                VStack(alignment: .leading, spacing: 12) {
                    scoreHeader
                    statGrid

                    VStack(spacing: 12) {
                        wordSection(
                            title: "Correct Cards",
                            words: result.correctWords,
                            accent: AppTheme.Colors.mint,
                            emptyText: "No correct cards yet.",
                            height: listHeight(for: proxy.size.height)
                        )

                        wordSection(
                            title: "Passed Cards",
                            words: result.passedWords,
                            accent: AppTheme.Colors.coral,
                            emptyText: "No passes this round.",
                            height: listHeight(for: proxy.size.height)
                        )
                    }

                    Spacer(minLength: 0)

                    actionButtons
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 20)
            }
        }
        .navigationBarBackButtonHidden(true)
        .preferredColorScheme(.light)
    }

    private var scoreHeader: some View {
        DoodlePanel(background: result.deck.color.displayColor) {
            HStack(alignment: .center, spacing: 18) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(result.title)
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.ink.opacity(0.62))

                    Text(result.subtitle)
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.ink)
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                }

                Spacer()

                VStack(spacing: 0) {
                    Text("\(result.finalScore)")
                        .font(.system(size: 70, weight: .black, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.ink)
                        .monospacedDigit()
                        .accessibilityIdentifier("finalScore")

                    Text("score")
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.ink.opacity(0.58))
                }
            }
            .padding(20)
            .frame(height: 132)
        }
    }

    private var statGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
            statCard(title: "Correct", value: "\(result.correctWords.count)", accent: AppTheme.Colors.mint)
            statCard(title: "Passed", value: "\(result.passedWords.count)", accent: AppTheme.Colors.coral)
            statCard(title: "Accuracy", value: "\(result.accuracyPercentage)%", accent: AppTheme.Colors.yellow)
            statCard(title: "Seen", value: "\(result.cardsSeen)", accent: AppTheme.Colors.blue)
            statCard(title: "Time", value: timeUsedText, accent: AppTheme.Colors.orange)
            statCard(title: "Tried", value: "\(result.totalAttempted)", accent: result.deck.color.displayColor)
            statCard(title: "Best", value: "\(result.bestStreak)", accent: AppTheme.Colors.mint)
            statCard(title: "Streak", value: "\(result.longestCorrectStreak)", accent: AppTheme.Colors.yellow)
        }
    }

    private func statCard(title: String, value: String, accent: Color) -> some View {
        DoodlePanel(background: AppTheme.Colors.paperBright, cornerRadius: 14) {
            VStack(alignment: .leading, spacing: 3) {
                Text(value)
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundStyle(accent)
                    .lineLimit(1)
                    .minimumScaleFactor(0.62)
                    .monospacedDigit()

                Text(title)
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink.opacity(0.56))
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            .frame(height: 70)
        }
    }

    private func wordSection(title: String, words: [GameWord], accent: Color, emptyText: String, height: CGFloat) -> some View {
        DoodlePanel {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(title)
                        .font(.system(size: 21, weight: .black, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.ink)

                    Spacer()

                    Text("\(words.count)")
                        .font(.system(size: 17, weight: .black, design: .rounded))
                        .foregroundStyle(accent)
                        .monospacedDigit()
                }

                ScrollView {
                    if words.isEmpty {
                        Text(emptyText)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.Colors.ink.opacity(0.54))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 8)
                    } else {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                            ForEach(words) { word in
                                Text(word.text)
                                    .font(.system(size: 14, weight: .black, design: .rounded))
                                    .foregroundStyle(AppTheme.Colors.ink)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.65)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 10)
                                    .background(accent.opacity(0.24), in: Capsule())
                                    .overlay {
                                        Capsule()
                                            .stroke(AppTheme.Colors.ink.opacity(0.28), lineWidth: 2)
                                    }
                            }
                        }
                    }
                }
                .scrollIndicators(.visible)
            }
            .padding(16)
            .frame(height: height)
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 10) {
            DoodleActionButton(
                title: "Play again",
                symbol: "arrow.clockwise",
                accent: result.deck.color.displayColor,
                action: onPlayAgain
            )

            DoodleActionButton(
                title: "Choose another mode",
                symbol: "rectangle.stack.fill",
                accent: AppTheme.Colors.paperBright,
                action: onChooseDeck
            )
        }
    }

    private var timeUsedText: String {
        guard result.timeUsed > 0 else { return result.mode == .infinite ? "0s" : "\(result.duration)s" }
        return "\(result.timeUsed)s"
    }

    private func listHeight(for availableHeight: CGFloat) -> CGFloat {
        availableHeight > 800 ? 156 : 132
    }
}
