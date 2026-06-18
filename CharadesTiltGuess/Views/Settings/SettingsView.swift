import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var viewModel: SettingsViewModel
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        ZStack {
            DoodlePaperBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.roomy) {
                    header
                    durationSection
                    feedbackSection
                    controlsSection
                    sensitivitySection
                    onboardingSection
                }
                .padding(24)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.light)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Game defaults")
                .font(.system(size: 40, weight: .black, design: .rounded))
                .foregroundStyle(AppTheme.Colors.ink)

            Text("These apply to new rounds.")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.Colors.ink.opacity(0.58))
        }
    }

    private var durationSection: some View {
        settingsPanel(title: "Round length", symbol: "timer", accent: AppTheme.Colors.yellow) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                ForEach(GameSettings.availableDurations, id: \.self) { duration in
                    Button {
                        viewModel.setDefaultDuration(duration)
                    } label: {
                        optionLabel(
                            title: "\(duration)s",
                            isSelected: viewModel.settings.defaultDuration == duration,
                            accent: AppTheme.Colors.yellow
                        )
                    }
                    .buttonStyle(DoodlePressStyle(rotation: 0))
                }
            }
        }
    }

    private var feedbackSection: some View {
        settingsPanel(title: "Feedback", symbol: "waveform", accent: AppTheme.Colors.mint) {
            VStack(spacing: 14) {
                toggleRow(
                    title: "Sounds",
                    subtitle: "Countdowns and game effects",
                    isOn: Binding(
                        get: { viewModel.settings.soundsEnabled },
                        set: { viewModel.setSoundsEnabled($0) }
                    ),
                    tint: AppTheme.Colors.yellow
                )

                toggleRow(
                    title: "Haptics",
                    subtitle: "Stronger taps during play",
                    isOn: Binding(
                        get: { viewModel.settings.hapticsEnabled },
                        set: { viewModel.setHapticsEnabled($0) }
                    ),
                    tint: AppTheme.Colors.mint
                )
            }
        }
    }

    private var controlsSection: some View {
        settingsPanel(title: "Controls", symbol: "hand.draw.fill", accent: AppTheme.Colors.coral) {
            VStack(spacing: 14) {
                toggleRow(
                    title: "Motion controls",
                    subtitle: "Tilt down for correct, up to pass",
                    isOn: Binding(
                        get: { viewModel.settings.motionControlsEnabled },
                        set: { viewModel.setMotionControlsEnabled($0) }
                    ),
                    tint: AppTheme.Colors.coral
                )

                toggleRow(
                    title: "Swipe controls",
                    subtitle: "Swipe down for correct, up to pass",
                    isOn: Binding(
                        get: { viewModel.settings.effectiveSwipeControlsEnabled },
                        set: { viewModel.setSwipeControlsEnabled($0) }
                    ),
                    tint: AppTheme.Colors.blue
                )
            }
        }
    }

    private var sensitivitySection: some View {
        settingsPanel(
            title: "Tilt sensitivity",
            symbol: "iphone.gen3.radiowaves.left.and.right",
            accent: AppTheme.Colors.blue
        ) {
            VStack(spacing: 12) {
                ForEach(TiltSensitivity.allCases) { sensitivity in
                    Button {
                        viewModel.setTiltSensitivity(sensitivity)
                    } label: {
                        optionLabel(
                            title: sensitivity.displayName,
                            isSelected: viewModel.settings.tiltSensitivity == sensitivity,
                            accent: AppTheme.Colors.blue
                        )
                    }
                    .buttonStyle(DoodlePressStyle(rotation: 0))
                }
            }
        }
    }

    private var onboardingSection: some View {
        settingsPanel(title: "Onboarding", symbol: "sparkles", accent: AppTheme.Colors.orange) {
            DoodleActionButton(title: "Replay how to play", symbol: "play.rectangle.fill", accent: AppTheme.Colors.orange) {
                router.open(.onboarding)
            }
        }
    }

    private func settingsPanel<Content: View>(
        title: String,
        symbol: String,
        accent: Color,
        @ViewBuilder content: () -> Content
    ) -> some View {
        DoodlePanel {
            VStack(alignment: .leading, spacing: 18) {
                Label(title, systemImage: symbol)
                    .font(.system(size: 23, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink)

                content()
            }
            .padding(20)
        }
    }

    private func optionLabel(title: String, isSelected: Bool, accent: Color) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 18, weight: .black, design: .rounded))

            Spacer()

            if isSelected {
                Image(systemName: "checkmark")
                    .font(.system(size: 16, weight: .black))
            }
        }
        .foregroundStyle(AppTheme.Colors.ink)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .frame(height: 52)
        .background(isSelected ? accent : AppTheme.Colors.paper, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(AppTheme.Colors.ink, lineWidth: AppTheme.Stroke.standard)
        }
    }

    private func toggleRow(title: String, subtitle: String, isOn: Binding<Bool>, tint: Color) -> some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink)

                Text(subtitle)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink.opacity(0.55))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            Toggle(title, isOn: isOn)
                .labelsHidden()
                .toggleStyle(.switch)
                .tint(tint)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(AppTheme.Colors.paper, in: RoundedRectangle(cornerRadius: AppTheme.Radius.button, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: AppTheme.Radius.button, style: .continuous)
                .stroke(AppTheme.Colors.ink, lineWidth: 2)
        }
    }
}
