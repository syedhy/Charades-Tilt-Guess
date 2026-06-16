import SwiftUI

struct DoodleIconButton: View {
    let symbol: String
    var accent: Color = AppTheme.Colors.paperBright
    var size: CGFloat = 46
    let accessibilityLabel: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: size * 0.42, weight: .black))
                .foregroundStyle(AppTheme.Colors.ink)
                .frame(width: size, height: size)
                .background(accent, in: Circle())
                .overlay {
                    Circle()
                        .stroke(AppTheme.Colors.ink, lineWidth: AppTheme.Stroke.standard)
                        .rotationEffect(.degrees(-3))
                }
                .shadow(color: AppTheme.Colors.ink.opacity(0.16), radius: 0, x: 3, y: 3)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }
}

struct DoodleActionButton: View {
    let title: String
    var symbol: String? = "arrow.right"
    var accent: Color = AppTheme.Colors.yellow
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 17, weight: .black, design: .rounded))

                Spacer()

                if let symbol {
                    Image(systemName: symbol)
                        .font(.system(size: 17, weight: .black))
                }
            }
            .foregroundStyle(AppTheme.Colors.ink)
            .padding(.horizontal, 18)
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background {
                RoundedRectangle(cornerRadius: AppTheme.Radius.button, style: .continuous)
                    .fill(accent)
                    .shadow(color: AppTheme.Colors.ink.opacity(0.16), radius: 0, x: 4, y: 5)
            }
            .overlay {
                RoundedRectangle(cornerRadius: AppTheme.Radius.button, style: .continuous)
                    .stroke(AppTheme.Colors.ink, lineWidth: AppTheme.Stroke.standard)
            }
        }
        .buttonStyle(DoodlePressStyle())
    }
}

struct DoodlePressStyle: ButtonStyle {
    var rotation: Double = 0

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .rotationEffect(.degrees(configuration.isPressed ? rotation * -0.4 : 0))
            .animation(.spring(response: 0.24, dampingFraction: 0.68), value: configuration.isPressed)
    }
}

#Preview {
    VStack(spacing: AppTheme.Spacing.roomy) {
        DoodleIconButton(symbol: "gearshape", accessibilityLabel: "Settings") {}
        DoodleActionButton(title: "Start round") {}
    }
    .padding(AppTheme.Spacing.roomy)
    .background(DoodlePaperBackground())
}
