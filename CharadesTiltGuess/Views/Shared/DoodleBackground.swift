import SwiftUI

struct DoodlePaperBackground: View {
    var body: some View {
        ZStack {
            AppTheme.Colors.paper
                .ignoresSafeArea()

            Canvas { context, size in
                let lineColor = AppTheme.Colors.ink.opacity(0.045)

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
            .allowsHitTesting(false)
        }
    }
}

#Preview {
    DoodlePaperBackground()
}
