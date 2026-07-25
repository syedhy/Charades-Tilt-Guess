import SwiftUI
import UIKit

@main
struct CharadesTiltGuessApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var router = AppRouter()
    @StateObject private var settingsViewModel = SettingsViewModel()

    var body: some Scene {
        WindowGroup {
            AppShellView()
                .environmentObject(router)
                .environmentObject(settingsViewModel)
        }
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        OrientationController.shared.supportedOrientations
    }
}

@MainActor
final class OrientationController {
    static let shared = OrientationController()

    private(set) var supportedOrientations: UIInterfaceOrientationMask = .portrait

    private init() {}

    func useMenuPortrait() {
        updateSupportedOrientations(.portrait, requestedOrientation: .portrait)
    }

    func useGameplayLandscape() {
        updateSupportedOrientations([.landscapeLeft, .landscapeRight], requestedOrientation: .landscape)
    }

    private func updateSupportedOrientations(
        _ orientations: UIInterfaceOrientationMask,
        requestedOrientation: UIInterfaceOrientationMask
    ) {
        supportedOrientations = orientations

        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first else {
            return
        }

        var topController = windowScene.windows.first?.rootViewController
        while let presented = topController?.presentedViewController {
            topController = presented
        }
        topController?.setNeedsUpdateOfSupportedInterfaceOrientations()
        windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: requestedOrientation)) { _ in }
    }
}
