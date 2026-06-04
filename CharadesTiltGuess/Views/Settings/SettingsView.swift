import SwiftUI

struct SettingsView: View {
    var body: some View {
        PlaceholderScreen(
            eyebrow: "SETTINGS",
            title: "Settings placeholder",
            message: "Round duration, haptics, and tilt sensitivity will live here once those systems exist.",
            symbol: "gearshape.2",
            accent: Color(red: 0.37, green: 0.68, blue: 0.92)
        )
        .navigationTitle("Settings")
    }
}

