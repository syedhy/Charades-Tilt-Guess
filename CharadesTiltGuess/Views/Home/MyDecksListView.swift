import SwiftUI

struct MyDecksListView: View {
    @EnvironmentObject private var router: AppRouter
    @StateObject private var viewModel = HomeViewModel()
    @State private var showingLimitAlert = false

    var body: some View {
        ZStack {
            DoodlePaperBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.roomy) {
                    header
                    customDecksList
                }
                .padding(.horizontal, 24)
                .padding(.top, 4)
                .padding(.bottom, 32)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.light)
        .onAppear {
            viewModel.loadDecks()
        }
        .alert("Deck Limit Reached", isPresented: $showingLimitAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("You can only have 20 custom decks at a time. Delete an old one to create a new one.")
        }
    }

    private var header: some View {
        DoodlePanel(background: AppTheme.Colors.paperBright) {
            VStack(alignment: .leading, spacing: 4) {
                Text("My Decks")
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var customDecksList: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.roomy) {
            let standardDecks = viewModel.customDecks.filter { !$0.isEmojiDeck }
            let emojiDecks = viewModel.customDecks.filter { $0.isEmojiDeck }

            deckSection(
                title: "Custom Decks",
                decks: standardDecks,
                isEmoji: false,
                emptyMessage: "No custom decks created yet."
            )

            deckSection(
                title: "Emoji Custom Decks",
                decks: emojiDecks,
                isEmoji: true,
                emptyMessage: "No emoji custom decks created yet."
            )
        }
    }

    private func deckSection(
        title: String,
        decks: [Deck],
        isEmoji: Bool,
        emptyMessage: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(title)
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink)

                Spacer()

                DoodleIconButton(
                    symbol: "plus",
                    size: 38,
                    accessibilityLabel: "Create new \(isEmoji ? "emoji" : "standard") deck"
                ) {
                    if viewModel.canCreateNewDeck {
                        router.openImmediately(.deckEditor(isEmoji: isEmoji))
                    } else {
                        showingLimitAlert = true
                    }
                }
            }

            if decks.isEmpty {
                DoodlePanel {
                    Text(emptyMessage)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.ink.opacity(0.58))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(18)
                }
            } else {
                DeckGridView(decks: decks) { deck in
                    let mode: GameMode = deck.isEmojiDeck ? .emoji : .normal
                    router.open(.customDeckDetail(deck: deck, mode: mode, fromMyDecks: true))
                }
            }
        }
    }
}
