import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var viewModel: SettingsViewModel

    var body: some View {
        ZStack {
            DoodlePaperBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.roomy) {
                    header
                    durationSection
                    hapticsSection
                    sensitivitySection
                }
                .padding(24)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle("Settings")
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

    private var hapticsSection: some View {
        settingsPanel(title: "Haptics", symbol: "waveform", accent: AppTheme.Colors.mint) {
            Toggle(
                isOn: Binding(
                    get: { viewModel.settings.hapticsEnabled },
                    set: { viewModel.setHapticsEnabled($0) }
                )
            ) {
                Text("Feedback taps")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink)
            }
            .toggleStyle(.switch)
            .tint(AppTheme.Colors.mint)
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
        .overlay(alignment: .topTrailing) {
            Circle()
                .fill(accent)
                .frame(width: 18, height: 18)
                .overlay(Circle().stroke(AppTheme.Colors.ink, lineWidth: 3))
                .padding(18)
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
}
