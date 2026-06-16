import SwiftUI

struct GameSetupView: View {
    let mode: GameMode
    let deck: Deck
    let settings: GameSettings
    let onStartRound: (GameConfiguration) -> Void

    @State private var selectedDuration = 60
    @State private var isShowingInstructions = false

    private let durations = GameSettings.availableDurations
    private var canStart: Bool { !deck.cards.isEmpty }

    var body: some View {
        ZStack {
            DoodlePaperBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.roomy) {
                    header
                    if mode.showsDurationPicker {
                        durationPicker
                    }
                    instructionPanel

                    DoodleActionButton(
                        title: canStart ? startButtonTitle : "Add cards first",
                        symbol: "play.fill",
                        accent: mode.accentColor
                    ) {
                        guard canStart else { return }
                        onStartRound(makeConfiguration())
                    }
                    .opacity(canStart ? 1 : 0.48)
                    .disabled(!canStart)
                    .accessibilityIdentifier("startRoundButton")
                }
                .padding(24)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle(mode.title)
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.light)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isShowingInstructions = true
                } label: {
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 18, weight: .black))
                        .foregroundStyle(AppTheme.Colors.ink)
                }
                .accessibilityLabel("\(mode.title) instructions")
            }
        }
        .sheet(isPresented: $isShowingInstructions) {
            ModeInstructionsView(mode: mode)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .onAppear {
            selectedDuration = settings.defaultDuration
        }
    }

    private var startButtonTitle: String {
        switch mode {
        case .infinite:
            return "Start infinite round"
        case .hotPotato:
            return "Start hidden timer"
        default:
            return "Start round"
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
                Label(mode.title, systemImage: mode.symbolName)
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
                    instructionRow(symbol: "checkmark.circle.fill", text: "Tilt down or swipe down for Correct")
                    instructionRow(symbol: "arrow.uturn.forward.circle.fill", text: "Tilt up or swipe up to Pass")
                    instructionRow(symbol: "pause.circle.fill", text: mode == .hotPotato ? "The timer is hidden" : "Pause anytime")
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

    private func makeConfiguration() -> GameConfiguration {
        switch mode {
        case .normal:
            return .normal(deck: deck, duration: selectedDuration)
        case .infinite:
            return .infinite(deck: deck)
        case .hotPotato:
            return .hotPotato(deck: deck, hiddenDuration: Int.random(in: 35...90))
        case .challengeCards:
            return .challengeCards(deck: deck, duration: selectedDuration)
        case .pasteAndPlay:
            return .pasteAndPlay(deck: deck, duration: selectedDuration)
        case .wikipedia:
            return .wikipedia(deck: deck, duration: selectedDuration)
        }
    }
}
