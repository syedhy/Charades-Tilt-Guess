import SwiftUI

struct ResultsView: View {
    let result: RoundResult
    let onPlayAgain: () -> Void
    let onChooseDeck: () -> Void

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                DoodlePaperBackground()

                VStack(alignment: .leading, spacing: 10) {
                    scoreHeader
                    cardSection
                        .frame(maxHeight: .infinity)
                        .layoutPriority(1)

                    actionButtons
                }
                .padding(.horizontal, 20)
                .padding(.top, min(max(proxy.safeAreaInsets.top - 20, 12), 28))
                .padding(.bottom, 16)
            }
        }
        .navigationBarBackButtonHidden(true)
        .preferredColorScheme(.light)
    }

    private var scoreHeader: some View {
        DoodlePanel(background: result.deck.color.displayColor) {
            HStack(alignment: .center, spacing: 16) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(result.title)
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.ink.opacity(0.62))
                        .lineLimit(1)

                    Text(result.subtitle)
                        .font(.system(size: 21, weight: .black, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.ink)
                        .lineLimit(1)
                        .minimumScaleFactor(0.58)
                }
                .layoutPriority(1)

                Spacer()

                VStack(alignment: .trailing, spacing: 0) {
                    Text(scoreText)
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.ink)
                        .monospacedDigit()
                        .lineLimit(1)
                        .minimumScaleFactor(0.46)
                        .accessibilityIdentifier("finalScore")

                    Text("score")
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.ink.opacity(0.58))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .frame(minHeight: 108)
        }
    }

    private var scoreText: String {
        "\(result.correctWords.count)/\(max(result.cardsSeen, result.totalAttempted))"
    }

    private var cardSection: some View {
        DoodlePanel {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("Cards")
                        .font(.system(size: 27, weight: .black, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.ink)

                    Spacer()

                    Text("\(result.totalAttempted)")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundStyle(result.deck.color.displayColor)
                        .monospacedDigit()
                }

                ScrollView {
                    if cardEntries.isEmpty {
                        Text("No cards played yet.")
                            .font(.system(size: 21, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.Colors.ink.opacity(0.54))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 8)
                    } else {
                        LazyVStack(alignment: .leading, spacing: 8) {
                            ForEach(cardEntries) { entry in
                                ResultWordRow(entry: entry)
                            }
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
            .padding(16)
            .frame(maxHeight: .infinity)
        }
    }

    private var cardEntries: [ResultCardEntry] {
        if !result.attempts.isEmpty {
            return result.attempts.map { attempt in
                ResultCardEntry(word: attempt.word, status: attempt.status, id: attempt.id)
            }
        }

        let correctEntries = result.correctWords.map { ResultCardEntry(word: $0, status: .correct, id: "correct-\($0.id)") }
        let passedEntries = result.passedWords.map { ResultCardEntry(word: $0, status: .passed, id: "passed-\($0.id)") }
        return correctEntries + passedEntries
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

}

private struct ResultCardEntry: Identifiable {
    let word: GameWord
    let status: WordStatus
    let id: String
}

private struct ResultWordRow: View {
    let entry: ResultCardEntry

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: entry.status == .correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 22, weight: .black))
                .foregroundStyle(entry.status == .correct ? AppTheme.Colors.mint : AppTheme.Colors.coral)

            Text(entry.word.text)
                .font(.system(size: 25, weight: .black, design: .rounded))
                .strikethrough(entry.status == .passed, color: AppTheme.Colors.coral)
                .foregroundStyle(AppTheme.Colors.ink.opacity(entry.status == .passed ? 0.58 : 1))
                .lineLimit(1)
                .minimumScaleFactor(0.64)

            Spacer(minLength: 0)
        }
        .padding(.vertical, 3)
    }
}
