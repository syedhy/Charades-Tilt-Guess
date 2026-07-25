import SwiftUI

struct DeckCardView: View {
    let name: String
    let detail: String
    let symbol: String
    let accent: Color
    var rotation: Double = 0

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            DoodlePanelBackground(
                background: AppTheme.Colors.paperBright,
                cornerRadius: AppTheme.Radius.card
            )

            Rectangle()
                .fill(accent)
                .frame(height: 14)
                .clipShape(
                    UnevenRoundedRectangle(
                        bottomLeadingRadius: 15,
                        bottomTrailingRadius: 15
                    )
                )
                .padding(4)

            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: symbol)
                    .font(.system(size: 22, weight: .black))

                Spacer()

                Text(name)
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .lineLimit(2)
                    .minimumScaleFactor(0.72)

                Text(detail.uppercased())
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink.opacity(0.56))
                    .lineLimit(1)
            }
            .foregroundStyle(AppTheme.Colors.ink)
            .padding(AppTheme.Spacing.standard)
            .padding(.bottom, AppTheme.Spacing.compact)
        }
        .frame(height: 148)
        .rotationEffect(.degrees(rotation))
    }
}

#Preview {
    DeckCardView(
        name: "Movie Night",
        detail: "42 prompts",
        symbol: "popcorn",
        accent: AppTheme.Colors.yellow,
        rotation: 1
    )
    .frame(width: 180)
    .padding()
    .background(DoodlePaperBackground())
}
