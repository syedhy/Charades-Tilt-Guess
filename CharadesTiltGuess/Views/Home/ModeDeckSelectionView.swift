import SwiftUI

struct ModeDeckSelectionView: View {
    @EnvironmentObject private var router: AppRouter
    @StateObject private var viewModel = HomeViewModel()
    @State private var isShowingInstructions = false

    let mode: GameMode

    var body: some View {
        ZStack {
            DoodlePaperBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.roomy) {
                    header

                    if let loadErrorMessage = viewModel.loadErrorMessage {
                        deckLoadError(message: loadErrorMessage)
                    } else {
                        deckSections
                    }
                }
                .padding(24)
                .padding(.bottom, 32)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle(mode.title)
        .navigationBarTitleDisplayMode(.inline)
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
        .preferredColorScheme(.light)
        .onAppear {
            viewModel.loadDecks()
        }
    }

    private var header: some View {
        DoodlePanel(background: mode.accentColor) {
            VStack(alignment: .leading, spacing: 14) {
                Label(mode.purpose.uppercased(), systemImage: mode.symbolName)
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink.opacity(0.64))

                Text("Choose a deck")
                    .font(.system(size: 40, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink)

                Text(mode.description)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink.opacity(0.68))
            }
            .padding(22)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var deckSections: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.roomy) {
            if !viewModel.customDecks.isEmpty {
                deckSection(title: "Custom Decks", decks: viewModel.customDecks)
            }

            deckSection(title: "Built-In Decks", decks: viewModel.defaultDecks)

            DoodleActionButton(title: "Add custom deck", symbol: "plus", accent: AppTheme.Colors.paperBright) {
                router.openImmediately(.deckEditor)
            }
        }
    }

    private func deckSection(title: String, decks: [Deck]) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.system(size: 25, weight: .black, design: .rounded))
                .foregroundStyle(AppTheme.Colors.ink)

            if decks.isEmpty {
                DoodlePanel {
                    Text(title == "Custom Decks" ? "Create a deck to see it here." : "Built-in decks could not be loaded.")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.ink.opacity(0.58))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(18)
                }
            } else {
                DeckGridView(decks: decks) { deck in
                    router.open(.gameSetup(mode: mode, deck: deck))
                }
            }
        }
    }

    private func deckLoadError(message: String) -> some View {
        DoodlePanel(cornerRadius: AppTheme.Radius.card) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.standard) {
                Text("Decks took a wrong turn")
                    .font(.system(size: 19, weight: .black, design: .rounded))

                Text(message)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink.opacity(0.62))

                DoodleActionButton(
                    title: "Try loading again",
                    symbol: "arrow.clockwise",
                    accent: AppTheme.Colors.yellow,
                    action: viewModel.loadDecks
                )
            }
            .foregroundStyle(AppTheme.Colors.ink)
            .padding(AppTheme.Spacing.standard)
        }
    }
}

#Preview {
    NavigationStack {
        ModeDeckSelectionView(mode: .normal)
            .environmentObject(AppRouter())
    }
}
