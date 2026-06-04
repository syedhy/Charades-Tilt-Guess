import SwiftUI

struct DoodlePanel<Content: View>: View {
    let background: Color
    let cornerRadius: CGFloat
    @ViewBuilder let content: Content

    init(
        background: Color = AppTheme.Colors.paperBright,
        cornerRadius: CGFloat = AppTheme.Radius.panel,
        @ViewBuilder content: () -> Content
    ) {
        self.background = background
        self.cornerRadius = cornerRadius
        self.content = content()
    }

    var body: some View {
        content
            .background {
                DoodlePanelBackground(background: background, cornerRadius: cornerRadius)
            }
    }
}

struct DoodlePanelBackground: View {
    let background: Color
    let cornerRadius: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(background)

            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(AppTheme.Colors.ink.opacity(0.25), lineWidth: 2)
                .offset(x: 2, y: -1)
                .rotationEffect(.degrees(0.35))

            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(AppTheme.Colors.ink, lineWidth: AppTheme.Stroke.standard)
        }
        .shadow(color: AppTheme.Colors.ink.opacity(0.15), radius: 0, x: 5, y: 6)
    }
}

#Preview {
    DoodlePanel {
        Text("Doodle panel")
            .font(.system(size: 24, weight: .black, design: .rounded))
            .padding(AppTheme.Spacing.roomy)
    }
    .padding()
    .background(DoodlePaperBackground())
}
