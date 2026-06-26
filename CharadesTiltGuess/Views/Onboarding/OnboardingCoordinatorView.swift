import SwiftUI

enum OnboardingStep {
    case splash
    case interactive
    case dismissing
}

struct OnboardingCoordinatorView: View {
    let onDone: () -> Void
    @State private var step: OnboardingStep = .splash

    var body: some View {
        ZStack {
            if step == .splash {
                OnboardingSplashView(
                    onSkip: onDone,
                    onContinue: {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            step = .interactive
                        }
                    }
                )
                .transition(.opacity)
            } else if step == .interactive {
                OnboardingView(onDone: {
                    step = .dismissing
                    onDone()
                })
                .transition(.opacity)
            } else {
                DoodlePaperBackground()
                    .ignoresSafeArea()
            }
        }
    }
}
