import SwiftUI

struct PlaceholderScreen: View {
    let eyebrow: String
    let title: String
    let message: String
    let symbol: String
    let accent: Color
    var primaryActionTitle: String?
    var primaryAction: (() -> Void)?
    var secondaryActionTitle: String?
    var secondaryAction: (() -> Void)?

    var body: some View {
        ZStack {
            DoodlePaperBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    Text(eyebrow)
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.ink.opacity(0.58))

                    VStack(alignment: .leading, spacing: 16) {
                        Image(systemName: symbol)
                            .font(.system(size: 54, weight: .black))
                            .foregroundStyle(AppTheme.Colors.ink)
                            .frame(width: 104, height: 104)
                            .background(accent, in: Circle())
                            .overlay(Circle().stroke(AppTheme.Colors.ink, lineWidth: AppTheme.Stroke.bold))
                            .rotationEffect(.degrees(-4))
                            .shadow(color: AppTheme.Colors.ink.opacity(0.18), radius: 0, x: 5, y: 6)

                        Text(title)
                            .font(.system(size: 38, weight: .black, design: .rounded))
                            .foregroundStyle(AppTheme.Colors.ink)
                            .fixedSize(horizontal: false, vertical: true)
                            .accessibilityIdentifier("placeholderTitle")

                        Text(message)
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.Colors.ink.opacity(0.62))
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    VStack(spacing: 12) {
                        if let primaryActionTitle, let primaryAction {
                            DoodleActionButton(
                                title: primaryActionTitle,
                                accent: accent,
                                action: primaryAction
                            )
                        }

                        if let secondaryActionTitle, let secondaryAction {
                            DoodleActionButton(
                                title: secondaryActionTitle,
                                accent: AppTheme.Colors.paperBright,
                                action: secondaryAction
                            )
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(24)
            }
            .scrollIndicators(.hidden)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

