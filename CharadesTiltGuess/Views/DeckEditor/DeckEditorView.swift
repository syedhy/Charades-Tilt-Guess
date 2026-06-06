import SwiftUI

struct DeckEditorView: View {
    @EnvironmentObject private var router: AppRouter
    @StateObject private var viewModel: DeckEditorViewModel
    @FocusState private var isNameFocused: Bool

    @MainActor
    init() {
        _viewModel = StateObject(wrappedValue: DeckEditorViewModel())
    }

    @MainActor
    init(viewModel: DeckEditorViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            DoodlePaperBackground()

            ScrollViewReader { scrollProxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.section) {
                        header
                        deckPreview
                        formPanel
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 42)
                }
                .scrollIndicators(.hidden)
                .scrollDismissesKeyboard(.interactively)
                .onChange(of: isNameFocused) { _, isFocused in
                    guard isFocused else { return }
                    scrollNameFieldIntoKeyboardView(using: scrollProxy)
                }
            }
        }
        .navigationTitle("New Deck")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .preferredColorScheme(.light)
        .onAppear {
            isNameFocused = true
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.compact) {
            Text("CUSTOM DECK")
                .font(.system(size: 12, weight: .black, design: .rounded))
                .foregroundStyle(AppTheme.Colors.ink.opacity(0.58))

            Text("Create a custom deck")
                .font(.system(size: 34, weight: .black, design: .rounded))
                .foregroundStyle(AppTheme.Colors.ink)
                .fixedSize(horizontal: false, vertical: true)

            Text("Name it, color it, then we will add cards in the next step.")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.Colors.ink.opacity(0.64))
        }
    }

    private var deckPreview: some View {
        HStack(spacing: AppTheme.Spacing.standard) {
            DeckCardView(
                name: viewModel.trimmedDeckName.isEmpty ? "My Deck" : viewModel.trimmedDeckName,
                detail: "0 prompts",
                symbol: "rectangle.stack",
                accent: viewModel.selectedColor.displayColor,
                rotation: -1
            )
            .frame(maxWidth: 175)

            VStack(alignment: .leading, spacing: AppTheme.Spacing.compact) {
                Text("Starter shell")
                    .font(.system(size: 18, weight: .black, design: .rounded))

                Text("Cards are coming next. For now, this saves the deck identity locally.")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink.opacity(0.62))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .foregroundStyle(AppTheme.Colors.ink)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Custom deck preview")
    }

    private var formPanel: some View {
        DoodlePanel {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.roomy) {
                deckNameField
                colorPicker

                if let saveErrorMessage = viewModel.saveErrorMessage {
                    Text(saveErrorMessage)
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.coral)
                }

                DoodleActionButton(
                    title: "Create deck",
                    symbol: "checkmark",
                    accent: viewModel.canSave ? AppTheme.Colors.yellow : AppTheme.Colors.gray.opacity(0.45)
                ) {
                    guard viewModel.saveDeck() != nil else { return }
                    router.goHome()
                }
                .disabled(!viewModel.canSave)
                .opacity(viewModel.canSave ? 1 : 0.58)
                .accessibilityIdentifier("createCustomDeckButton")
            }
            .padding(AppTheme.Spacing.roomy)
        }
    }

    private var deckNameField: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.compact) {
            HStack {
                Text("Deck name")
                    .font(.system(size: 17, weight: .black, design: .rounded))

                Spacer()

                Text(viewModel.nameCharacterCountText)
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink.opacity(0.52))
            }

            TextField("Movie night, family chaos...", text: $viewModel.deckName)
                .font(.system(size: 21, weight: .black, design: .rounded))
                .foregroundStyle(AppTheme.Colors.ink)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .focused($isNameFocused)
                .padding(.horizontal, AppTheme.Spacing.standard)
                .frame(height: 58)
                .background(AppTheme.Colors.paper, in: RoundedRectangle(cornerRadius: AppTheme.Radius.button, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: AppTheme.Radius.button, style: .continuous)
                        .stroke(AppTheme.Colors.ink, lineWidth: AppTheme.Stroke.standard)
                }
                .accessibilityIdentifier("deckNameField")
        }
        .id(Self.deckNameFieldScrollID)
        .foregroundStyle(AppTheme.Colors.ink)
    }

    private var colorPicker: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.standard) {
            Text("Pick a deck color")
                .font(.system(size: 17, weight: .black, design: .rounded))
                .foregroundStyle(AppTheme.Colors.ink)

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 14), count: 4),
                spacing: 14
            ) {
                ForEach(viewModel.availableColors, id: \.self) { color in
                    colorButton(for: color)
                }
            }
        }
    }

    private func colorButton(for deckColor: DeckColor) -> some View {
        Button {
            viewModel.selectedColor = deckColor
        } label: {
            Circle()
                .fill(deckColor.displayColor)
                .frame(width: 48, height: 48)
                .overlay {
                    Circle()
                        .stroke(AppTheme.Colors.ink, lineWidth: AppTheme.Stroke.standard)
                }
                .overlay {
                    if viewModel.selectedColor == deckColor {
                        Image(systemName: "checkmark")
                            .font(.system(size: 18, weight: .black))
                            .foregroundStyle(AppTheme.Colors.ink)
                    }
                }
                .shadow(color: AppTheme.Colors.ink.opacity(0.16), radius: 0, x: 3, y: 3)
        }
        .buttonStyle(DoodlePressStyle())
        .accessibilityLabel("\(deckColor.rawValue.capitalized) deck color")
        .accessibilityAddTraits(viewModel.selectedColor == deckColor ? .isSelected : [])
    }

    private func scrollNameFieldIntoKeyboardView(using scrollProxy: ScrollViewProxy) {
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.keyboardScrollDelay) {
            withAnimation(.snappy(duration: 0.34)) {
                scrollProxy.scrollTo(Self.deckNameFieldScrollID, anchor: .center)
            }
        }
    }
}

private extension DeckEditorView {
    static let deckNameFieldScrollID = "deck-name-field-scroll-target"
    static let keyboardScrollDelay: TimeInterval = 0.32
}

#Preview {
    NavigationStack {
        DeckEditorView()
            .environmentObject(AppRouter())
    }
}
