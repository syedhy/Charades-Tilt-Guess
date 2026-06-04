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
            PlaceholderPaperBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    Text(eyebrow)
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .foregroundStyle(.black.opacity(0.58))

                    VStack(alignment: .leading, spacing: 16) {
                        Image(systemName: symbol)
                            .font(.system(size: 54, weight: .black))
                            .foregroundStyle(.black)
                            .frame(width: 104, height: 104)
                            .background(accent, in: Circle())
                            .overlay(Circle().stroke(.black, lineWidth: 4))
                            .rotationEffect(.degrees(-4))
                            .shadow(color: .black.opacity(0.18), radius: 0, x: 5, y: 6)

                        Text(title)
                            .font(.system(size: 38, weight: .black, design: .rounded))
                            .foregroundStyle(.black)
                            .fixedSize(horizontal: false, vertical: true)
                            .accessibilityIdentifier("placeholderTitle")

                        Text(message)
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundStyle(.black.opacity(0.62))
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    VStack(spacing: 12) {
                        if let primaryActionTitle, let primaryAction {
                            PlaceholderButton(
                                title: primaryActionTitle,
                                accent: accent,
                                action: primaryAction
                            )
                        }

                        if let secondaryActionTitle, let secondaryAction {
                            PlaceholderButton(
                                title: secondaryActionTitle,
                                accent: .white,
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

private struct PlaceholderButton: View {
    let title: String
    let accent: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 17, weight: .black, design: .rounded))

                Spacer()

                Image(systemName: "arrow.right")
                    .font(.system(size: 17, weight: .black))
            }
            .foregroundStyle(.black)
            .padding(.horizontal, 18)
            .frame(height: 58)
            .background(accent, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(.black, lineWidth: 3)
            }
            .shadow(color: .black.opacity(0.16), radius: 0, x: 4, y: 5)
        }
        .buttonStyle(.plain)
    }
}

struct PlaceholderPaperBackground: View {
    var body: some View {
        ZStack {
            Color(red: 0.94, green: 0.92, blue: 0.86)
                .ignoresSafeArea()

            Canvas { context, size in
                let lineColor = Color.black.opacity(0.045)

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

