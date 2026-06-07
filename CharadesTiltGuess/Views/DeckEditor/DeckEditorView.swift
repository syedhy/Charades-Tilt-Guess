import SwiftUI

struct DeckEditorView: View {
    @EnvironmentObject private var router: AppRouter
    @StateObject private var viewModel: DeckEditorViewModel
    @State private var isShowingAddCardSheet = false
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
                            .contentShape(Rectangle())
                            .onTapGesture {
                                isNameFocused = false
                            }

                        deckPreview
                            .contentShape(Rectangle())
                            .onTapGesture {
                                isNameFocused = false
                            }

                        formPanel
                            .contentShape(Rectangle())
                            .onTapGesture {
                                isNameFocused = false
                            }
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
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .preferredColorScheme(.light)
        .sheet(isPresented: $isShowingAddCardSheet) {
            AddCardSheet(viewModel: viewModel)
                .presentationDetents([.height(330)])
                .presentationDragIndicator(.hidden)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.compact) {
            Text("Custom deck")
                .font(.system(size: 34, weight: .black, design: .rounded))
                .foregroundStyle(AppTheme.Colors.ink)
                .fixedSize(horizontal: false, vertical: true)

            Text("Name it , Color it and Start Playing")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.Colors.ink.opacity(0.64))
        }
    }

    private var deckPreview: some View {
        HStack(spacing: AppTheme.Spacing.standard) {
            DeckCardView(
                name: viewModel.trimmedDeckName.isEmpty ? "My Deck" : viewModel.trimmedDeckName,
                detail: viewModel.cardCountText,
                symbol: "rectangle.stack",
                accent: viewModel.selectedColor.displayColor,
                rotation: -1
            )
            .frame(maxWidth: 175)

            VStack(alignment: .leading, spacing: AppTheme.Spacing.compact) {
                Text("Starter shell")
                    .font(.system(size: 18, weight: .black, design: .rounded))

                Text("Add prompts now so your deck is ready for game night.")
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
                cardList

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
                .simultaneousGesture(TapGesture())
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

            TextField("Movies , Celebs", text: $viewModel.deckName)
                .font(.system(size: 21, weight: .black, design: .rounded))
                .foregroundStyle(AppTheme.Colors.ink)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .focused($isNameFocused)
                .padding(.horizontal, AppTheme.Spacing.standard)
                .frame(height: 58)
                .background(
                    AppTheme.Colors.paper,
                    in: RoundedRectangle(
                        cornerRadius: AppTheme.Radius.button,
                        style: .continuous
                    )
                )
                .overlay {
                    RoundedRectangle(
                        cornerRadius: AppTheme.Radius.button,
                        style: .continuous
                    )
                    .stroke(
                        AppTheme.Colors.ink,
                        lineWidth: AppTheme.Stroke.standard
                    )
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

    private var cardList: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.standard) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Cards")
                        .font(.system(size: 17, weight: .black, design: .rounded))

                    Text(viewModel.cardCountText)
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.ink.opacity(0.52))
                }

                Spacer()

                Button {
                    isNameFocused = false
                    viewModel.clearCardError()
                    isShowingAddCardSheet = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .black))
                        .foregroundStyle(AppTheme.Colors.ink)
                        .frame(width: 44, height: 44)
                        .background(AppTheme.Colors.yellow, in: Circle())
                        .overlay {
                            Circle()
                                .stroke(AppTheme.Colors.ink, lineWidth: AppTheme.Stroke.standard)
                        }
                        .shadow(color: AppTheme.Colors.ink.opacity(0.16), radius: 0, x: 3, y: 3)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Add card")
            }

            if let cardErrorMessage = viewModel.cardErrorMessage {
                Text(cardErrorMessage)
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.coral)
            }

            if viewModel.cards.isEmpty {
                Text("Add at least one prompt before saving this deck.")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink.opacity(0.58))
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.vertical, 4)
            } else {
                VStack(spacing: 10) {
                    ForEach(viewModel.cards) { card in
                        cardRow(card)
                    }
                }
            }
        }
        .foregroundStyle(AppTheme.Colors.ink)
    }

    private func cardRow(_ card: GameWord) -> some View {
        HStack(spacing: 12) {
            Text(card.text)
                .font(.system(size: 15, weight: .black, design: .rounded))
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                viewModel.deleteCard(id: card.id)
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 14, weight: .black))
                    .foregroundStyle(AppTheme.Colors.ink)
                    .frame(width: 34, height: 34)
                    .background(AppTheme.Colors.paper, in: Circle())
                    .overlay {
                        Circle()
                            .stroke(AppTheme.Colors.ink, lineWidth: 2)
                    }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Delete \(card.text)")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            AppTheme.Colors.paper,
            in: RoundedRectangle(cornerRadius: 14, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(AppTheme.Colors.ink.opacity(0.92), lineWidth: 2)
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
        .simultaneousGesture(TapGesture())
        .accessibilityLabel("\(deckColor.rawValue.capitalized) deck color")
        .accessibilityAddTraits(viewModel.selectedColor == deckColor ? .isSelected : [])
    }

    private func scrollNameFieldIntoKeyboardView(using scrollProxy: ScrollViewProxy) {
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.keyboardScrollDelay) {
            withAnimation(.snappy(duration: 0.15)) {
                scrollProxy.scrollTo(Self.deckNameFieldScrollID, anchor: .center)
            }
        }
    }
}

private extension DeckEditorView {
    static let deckNameFieldScrollID = "deck-name-field-scroll-target"
    static let keyboardScrollDelay: TimeInterval = 0.0
}

#Preview {
    NavigationStack {
        DeckEditorView()
            .environmentObject(AppRouter())
    }
}

private struct AddCardSheet: View {
    @ObservedObject var viewModel: DeckEditorViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var cardText = ""
    @FocusState private var isCardFocused: Bool

    var body: some View {
        ZStack {
            DoodlePaperBackground()

            DoodlePanel {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.standard) {
                    HStack(alignment: .top) {
                        Text("Add Card")
                            .font(.system(size: 30, weight: .black, design: .rounded))
                            .foregroundStyle(AppTheme.Colors.ink)

                        Spacer()

                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 15, weight: .black))
                                .foregroundStyle(AppTheme.Colors.ink)
                                .frame(width: 38, height: 38)
                                .background(AppTheme.Colors.paper, in: Circle())
                                .overlay {
                                    Circle()
                                        .stroke(AppTheme.Colors.ink, lineWidth: 2)
                                }
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Close add card")
                    }

                    VStack(alignment: .leading, spacing: AppTheme.Spacing.compact) {
                        HStack {
                            Text("Card text")
                                .font(.system(size: 14, weight: .black, design: .rounded))

                            Spacer()

                            Text(viewModel.cardCharacterCountText(for: cardText))
                                .font(.system(size: 12, weight: .black, design: .rounded))
                                .foregroundStyle(AppTheme.Colors.ink.opacity(0.52))
                        }

                        TextField("Pizza, Spider-Man, Football", text: $cardText)
                            .font(.system(size: 19, weight: .black, design: .rounded))
                            .foregroundStyle(AppTheme.Colors.ink)
                            .textInputAutocapitalization(.words)
                            .autocorrectionDisabled()
                            .focused($isCardFocused)
                            .padding(.horizontal, AppTheme.Spacing.standard)
                            .frame(height: 56)
                            .background(
                                AppTheme.Colors.paper,
                                in: RoundedRectangle(cornerRadius: AppTheme.Radius.button, style: .continuous)
                            )
                            .overlay {
                                RoundedRectangle(cornerRadius: AppTheme.Radius.button, style: .continuous)
                                    .stroke(AppTheme.Colors.ink, lineWidth: AppTheme.Stroke.standard)
                            }
                            .accessibilityIdentifier("addCardTextField")
                    }
                    .foregroundStyle(AppTheme.Colors.ink)

                    if let message = viewModel.cardValidationMessage(for: cardText), !cardText.isEmpty {
                        Text(message)
                            .font(.system(size: 12, weight: .black, design: .rounded))
                            .foregroundStyle(AppTheme.Colors.coral)
                    }

                    DoodleActionButton(
                        title: "Add card",
                        symbol: "plus",
                        accent: viewModel.canAddCard(text: cardText) ? AppTheme.Colors.yellow : AppTheme.Colors.gray.opacity(0.45)
                    ) {
                        guard viewModel.addCard(text: cardText) else { return }
                        cardText = ""
                        dismiss()
                    }
                    .disabled(!viewModel.canAddCard(text: cardText))
                    .opacity(viewModel.canAddCard(text: cardText) ? 1 : 0.58)
                    .accessibilityIdentifier("confirmAddCardButton")
                }
                .padding(AppTheme.Spacing.roomy)
            }
            .padding(20)
        }
        .preferredColorScheme(.light)
        .onAppear {
            isCardFocused = true
        }
    }
}
