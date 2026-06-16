import SwiftUI
import UIKit

struct PasteAndPlayView: View {
    let settings: GameSettings
    let onStart: (GameConfiguration) -> Void

    @State private var pastedText = ""
    @State private var preview = ClipboardImportPreview(cards: [], blankLineCount: 0, duplicateCount: 0, tooLongLines: [], overDeckLimitCount: 0)
    @State private var selectedDuration = 60
    @State private var pasteMessage: String?
    @State private var isShowingInstructions = false

    private let importService = ClipboardImportService()

    var body: some View {
        ZStack {
            DoodlePaperBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.roomy) {
                    header
                    durationPicker
                    pastePanel
                    previewPanel
                    playButton
                }
                .padding(24)
                .padding(.bottom, 32)
            }
            .scrollDismissesKeyboard(.interactively)
            .scrollIndicators(.hidden)
        }
        .navigationTitle(GameMode.pasteAndPlay.title)
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
                .accessibilityLabel("Paste and Play instructions")
            }
        }
        .sheet(isPresented: $isShowingInstructions) {
            ModeInstructionsView(mode: .pasteAndPlay)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .preferredColorScheme(.light)
        .onAppear {
            selectedDuration = settings.defaultDuration
            refreshPreview()
        }
        .onChange(of: pastedText) { _, _ in
            refreshPreview()
        }
    }

    private var header: some View {
        DoodlePanel(background: GameMode.pasteAndPlay.accentColor) {
            VStack(alignment: .leading, spacing: 12) {
                Label("TEMPORARY DECK", systemImage: GameMode.pasteAndPlay.symbolName)
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink.opacity(0.62))

                Text("Paste a list.\nPlay in seconds.")
                    .font(.system(size: 40, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink)
                    .fixedSize(horizontal: false, vertical: true)

                Text("New lines, commas, bullets, and numbered lists all work.")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink.opacity(0.66))
            }
            .padding(22)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var durationPicker: some View {
        DoodlePanel {
            VStack(alignment: .leading, spacing: 14) {
                Text("Round length")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                    ForEach(GameSettings.availableDurations, id: \.self) { duration in
                        Button {
                            selectedDuration = duration
                        } label: {
                            Text("\(duration)s")
                                .font(.system(size: 19, weight: .black, design: .rounded))
                                .foregroundStyle(AppTheme.Colors.ink)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    selectedDuration == duration ? GameMode.pasteAndPlay.accentColor : AppTheme.Colors.paper,
                                    in: RoundedRectangle(cornerRadius: AppTheme.Radius.button, style: .continuous)
                                )
                                .overlay {
                                    RoundedRectangle(cornerRadius: AppTheme.Radius.button, style: .continuous)
                                        .stroke(AppTheme.Colors.ink, lineWidth: AppTheme.Stroke.standard)
                                }
                        }
                        .buttonStyle(DoodlePressStyle())
                    }
                }
            }
            .padding(18)
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
                    .padding(12)
                    .frame(minHeight: 172)
                    .background(AppTheme.Colors.paper, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
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
                            ImportPreviewPill(text: card)
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
            onStart(.pasteAndPlay(deck: makeTemporaryDeck(), duration: selectedDuration))
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
            cards: preview.cards.enumerated().map { index, text in
                GameWord(id: "paste-\(index)-\(UUID().uuidString)", text: text)
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
