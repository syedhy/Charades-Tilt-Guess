import SwiftUI

@main
struct CharadesTiltGuessApp: App {
    @StateObject private var router = AppRouter()

    var body: some Scene {
        WindowGroup {
            AppShellView()
                .environmentObject(router)
        }
    }
}
