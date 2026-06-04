import SwiftUI

enum AppTheme {
    enum Colors {
        static let ink = Color(red: 0.10, green: 0.10, blue: 0.11)
        static let paper = Color(red: 0.94, green: 0.92, blue: 0.86)
        static let paperBright = Color(red: 1.00, green: 0.99, blue: 0.95)
        static let yellow = Color(red: 1.00, green: 0.82, blue: 0.23)
        static let mint = Color(red: 0.39, green: 0.82, blue: 0.62)
        static let coral = Color(red: 0.96, green: 0.42, blue: 0.36)
        static let blue = Color(red: 0.37, green: 0.68, blue: 0.92)
    }

    enum Spacing {
        static let compact: CGFloat = 8
        static let standard: CGFloat = 16
        static let roomy: CGFloat = 24
        static let section: CGFloat = 30
    }

    enum Radius {
        static let button: CGFloat = 16
        static let card: CGFloat = 18
        static let panel: CGFloat = 24
    }

    enum Stroke {
        static let standard: CGFloat = 3
        static let bold: CGFloat = 4
    }
}

extension DeckColor {
    var displayColor: Color {
        switch self {
        case .yellow:
            AppTheme.Colors.yellow
        case .mint:
            AppTheme.Colors.mint
        case .coral:
            AppTheme.Colors.coral
        case .blue:
            AppTheme.Colors.blue
        case .purple:
            Color(red: 0.57, green: 0.40, blue: 0.88)
        case .pink:
            Color(red: 0.92, green: 0.43, blue: 0.66)
        case .gray:
            Color(red: 0.68, green: 0.68, blue: 0.65)
        }
    }
}
