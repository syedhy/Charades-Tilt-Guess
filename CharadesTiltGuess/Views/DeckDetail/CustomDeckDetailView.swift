import SwiftUI
import UIKit

struct CustomDeckDetailView: View {
    @EnvironmentObject private var router: AppRouter
    @StateObject private var viewModel: CustomDeckDetailViewModel
    @State private var isEditingDeckIdentity = false
    @State private var isShowingDeleteConfirmation = false
    @State private var isShowingAddCardSheet = false
    @State private var isShowingPasteSheet = false
    @FocusState private var isNameFocused: Bool

    @MainActor
    init(deck: Deck) {
        _viewModel = StateObject(wrappedValue: CustomDeckDetailViewModel(deck: deck))
    }

    @MainActor
    init(viewModel: CustomDeckDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            DeckDetailBackground(accent: viewModel.draftColor.displayColor)

            deckManagementContent

            floatingEditTools

            if isShowingAddCardSheet {
                AddCardSheet(viewModel: viewModel) {
                    isShowingAddCardSheet = false
                }
                .transition(.opacity)
                .zIndex(2)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .preferredColorScheme(.light)
        .animation(.snappy(duration: 0.16), value: isEditingDeckIdentity)
        .alert("Delete deck?", isPresented: $isShowingDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                guard viewModel.deleteDeck() else { return }
                router.goHome()
            }
        } message: {
            Text("This removes \"\(viewModel.deck.name)\" and all of its cards from this device.")
        }
        .sheet(isPresented: $isShowingPasteSheet) {
            PasteCardsSheet(viewModel: viewModel)
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
        }
    }

    private var deckManagementContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 26) {
                managementHeader
                deckTitleBlock

                if isEditingDeckIdentity {
                    editFormPanel
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                cardsWorkspace
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 132)
        }
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.interactively)
    }

    private var managementHeader: some View {
        HStack(spacing: 12) {
            DoodleIconButton(
                symbol: "xmark",
                accent: AppTheme.Colors.paperBright.opacity(0.66),
                size: 48,
                accessibilityLabel: "Close deck"
            ) {
                router.goBack()
            }

            Button {
                isEditingDeckIdentity.toggle()
                isNameFocused = isEditingDeckIdentity
            } label: {
                Text(isEditingDeckIdentity ? "Done" : "Edit")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink)
                    .frame(width: 78, height: 48)
                    .background(AppTheme.Colors.blue, in: Capsule())
                    .overlay {
                        Capsule()
                            .stroke(AppTheme.Colors.ink, lineWidth: AppTheme.Stroke.standard)
                    }
                    .shadow(color: AppTheme.Colors.ink.opacity(0.16), radius: 0, x: 3, y: 3)
            }
            .buttonStyle(DoodlePressStyle())
            .accessibilityLabel(isEditingDeckIdentity ? "Hide deck identity editor" : "Edit deck name and color")

            Spacer()

            DoodleIconButton(
                symbol: "trash",
                accent: AppTheme.Colors.paperBright.opacity(0.58),
                size: 48,
                accessibilityLabel: "Delete deck"
            ) {
                isShowingDeleteConfirmation = true
            }

            saveButton
        }
    }

    private var saveButton: some View {
        Button {
            guard viewModel.saveDraft() != nil else { return }
            isNameFocused = false
            isEditingDeckIdentity = false
        } label: {
            HStack(spacing: 8) {
                Text("Save")
                    .font(.system(size: 18, weight: .black, design: .rounded))

                Image(systemName: "checkmark")
                    .font(.system(size: 16, weight: .black))
            }
            .foregroundStyle(AppTheme.Colors.ink)
            .padding(.horizontal, 17)
            .frame(height: 48)
            .background(
                viewModel.canSaveDraft ? AppTheme.Colors.blue : AppTheme.Colors.gray.opacity(0.45),
                in: Capsule()
            )
            .overlay {
                Capsule()
                    .stroke(AppTheme.Colors.ink, lineWidth: AppTheme.Stroke.standard)
            }
            .shadow(color: AppTheme.Colors.ink.opacity(0.16), radius: 0, x: 3, y: 3)
        }
        .buttonStyle(DoodlePressStyle())
        .disabled(!viewModel.canSaveDraft)
        .opacity(viewModel.canSaveDraft ? 1 : 0.58)
        .accessibilityIdentifier("saveCustomDeckEditsButton")
    }

    private var deckTitleBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(viewModel.trimmedDraftName.isEmpty ? viewModel.deck.name : viewModel.trimmedDraftName)
                .font(.system(size: 48, weight: .black, design: .rounded))
                .lineLimit(2)
                .minimumScaleFactor(0.62)
                .foregroundStyle(viewModel.draftColor.displayColor)
                .accessibilityIdentifier("customDeckDetailTitle")

            Text(viewModel.draftCardCountText)
                .font(.system(size: 21, weight: .black, design: .rounded))
                .foregroundStyle(AppTheme.Colors.ink)
        }
    }

    private var cardsWorkspace: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.standard) {
            if let cardErrorMessage = viewModel.cardErrorMessage {
                Text(cardErrorMessage)
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.coral)
            }

            if let saveErrorMessage = viewModel.saveErrorMessage {
                Text(saveErrorMessage)
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.coral)
            }

            if let deleteErrorMessage = viewModel.deleteErrorMessage {
                Text(deleteErrorMessage)
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.coral)
            }

            if viewModel.draftCards.isEmpty {
                emptyCardsWorkspace
            } else {
                cardPreviewPanel
            }
        }
    }

    private var emptyCardsWorkspace: some View {
        VStack(spacing: AppTheme.Spacing.standard) {
            Spacer(minLength: 42)

            EmptyDeckDoodle()
                .frame(height: 175)
                .opacity(0.22)

            Text("Your deck is empty\nAdd cards to\nyour Deck!")
                .font(.system(size: 34, weight: .black, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundStyle(AppTheme.Colors.ink.opacity(0.42))
                .frame(maxWidth: .infinity)

            Spacer(minLength: 120)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 520)
    }

    private var cardPreviewPanel: some View {
        DoodlePanel(background: viewModel.draftColor.displayColor.opacity(0.88)) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.roomy) {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2),
                    alignment: .leading,
                    spacing: 12
                ) {
                    ForEach(viewModel.draftCards.prefix(16)) { card in
                        EditCardRow(card: card) {
                            viewModel.deleteDraftCard(id: card.id)
                        }
                    }
                }

                if viewModel.draftCards.count > 16 {
                    Text("+ \(viewModel.draftCards.count - 16) more")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.ink.opacity(0.62))
                }

                DoodleActionButton(
                    title: "Play",
                    symbol: "play.fill",
                    accent: AppTheme.Colors.paperBright
                ) {
                    router.open(.gameSetup(deck: viewModel.deck))
                }
                .accessibilityIdentifier("playCustomDeckButton")
            }
            .padding(AppTheme.Spacing.roomy)
        }
    }

    private var floatingEditTools: some View {
        HStack(spacing: 14) {
            DoodleIconButton(
                symbol: "doc.on.clipboard",
                accent: AppTheme.Colors.yellow,
                size: 62,
                accessibilityLabel: "Paste cards from clipboard"
            ) {
                isNameFocused = false
                viewModel.refreshImportPreview(from: "")
                isShowingPasteSheet = true
            }

            DoodleIconButton(
                symbol: "plus",
                accent: AppTheme.Colors.yellow,
                size: 62,
                accessibilityLabel: "Add card manually"
            ) {
                isNameFocused = false
                var transaction = Transaction()
                transaction.animation = nil
                withTransaction(transaction) {
                    isShowingAddCardSheet = true
                }
            }
        }
        .padding(.trailing, 28)
        .padding(.bottom, 26)
    }

    private var editFormPanel: some View {
        DoodlePanel {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.roomy) {
                editNameField
                editColorPicker
            }
            .padding(AppTheme.Spacing.roomy)
        }
    }

    private var editNameField: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.compact) {
            HStack {
                Text("Deck name")
                    .font(.system(size: 17, weight: .black, design: .rounded))

                Spacer()

                Text(viewModel.nameCharacterCountText)
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink.opacity(0.52))
            }

            TextField("Movie night", text: $viewModel.draftName)
                .font(.system(size: 21, weight: .black, design: .rounded))
                .foregroundStyle(AppTheme.Colors.ink)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .focused($isNameFocused)
                .padding(.horizontal, AppTheme.Spacing.standard)
                .frame(height: 58)
                .background(
                    AppTheme.Colors.paper,
                    in: RoundedRectangle(cornerRadius: AppTheme.Radius.button, style: .continuous)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: AppTheme.Radius.button, style: .continuous)
                        .stroke(AppTheme.Colors.ink, lineWidth: AppTheme.Stroke.standard)
                }
                .accessibilityIdentifier("editDeckNameField")
        }
        .foregroundStyle(AppTheme.Colors.ink)
    }

    private var editColorPicker: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.standard) {
            Text("Pick a deck color")
                .font(.system(size: 17, weight: .black, design: .rounded))
                .foregroundStyle(AppTheme.Colors.ink)

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 14), count: 4),
                spacing: 14
            ) {
                ForEach(viewModel.availableColors, id: \.self) { color in
                    Button {
                        viewModel.draftColor = color
                    } label: {
                        Circle()
                            .fill(color.displayColor)
                            .frame(width: 48, height: 48)
                            .overlay {
                                Circle()
                                    .stroke(AppTheme.Colors.ink, lineWidth: AppTheme.Stroke.standard)
                            }
                            .overlay {
                                if viewModel.draftColor == color {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 18, weight: .black))
                                        .foregroundStyle(AppTheme.Colors.ink)
                                }
                            }
                            .shadow(color: AppTheme.Colors.ink.opacity(0.16), radius: 0, x: 3, y: 3)
                    }
                    .buttonStyle(DoodlePressStyle())
                    .accessibilityLabel("\(color.rawValue.capitalized) deck color")
                    .accessibilityAddTraits(viewModel.draftColor == color ? .isSelected : [])
                }
            }
        }
    }
}

private struct DeckDetailBackground: View {
    let accent: Color

    var body: some View {
        ZStack {
            Color(red: 0.09, green: 0.12, blue: 0.16)
                .ignoresSafeArea()

            Canvas { context, size in
                for y in stride(from: 0.0, through: size.height, by: 18.0) {
                    for x in stride(from: 0.0, through: size.width, by: 18.0) {
                        let rect = CGRect(x: x, y: y, width: 1.4, height: 1.4)
                        let opacity = ((Int(x + y) / 18).isMultiple(of: 3)) ? 0.055 : 0.025
                        context.fill(Path(ellipseIn: rect), with: .color(AppTheme.Colors.paperBright.opacity(opacity)))
                    }
                }
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)

            accent
                .opacity(0.20)
                .blur(radius: 72)
                .frame(width: 260, height: 260)
                .offset(x: -110, y: -210)

            AppTheme.Colors.coral
                .opacity(0.12)
                .blur(radius: 88)
                .frame(width: 280, height: 280)
                .offset(x: 150, y: 260)
        }
    }
}

private struct EditCardRow: View {
    let card: GameWord
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Text(card.text)
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundStyle(AppTheme.Colors.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.74)
                .frame(maxWidth: .infinity)

            Button(action: onDelete) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .black))
                    .foregroundStyle(AppTheme.Colors.ink)
                    .frame(width: 22, height: 22)
                    .background(AppTheme.Colors.paperBright.opacity(0.88), in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Delete \(card.text)")
        }
        .padding(.leading, 12)
        .padding(.trailing, 7)
        .padding(.vertical, 8)
        .background(AppTheme.Colors.paperBright.opacity(0.76), in: Capsule())
        .overlay {
            Capsule()
                .stroke(AppTheme.Colors.ink.opacity(0.46), lineWidth: 2)
        }
        .shadow(color: AppTheme.Colors.ink.opacity(0.12), radius: 0, x: 2, y: 2)
    }
}

private struct EmptyDeckDoodle: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(AppTheme.Colors.paperBright.opacity(0.60))
                .frame(width: 116, height: 150)
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(AppTheme.Colors.ink.opacity(0.26), lineWidth: 4)
                }
                .rotationEffect(.degrees(8))
                .offset(x: 18, y: 8)

            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(AppTheme.Colors.paperBright.opacity(0.72))
                .frame(width: 116, height: 150)
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(AppTheme.Colors.ink.opacity(0.30), lineWidth: 4)
                }
                .rotationEffect(.degrees(-10))
                .offset(x: -18, y: -2)

            Image(systemName: "sparkles")
                .font(.system(size: 24, weight: .black))
                .foregroundStyle(AppTheme.Colors.ink.opacity(0.30))
                .offset(x: 58, y: -76)
        }
    }
}

private struct AddCardSheet: View {
    @ObservedObject var viewModel: CustomDeckDetailViewModel
    let onDismiss: () -> Void
    @State private var cardText = ""
    @FocusState private var isCardFocused: Bool

    var body: some View {
        ZStack(alignment: .top) {
            AppTheme.Colors.ink
                .opacity(0.36)
                .ignoresSafeArea()

            DoodlePanel(background: AppTheme.Colors.yellow) {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.roomy) {
                    HStack(spacing: AppTheme.Spacing.standard) {
                        DoodleIconButton(
                            symbol: "xmark",
                            accent: AppTheme.Colors.paperBright.opacity(0.70),
                            size: 42,
                            accessibilityLabel: "Close add card"
                        ) {
                            onDismiss()
                        }

                        Text("Add Card")
                            .font(.system(size: 36, weight: .black, design: .rounded))
                            .foregroundStyle(AppTheme.Colors.ink)

                        Spacer()
                    }

                    VStack(alignment: .leading, spacing: AppTheme.Spacing.compact) {
                        HStack {
                            Text("Name of card")
                                .font(.system(size: 16, weight: .black, design: .rounded))

                            Spacer()

                            Text(viewModel.cardCharacterCountText(for: cardText))
                                .font(.system(size: 13, weight: .black, design: .rounded))
                        }
                        .foregroundStyle(AppTheme.Colors.ink.opacity(0.72))

                        TextField("Pizza", text: $cardText)
                            .font(.system(size: 21, weight: .black, design: .rounded))
                            .foregroundStyle(AppTheme.Colors.ink)
                            .textInputAutocapitalization(.words)
                            .autocorrectionDisabled()
                            .focused($isCardFocused)
                            .padding(.horizontal, AppTheme.Spacing.standard)
                            .frame(height: 58)
                            .background(
                                AppTheme.Colors.paper,
                                in: RoundedRectangle(cornerRadius: AppTheme.Radius.button, style: .continuous)
                            )
                            .overlay {
                                RoundedRectangle(cornerRadius: AppTheme.Radius.button, style: .continuous)
                                    .stroke(AppTheme.Colors.ink, lineWidth: AppTheme.Stroke.standard)
                            }
                            .accessibilityIdentifier("manualCardTextField")
                    }

                    if let cardErrorMessage = viewModel.cardValidationMessage(for: cardText), !cardText.isEmpty {
                        Text(cardErrorMessage)
                            .font(.system(size: 13, weight: .black, design: .rounded))
                            .foregroundStyle(AppTheme.Colors.coral)
                    }

                    DoodleActionButton(
                        title: "Add",
                        symbol: "plus",
                        accent: viewModel.canAddCard(text: cardText) ? AppTheme.Colors.mint : AppTheme.Colors.gray.opacity(0.42)
                    ) {
                        guard viewModel.addCard(text: cardText) else { return }
                        cardText = ""
                        isCardFocused = true
                    }
                    .disabled(!viewModel.canAddCard(text: cardText))
                    .opacity(viewModel.canAddCard(text: cardText) ? 1 : 0.60)
                    .accessibilityIdentifier("addManualCardButton")
                }
                .padding(AppTheme.Spacing.roomy)
            }
            .padding(20)
            .padding(.top, 32)
        }
        .onAppear {
            isCardFocused = true
        }
    }
}

private struct PasteCardsSheet: View {
    @ObservedObject var viewModel: CustomDeckDetailViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var pastedText = ""
    @State private var pasteMessage: String?

    var body: some View {
        ZStack {
            AppTheme.Colors.paper
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.roomy) {
                    header
                    textInput
                    preview
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 22)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .onAppear {
            viewModel.refreshImportPreview(from: pastedText)
        }
        .onChange(of: pastedText) { _, newText in
            viewModel.refreshImportPreview(from: newText)
        }
    }

    private var header: some View {
        DoodlePanel(background: AppTheme.Colors.paperBright) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.standard) {
                HStack(alignment: .top, spacing: AppTheme.Spacing.standard) {
                    DoodleIconButton(
                        symbol: "xmark",
                        size: 42,
                        accessibilityLabel: "Close paste cards"
                    ) {
                        dismiss()
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Paste from clipboard")
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .foregroundStyle(AppTheme.Colors.ink)

                        Text("Put each card on its own line\nLists from AI work great here")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.Colors.ink.opacity(0.64))
                    }

                    Spacer()
                }

                importButton

                DoodleActionButton(
                    title: "Paste clipboard",
                    symbol: "doc.on.clipboard",
                    accent: AppTheme.Colors.yellow
                ) {
                    let clipboardText = UIPasteboard.general.string ?? ""
                    pastedText = clipboardText
                    pasteMessage = clipboardText.isEmpty ? "Clipboard is empty." : nil
                }
                .accessibilityIdentifier("pasteClipboardButton")

                if let pasteMessage {
                    Text(pasteMessage)
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.coral)
                }
            }
            .padding(AppTheme.Spacing.roomy)
        }
    }

    private var textInput: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.compact) {
            Text("Or Paste Here")
                .font(.system(size: 17, weight: .black, design: .rounded))
                .foregroundStyle(AppTheme.Colors.ink)

            TextEditor(text: $pastedText)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.Colors.ink)
                .scrollContentBackground(.hidden)
                .padding(12)
                .frame(minHeight: 150)
                .background(AppTheme.Colors.paperBright, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(AppTheme.Colors.ink, lineWidth: AppTheme.Stroke.standard)
                }
                .accessibilityIdentifier("pasteCardsTextEditor")
        }
    }

    private var preview: some View {
        DoodlePanel(background: AppTheme.Colors.paperBright) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.standard) {
                Text("\(viewModel.importPreview.cards.count) ready to import")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink)

                ForEach(viewModel.importPreview.summaryMessages, id: \.self) { message in
                    Text(message)
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.ink.opacity(0.62))
                }

                if viewModel.importPreview.cards.isEmpty {
                    Text("Apple\nFootball\nPizza\nSpider-Man")
                        .font(.system(size: 17, weight: .black, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.ink.opacity(0.34))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(AppTheme.Spacing.standard)
                        .background(AppTheme.Colors.paper, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                } else {
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2),
                        alignment: .leading,
                        spacing: 12
                    ) {
                        ForEach(Array(viewModel.importPreview.cards.prefix(14).enumerated()), id: \.element) { index, card in
                            ImportPreviewChip(text: card, index: index)
                        }
                    }

                    if viewModel.importPreview.cards.count > 14 {
                        Text("+ \(viewModel.importPreview.cards.count - 14) more")
                            .font(.system(size: 13, weight: .black, design: .rounded))
                            .foregroundStyle(AppTheme.Colors.ink.opacity(0.58))
                    }
                }
            }
            .padding(AppTheme.Spacing.roomy)
        }
    }

    private var importButton: some View {
        DoodleActionButton(
            title: "Import cards",
            symbol: "tray.and.arrow.down.fill",
            accent: viewModel.importPreview.hasImportableCards ? AppTheme.Colors.mint : AppTheme.Colors.gray.opacity(0.42)
        ) {
            importCardsAndDismiss()
        }
        .disabled(!viewModel.importPreview.hasImportableCards)
        .opacity(viewModel.importPreview.hasImportableCards ? 1 : 0.60)
        .accessibilityIdentifier("importClipboardCardsButton")
    }

    private func importCardsAndDismiss() {
        guard viewModel.importCards(from: pastedText) > 0 else { return }
        pastedText = ""
        dismiss()
    }
}

private struct ImportPreviewChip: View {
    let text: String
    let index: Int

    private var background: Color {
        [AppTheme.Colors.paperBright, AppTheme.Colors.mint.opacity(0.45), AppTheme.Colors.yellow.opacity(0.52)][index % 3]
    }

    var body: some View {
        Text(text)
            .font(.system(size: 15, weight: .black, design: .rounded))
            .foregroundStyle(AppTheme.Colors.ink)
            .lineLimit(1)
            .minimumScaleFactor(0.72)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(background, in: Capsule())
            .overlay {
                Capsule()
                    .stroke(AppTheme.Colors.ink.opacity(0.38), lineWidth: 2)
            }
            .shadow(color: AppTheme.Colors.ink.opacity(0.10), radius: 0, x: 2, y: 2)
    }
}

#Preview {
    NavigationStack {
        CustomDeckDetailView(
            deck: Deck(
                id: "preview-custom",
                name: "Games",
                cards: [
                    GameWord(id: "mario", text: "Mario Kart"),
                    GameWord(id: "zelda", text: "Zelda"),
                    GameWord(id: "minecraft", text: "Minecraft")
                ],
                type: .custom,
                color: .mint,
                symbolName: "rectangle.stack"
            )
        )
        .environmentObject(AppRouter())
    }
}
