import SwiftUI

struct GameSetupView: View {
    let deck: Deck
    let settings: GameSettings
    let onStartRound: (Int) -> Void

    @State private var selectedDuration = 60

    private let durations = GameSettings.availableDurations
    private var canStart: Bool { !deck.cards.isEmpty }

    var body: some View {
        ZStack {
            DoodlePaperBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.roomy) {
                    header
                    durationPicker
                    instructionPanel

                    DoodleActionButton(
                        title: canStart ? "Start round" : "Add cards first",
                        symbol: "play.fill",
                        accent: deck.color.displayColor
                    ) {
                        guard canStart else { return }
                        onStartRound(selectedDuration)
                    }
                    .opacity(canStart ? 1 : 0.48)
                    .disabled(!canStart)
                    .accessibilityIdentifier("startRoundButton")
                }
                .padding(24)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle("Game Setup")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.light)
        .onAppear {
            selectedDuration = settings.defaultDuration
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(deck.name)
                .font(.system(size: 44, weight: .black, design: .rounded))
                .foregroundStyle(AppTheme.Colors.ink)
                .lineLimit(2)
                .minimumScaleFactor(0.72)

            HStack(spacing: 10) {
                Label("\(deck.cards.count) cards", systemImage: "rectangle.stack.fill")
                Label("\(settings.tiltSensitivity.displayName) tilt", systemImage: "iphone.gen3.radiowaves.left.and.right")
            }
            .font(.system(size: 14, weight: .black, design: .rounded))
            .foregroundStyle(AppTheme.Colors.ink.opacity(0.58))
        }
    }

    private var durationPicker: some View {
        DoodlePanel {
            VStack(alignment: .leading, spacing: 16) {
                Text("Round length")
                    .font(.system(size: 24, weight: .black, design: .rounded))

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                    ForEach(durations, id: \.self) { duration in
                        Button {
                            selectedDuration = duration
                        } label: {
                            Text("\(duration)s")
                                .font(.system(size: 22, weight: .black, design: .rounded))
                                .foregroundStyle(AppTheme.Colors.ink)
                                .frame(maxWidth: .infinity)
                                .frame(height: 58)
                                .background(
                                    selectedDuration == duration ? deck.color.displayColor : AppTheme.Colors.paper,
                                    in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                                )
                                .overlay {
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(AppTheme.Colors.ink, lineWidth: AppTheme.Stroke.standard)
                                }
                        }
                        .buttonStyle(DoodlePressStyle())
                    }
                }
            }
            .padding(20)
        }
    }

    private var instructionPanel: some View {
        DoodlePanel(background: deck.color.displayColor) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Place the device on your forehead")
                    .font(.system(size: 31, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink)
                    .fixedSize(horizontal: false, vertical: true)

                VStack(alignment: .leading, spacing: 10) {
                    instructionRow(symbol: "checkmark.circle.fill", text: "Tilt down or tap Correct")
                    instructionRow(symbol: "arrow.uturn.forward.circle.fill", text: "Tilt up or tap Pass")
                    instructionRow(symbol: "pause.circle.fill", text: "Pause anytime")
                }
            }
            .padding(22)
        }
    }

    private func instructionRow(symbol: String, text: String) -> some View {
        Label(text, systemImage: symbol)
            .font(.system(size: 16, weight: .black, design: .rounded))
            .foregroundStyle(AppTheme.Colors.ink.opacity(0.72))
    }
}
