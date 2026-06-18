import SwiftUI

struct ModeInstructionsView: View {
    let mode: GameMode
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            DoodlePaperBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.roomy) {
                    header
                    rules
                    scoring
                }
                .padding(24)
            }
            .scrollIndicators(.hidden)
        }
        .preferredColorScheme(.light)
    }

    private var header: some View {
        DoodlePanel(background: mode.accentColor) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    Image(systemName: mode.symbolName)
                        .font(.system(size: 34, weight: .black))
                        .foregroundStyle(AppTheme.Colors.ink)
                        .frame(width: 72, height: 72)
                        .background(AppTheme.Colors.paperBright.opacity(0.78), in: Circle())
                        .overlay(Circle().stroke(AppTheme.Colors.ink, lineWidth: AppTheme.Stroke.standard))

                    Spacer()

                    DoodleIconButton(symbol: "xmark", size: 42, accessibilityLabel: "Close instructions") {
                        dismiss()
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(mode.instruction.title)
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.ink)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(mode.instruction.summary)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.ink.opacity(0.68))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(22)
        }
    }

    private var rules: some View {
        DoodlePanel {
            VStack(alignment: .leading, spacing: 16) {
                Label("Rules & controls", systemImage: "list.bullet.clipboard.fill")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink)

                ForEach(Array(mode.instruction.rules.enumerated()), id: \.offset) { index, rule in
                    HStack(alignment: .top, spacing: 12) {
                        Text("\(index + 1)")
                            .font(.system(size: 15, weight: .black, design: .rounded))
                            .foregroundStyle(AppTheme.Colors.ink)
                            .frame(width: 30, height: 30)
                            .background(mode.accentColor, in: Circle())
                            .overlay(Circle().stroke(AppTheme.Colors.ink, lineWidth: 2))

                        Text(rule)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.Colors.ink.opacity(0.72))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(20)
        }
    }

    private var scoring: some View {
        DoodlePanel(background: AppTheme.Colors.paperBright) {
            VStack(alignment: .leading, spacing: 10) {
                Label("Scoring", systemImage: "chart.bar.fill")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink)

                Text(mode.instruction.scoring)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink.opacity(0.68))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(20)
        }
    }
}

#Preview {
    ModeInstructionsView(mode: .challengeCards)
}
