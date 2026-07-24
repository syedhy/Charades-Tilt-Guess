import SwiftUI
import UIKit

struct PasteAndPlayView: View {
    let settings: GameSettings
    let onStart: (GameConfiguration) -> Void

    @State private var pastedText = ""
    @State private var preview = ClipboardImportPreview(
        cards: [],
        blankLineCount: 0,
        duplicateCount: 0,
        tooLongLines: [],
        overDeckLimitCount: 0,
        maxCardLength: 30,
        invalidEmojiCardsCount: 0,
        missingMeaningCardsCount: 0
    )
    @State private var pasteMessage: String?

    private let importService = ClipboardImportService()

    var body: some View {
        ZStack {
            DoodlePaperBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.roomy) {
                    header
                    playButton
                    pastePanel
                    previewPanel
                }
                .padding(.horizontal, 24)
                .padding(.top, 4)
                .padding(.bottom, 32)
            }
            .scrollDismissesKeyboard(.interactively)
            .scrollIndicators(.hidden)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.light)
        .onAppear {
            refreshPreview()
        }
        .onChange(of: pastedText) { _, _ in
            refreshPreview()
        }
    }

    private var header: some View {
        DoodlePanel(background: GameMode.pasteAndPlay.accentColor) {
            VStack(alignment: .leading, spacing: 14) {
                Label(GameMode.pasteAndPlay.purpose.uppercased(), systemImage: GameMode.pasteAndPlay.symbolName)
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink.opacity(0.64))

                Text(GameMode.pasteAndPlay.title)
                    .font(.system(size: 40, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink)

                Text(GameMode.pasteAndPlay.description)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink.opacity(0.68))
            }
            .padding(22)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var pastePanel: some View {
        DoodlePanel {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.standard) {
                DoodleActionButton(title: "Paste clipboard", symbol: "doc.on.clipboard", accent: AppTheme.Colors.yellow) {
                    let clipboardText = UIPasteboard.general.string ?? ""
                    pastedText = clipboardText
                    pasteMessage = clipboardText.isEmpty ? "Clipboard is empty." : nil
                }

                if let pasteMessage {
                    Text(pasteMessage)
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.coral)
                }

                TextEditor(text: $pastedText)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .padding(12)
                    .frame(minHeight: 140)
                    .background(AppTheme.Colors.paper, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(AppTheme.Colors.ink, lineWidth: AppTheme.Stroke.standard)
                    }
                    .accessibilityIdentifier("pasteAndPlayTextEditor")
            }
            .padding(18)
        }
    }

    private var previewPanel: some View {
        DoodlePanel(background: AppTheme.Colors.paperBright) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.standard) {
                Text("\(preview.cards.count) cards ready")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink)

                ForEach(preview.summaryMessages, id: \.self) { message in
                    Text(message)
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.ink.opacity(0.6))
                }

                if preview.cards.isEmpty {
                    Text("1. Pizza\n2. Football\n3. Spider-Man")
                        .font(.system(size: 17, weight: .black, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.ink.opacity(0.34))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(AppTheme.Spacing.standard)
                        .background(AppTheme.Colors.paper, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                } else {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 124), spacing: 10)], alignment: .leading, spacing: 10) {
                        ForEach(preview.cards.prefix(12), id: \.self) { card in
                            let displayText = card.meaning != nil ? "\(card.text) - \(card.meaning!)" : card.text
                            ImportPreviewPill(text: displayText)
                        }
                    }

                    if preview.cards.count > 12 {
                        Text("+ \(preview.cards.count - 12) more")
                            .font(.system(size: 13, weight: .black, design: .rounded))
                            .foregroundStyle(AppTheme.Colors.ink.opacity(0.58))
                    }
                }
            }
            .padding(18)
        }
    }

    private var playButton: some View {
        DoodleActionButton(
            title: preview.cards.isEmpty ? "Paste cards first" : "Play now",
            symbol: "play.fill",
            accent: preview.cards.isEmpty ? AppTheme.Colors.gray.opacity(0.42) : GameMode.pasteAndPlay.accentColor
        ) {
            guard !preview.cards.isEmpty else { return }
            onStart(.pasteAndPlay(deck: makeTemporaryDeck(), duration: settings.defaultDuration))
        }
        .disabled(preview.cards.isEmpty)
        .opacity(preview.cards.isEmpty ? 0.62 : 1)
        .accessibilityIdentifier("pasteAndPlayStartButton")
    }

    private func refreshPreview() {
        preview = importService.previewCards(from: pastedText)
    }

    private func makeTemporaryDeck() -> Deck {
        Deck(
            id: "temp-paste-\(UUID().uuidString)",
            name: "Paste & Play",
            description: "Temporary pasted deck",
            cards: preview.cards.enumerated().map { index, card in
                GameWord(id: "paste-\(index)-\(UUID().uuidString)", text: card.text, meaning: card.meaning)
            },
            type: .custom,
            color: .yellow,
            symbolName: GameMode.pasteAndPlay.symbolName
        )
    }
}

private struct ImportPreviewPill: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 15, weight: .black, design: .rounded))
            .foregroundStyle(AppTheme.Colors.ink)
            .lineLimit(1)
            .minimumScaleFactor(0.72)
            .padding(.horizontal, 13)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(AppTheme.Colors.paper, in: Capsule())
            .overlay {
                Capsule()
                    .stroke(AppTheme.Colors.ink.opacity(0.42), lineWidth: 2)
            }
    }
}
