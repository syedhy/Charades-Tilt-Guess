import SwiftUI
import UIKit

struct CustomDeckDetailView: View {
    @EnvironmentObject private var router: AppRouter
    @StateObject private var viewModel: CustomDeckDetailViewModel
    @State private var isEditingDeckIdentity = false
    @State private var isShowingDeleteConfirmation = false
    @State private var isShowingUnsavedChangesConfirmation = false
    @State private var isShowingAddCardSheet = false
    @State private var isShowingPasteSheet = false
    @State private var toastMessage: String?
    @State private var toastPlacement: ToastPlacement = .top
    @FocusState private var isNameFocused: Bool

    @MainActor
    init(deck: Deck) {
        _viewModel = StateObject(wrappedValue: CustomDeckDetailViewModel(deck: deck))
    }

    @MainActor
    init(viewModel: CustomDeckDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    private var isCustomDeck: Bool {
        viewModel.deck.type == .custom
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            DoodlePaperBackground()

            editContent

            if isCustomDeck {
                floatingEditTools
            }

            if let toastMessage {
                ToastBanner(message: toastMessage)
                    .padding(.horizontal, 24)
                    .padding(.top, toastPlacement == .top ? 14 : 0)
                    .padding(.bottom, toastPlacement == .lower ? 150 : 0)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: toastPlacement.alignment)
                    .transition(toastPlacement.transition)
                    .zIndex(4)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .preferredColorScheme(.light)
        .alert("Delete deck?", isPresented: $isShowingDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                guard viewModel.deleteDeck() else { return }
                router.goHome()
            }
        } message: {
            Text("This removes \"\(viewModel.deck.name)\" and all of its cards from this device.")
        }
        .alert("Unsaved changes", isPresented: $isShowingUnsavedChangesConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Don't Save", role: .destructive) {
                viewModel.resetDraft()
                router.goBack()
            }
            Button("Save") {
                saveDeck(leaveOpen: false)
            }
        } message: {
            Text("Save your deck changes before leaving?")
        }
        .sheet(isPresented: $isShowingPasteSheet) {
            PasteCardsSheet(viewModel: viewModel)
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $isShowingAddCardSheet) {
            AddCardSheet(viewModel: viewModel) {
                isShowingAddCardSheet = false
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.hidden)
        }
    }

    private var detailContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.section) {
                detailPanel
            }
            .padding(.horizontal, 20)
            .padding(.top, 22)
            .padding(.bottom, 42)
        }
        .scrollIndicators(.hidden)
    }

    private var detailPanel: some View {
        DoodlePanel(background: viewModel.deck.color.displayColor.opacity(0.92)) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.roomy) {
                detailControls

                VStack(alignment: .leading, spacing: AppTheme.Spacing.compact) {
                    Text(viewModel.deck.name)
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .lineLimit(2)
                        .minimumScaleFactor(0.62)

                    Text(viewModel.cardCountText)
                        .font(.system(size: 20, weight: .black, design: .rounded))
                }
                .foregroundStyle(AppTheme.Colors.ink)
                .accessibilityIdentifier("customDeckDetailTitle")

                if viewModel.deck.cards.isEmpty {
                    detailEmptyState
                } else {
                    detailCardPreview
                }

                if let deleteErrorMessage = viewModel.deleteErrorMessage {
                    Text(deleteErrorMessage)
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.coral)
                }
            }
            .padding(AppTheme.Spacing.roomy)
        }
    }

    private var detailControls: some View {
        HStack(spacing: AppTheme.Spacing.standard) {
            DoodleIconButton(
                symbol: "trash",
                accent: AppTheme.Colors.paperBright.opacity(0.66),
                size: 44,
                accessibilityLabel: "Delete deck"
            ) {
                isShowingDeleteConfirmation = true
            }

            DoodleIconButton(
                symbol: "gearshape",
                accent: AppTheme.Colors.paperBright.opacity(0.66),
                size: 44,
                accessibilityLabel: "Edit deck"
            ) {
                isEditingDeckIdentity = true
                viewModel.resetDraft()
            }

            Spacer()

            DoodleIconButton(
                symbol: "xmark",
                accent: AppTheme.Colors.paperBright.opacity(0.78),
                size: 44,
                accessibilityLabel: "Close deck"
            ) {
                router.goBack()
            }
        }
    }

    private var detailEmptyState: some View {
        VStack(spacing: AppTheme.Spacing.standard) {
            EmptyDeckDoodle()
                .frame(height: 150)
                .opacity(0.62)

            Text("Uh oh. Your deck is empty.")
                .font(.system(size: 24, weight: .black, design: .rounded))
                .foregroundStyle(AppTheme.Colors.ink)
                .multilineTextAlignment(.center)

            DoodleActionButton(
                title: "Add cards",
                symbol: "plus",
                accent: AppTheme.Colors.paperBright
            ) {
                isEditingDeckIdentity = true
                viewModel.resetDraft()
            }
            .accessibilityIdentifier("addCardsFromEmptyDeckButton")
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.Spacing.compact)
    }

    private var detailCardPreview: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.roomy) {
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 116), spacing: 10)],
                alignment: .leading,
                spacing: 10
            ) {
                ForEach(viewModel.deck.cards.prefix(16)) { card in
                    WordChip(text: card.text)
                }
            }

            if viewModel.deck.cards.count > 16 {
                Text("+ \(viewModel.deck.cards.count - 16) more")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink.opacity(0.64))
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
    }

    private var editContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.section) {
                editHeader
                if isEditingDeckIdentity {
                    editFormPanel
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                editCardsSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 22)
            .padding(.bottom, 132)
        }
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.interactively)
    }

    private var editHeader: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.standard) {
            HStack(alignment: .center, spacing: AppTheme.Spacing.standard) {
                DoodleIconButton(
                    symbol: "xmark",
                    size: 46,
                    accessibilityLabel: "Close deck"
                ) {
                    closeDeck()
                }

                if isCustomDeck {
                    DoodleIconButton(
                        symbol: "trash",
                        accent: AppTheme.Colors.coral.opacity(0.82),
                        size: 46,
                        accessibilityLabel: "Delete deck"
                    ) {
                        isShowingDeleteConfirmation = true
                    }

                    Spacer()

                    Button {
                        toggleIdentityEditor()
                    } label: {
                        Text(isEditingDeckIdentity ? "Done" : "Edit")
                            .font(.system(size: 16, weight: .black, design: .rounded))
                            .foregroundStyle(AppTheme.Colors.ink)
                            .padding(.horizontal, 15)
                            .frame(height: 46)
                            .background(AppTheme.Colors.blue, in: Capsule())
                            .overlay {
                                Capsule()
                                    .stroke(AppTheme.Colors.ink, lineWidth: AppTheme.Stroke.standard)
                            }
                            .shadow(color: AppTheme.Colors.ink.opacity(0.16), radius: 0, x: 3, y: 3)
                    }
                    .buttonStyle(DoodlePressStyle())
                    .accessibilityIdentifier("editDeckIdentityButton")

                    Button {
                        saveDeck(leaveOpen: true)
                    } label: {
                        HStack(spacing: 8) {
                            Text("Save")
                                .font(.system(size: 17, weight: .black, design: .rounded))

                            Image(systemName: "checkmark")
                                .font(.system(size: 15, weight: .black))
                        }
                        .foregroundStyle(AppTheme.Colors.ink)
                        .padding(.horizontal, 16)
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
                } else {
                    Spacer()
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(isCustomDeck && !viewModel.draftName.isEmpty ? viewModel.draftName : viewModel.deck.name)
                    .font(.system(size: 42, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink)
                    .lineLimit(2)
                    .minimumScaleFactor(0.68)

                Text(isCustomDeck ? viewModel.draftCardCountText : viewModel.cardCountText)
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink.opacity(0.56))
            }

            playDeckButton
        }
    }

    private var playDeckButton: some View {
        DoodleActionButton(
            title: viewModel.draftCards.isEmpty ? "Add cards to play" : "Play deck",
            symbol: viewModel.draftCards.isEmpty ? "exclamationmark.circle.fill" : "play.fill",
            accent: viewModel.draftCards.isEmpty ? AppTheme.Colors.gray.opacity(0.42) : viewModel.draftColor.displayColor
        ) {
            playDeck()
        }
        .disabled(viewModel.draftCards.isEmpty)
        .opacity(viewModel.draftCards.isEmpty ? 0.62 : 1)
        .accessibilityIdentifier("playDeckButton")
    }

    private var editFormPanel: some View {
        DoodlePanel {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.roomy) {
                editNameField
                editColorPicker

                if let saveErrorMessage = viewModel.saveErrorMessage {
                    Text(saveErrorMessage)
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.coral)
                }
            }
            .padding(AppTheme.Spacing.roomy)
        }
    }

    private var editNameField: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.compact) {
            HStack {
                Text("Deck name")
                    .font(.system(size: 17, weight: .black, design: .rounded))

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

    private var editCardsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.standard) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.draftCardCountText)
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.ink.opacity(0.56))
                }

                Spacer()
            }
            .foregroundStyle(AppTheme.Colors.ink)

            if let cardErrorMessage = viewModel.cardErrorMessage {
                Text(cardErrorMessage)
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.coral)
            }

            if viewModel.draftCards.isEmpty {
                VStack(spacing: AppTheme.Spacing.standard) {
                    EmptyDeckDoodle()
                        .frame(height: 145)
                        .opacity(0.36)

                    Text("Your deck is empty\nAdd cards to your deck!")
                        .font(.system(size: 31, weight: .black, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(AppTheme.Colors.ink.opacity(0.52))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                VStack(spacing: 10) {
                    ForEach(viewModel.draftCards) { card in
                        if isCustomDeck {
                            EditCardRow(card: card) {
                                viewModel.deleteDraftCard(id: card.id)
                            }
                        } else {
                            ReadOnlyCardRow(card: card)
                        }
                    }
                }
            }

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

    private func closeDeck() {
        isNameFocused = false

        if viewModel.hasUnsavedChanges {
            isShowingUnsavedChangesConfirmation = true
        } else {
            router.goBack()
        }
    }

    private func saveDeck(leaveOpen: Bool) {
        guard viewModel.saveDraft() != nil else {
            isEditingDeckIdentity = true
            return
        }

        isNameFocused = false
        hideIdentityEditorImmediately()
        showToast("Deck saved", placement: .lower)

        if !leaveOpen {
            router.goBack()
        }
    }

    private func playDeck() {
        if isCustomDeck && viewModel.hasUnsavedChanges {
            guard let savedDeck = viewModel.saveDraft() else {
                isEditingDeckIdentity = true
                return
            }

            isNameFocused = false
            hideIdentityEditorImmediately()
            router.open(.gameSetup(deck: savedDeck))
            return
        }

        router.open(.gameSetup(deck: viewModel.deck))
    }

    private func toggleIdentityEditor() {
        isNameFocused = false

        if isEditingDeckIdentity {
            hideIdentityEditorImmediately()
        } else {
            withAnimation(.snappy(duration: 0.18)) {
                isEditingDeckIdentity = true
            }
        }
    }

    private func hideIdentityEditorImmediately() {
        var transaction = Transaction()
        transaction.animation = nil
        withTransaction(transaction) {
            isEditingDeckIdentity = false
        }
    }

    private func showToast(_ message: String, placement: ToastPlacement = .top) {
        withAnimation(.snappy(duration: 0.16)) {
            toastPlacement = placement
            toastMessage = message
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.35) {
            guard toastMessage == message else { return }
            withAnimation(.snappy(duration: 0.16)) {
                toastMessage = nil
            }
        }
    }
}

private struct EditCardRow: View {
    let card: GameWord
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Text(card.text)
                .font(.system(size: 17, weight: .black, design: .rounded))
                .foregroundStyle(AppTheme.Colors.ink)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 15, weight: .black))
                    .foregroundStyle(AppTheme.Colors.ink)
                    .frame(width: 36, height: 36)
                    .background(AppTheme.Colors.paper, in: Circle())
                    .overlay {
                        Circle()
                            .stroke(AppTheme.Colors.ink, lineWidth: 2)
                    }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Delete \(card.text)")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(AppTheme.Colors.paperBright, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(AppTheme.Colors.ink, lineWidth: 2)
        }
        .shadow(color: AppTheme.Colors.ink.opacity(0.10), radius: 0, x: 3, y: 3)
    }
}

private struct ReadOnlyCardRow: View {
    let card: GameWord

    var body: some View {
        HStack(spacing: 12) {
            Text(card.text)
                .font(.system(size: 17, weight: .black, design: .rounded))
                .foregroundStyle(AppTheme.Colors.ink)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: "rectangle.stack")
                .font(.system(size: 15, weight: .black))
                .foregroundStyle(AppTheme.Colors.ink.opacity(0.42))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(AppTheme.Colors.paperBright, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(AppTheme.Colors.ink, lineWidth: 2)
        }
        .shadow(color: AppTheme.Colors.ink.opacity(0.10), radius: 0, x: 3, y: 3)
    }
}

private struct WordChip: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 15, weight: .black, design: .rounded))
            .foregroundStyle(AppTheme.Colors.ink)
            .lineLimit(1)
            .minimumScaleFactor(0.75)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .frame(maxWidth: .infinity)
            .background(AppTheme.Colors.paperBright.opacity(0.72), in: Capsule())
            .overlay {
                Capsule()
                    .stroke(AppTheme.Colors.ink.opacity(0.48), lineWidth: 2)
            }
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
    @State private var toastMessage: String?
    @FocusState private var isCardFocused: Bool

    var body: some View {
        ZStack {
            AppTheme.Colors.paper
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.roomy) {
                    addCardHeader
                    cardInputPanel
                    addCardButton
                    if let toastMessage {
                        ToastBanner(message: toastMessage)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    currentCardsPreview
                }
                .padding(.horizontal, 20)
                .padding(.top, 22)
                .padding(.bottom, 40)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .onAppear {
            isCardFocused = true
        }
    }

    private var addCardHeader: some View {
        DoodlePanel(background: AppTheme.Colors.paperBright) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.standard) {
                HStack(alignment: .top, spacing: AppTheme.Spacing.standard) {
                    DoodleIconButton(
                        symbol: "xmark",
                        size: 42,
                        accessibilityLabel: "Close add card"
                    ) {
                        onDismiss()
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Add Card")
                            .font(.system(size: 34, weight: .black, design: .rounded))
                            .foregroundStyle(AppTheme.Colors.ink)
                            .lineLimit(1)
                            .minimumScaleFactor(0.72)

                    }
                }
            }
            .padding(AppTheme.Spacing.roomy)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var cardInputPanel: some View {
        DoodlePanel(background: AppTheme.Colors.yellow) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.standard) {
                HStack {
                    Text("Name of card")
                        .font(.system(size: 17, weight: .black, design: .rounded))

                    Spacer()

                    Text(viewModel.cardCharacterCountText(for: cardText))
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.ink.opacity(0.58))
                }

                TextField("Pizza", text: $cardText)
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                    .focused($isCardFocused)
                    .padding(.horizontal, AppTheme.Spacing.standard)
                    .frame(height: 62)
                    .background(
                        AppTheme.Colors.paper,
                        in: RoundedRectangle(cornerRadius: AppTheme.Radius.button, style: .continuous)
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: AppTheme.Radius.button, style: .continuous)
                            .stroke(AppTheme.Colors.ink, lineWidth: AppTheme.Stroke.standard)
                    }
                    .accessibilityIdentifier("manualCardTextField")

                if let cardErrorMessage = viewModel.cardValidationMessage(for: cardText), !cardText.isEmpty {
                    Text(cardErrorMessage)
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.coral)
                }
            }
            .padding(AppTheme.Spacing.roomy)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var addCardButton: some View {
        DoodleActionButton(
            title: "Add card",
            symbol: "plus",
            accent: viewModel.canAddCard(text: cardText) ? AppTheme.Colors.mint : AppTheme.Colors.gray.opacity(0.42)
        ) {
            let addedText = cardText.trimmingCharacters(in: .whitespacesAndNewlines)
            guard viewModel.addCard(text: cardText) else { return }
            cardText = ""
            isCardFocused = true
            showAddedToast(for: addedText)
        }
        .disabled(!viewModel.canAddCard(text: cardText))
        .opacity(viewModel.canAddCard(text: cardText) ? 1 : 0.60)
        .accessibilityIdentifier("addManualCardButton")
    }

    private var currentCardsPreview: some View {
        DoodlePanel(background: AppTheme.Colors.paperBright) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.standard) {
                Text("\(viewModel.draftCards.count) in this deck")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink)

                if viewModel.draftCards.isEmpty {
                    Text("Your new cards will appear here.")
                        .font(.system(size: 17, weight: .black, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.ink.opacity(0.40))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(AppTheme.Spacing.standard)
                        .background(AppTheme.Colors.paper, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                } else {
                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 124), spacing: 10)],
                        alignment: .leading,
                        spacing: 10
                    ) {
                        ForEach(viewModel.draftCards.prefix(12)) { card in
                            ImportPreviewChip(text: card.text)
                        }
                    }

                    if viewModel.draftCards.count > 12 {
                        Text("+ \(viewModel.draftCards.count - 12) more")
                            .font(.system(size: 13, weight: .black, design: .rounded))
                            .foregroundStyle(AppTheme.Colors.ink.opacity(0.58))
                    }
                }
            }
            .padding(AppTheme.Spacing.roomy)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func showAddedToast(for cardText: String) {
        withAnimation(.snappy(duration: 0.16)) {
            toastMessage = "Added \(cardText)"
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.15) {
            guard toastMessage == "Added \(cardText)" else { return }
            withAnimation(.snappy(duration: 0.16)) {
                toastMessage = nil
            }
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
                    importButton
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
                            .lineLimit(2)
                            .minimumScaleFactor(0.72)

                        Text("Put each card on its own line\nLists from AI work great here")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.Colors.ink.opacity(0.64))
                    }
                }

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
                        columns: [GridItem(.adaptive(minimum: 124), spacing: 10)],
                        alignment: .leading,
                        spacing: 10
                    ) {
                        ForEach(viewModel.importPreview.cards.prefix(12), id: \.self) { card in
                            ImportPreviewChip(text: card)
                        }
                    }

                    if viewModel.importPreview.cards.count > 12 {
                        Text("+ \(viewModel.importPreview.cards.count - 12) more")
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
            guard viewModel.importCards(from: pastedText) > 0 else { return }
            pastedText = ""
            dismiss()
        }
        .disabled(!viewModel.importPreview.hasImportableCards)
        .opacity(viewModel.importPreview.hasImportableCards ? 1 : 0.60)
        .accessibilityIdentifier("importClipboardCardsButton")
    }
}

private struct ImportPreviewChip: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 16, weight: .black, design: .rounded))
            .foregroundStyle(AppTheme.Colors.ink)
            .lineLimit(1)
            .minimumScaleFactor(0.72)
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .frame(maxWidth: .infinity)
            .background(AppTheme.Colors.paper, in: Capsule())
            .overlay {
                Capsule()
                    .stroke(AppTheme.Colors.ink.opacity(0.42), lineWidth: 2)
            }
            .shadow(color: AppTheme.Colors.ink.opacity(0.08), radius: 0, x: 2, y: 2)
    }
}

private enum ToastPlacement {
    case top
    case lower

    var alignment: Alignment {
        switch self {
        case .top:
            return .top
        case .lower:
            return .bottom
        }
    }

    var transition: AnyTransition {
        switch self {
        case .top:
            return .move(edge: .top).combined(with: .opacity)
        case .lower:
            return .move(edge: .bottom).combined(with: .opacity)
        }
    }
}

private struct ToastBanner: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.system(size: 15, weight: .black, design: .rounded))
            .foregroundStyle(AppTheme.Colors.ink)
            .lineLimit(1)
            .minimumScaleFactor(0.76)
            .padding(.horizontal, 18)
            .frame(height: 44)
            .background(AppTheme.Colors.paperBright, in: Capsule())
            .overlay {
                Capsule()
                    .stroke(AppTheme.Colors.ink, lineWidth: AppTheme.Stroke.standard)
            }
            .shadow(color: AppTheme.Colors.ink.opacity(0.16), radius: 0, x: 3, y: 3)
            .accessibilityIdentifier("deckToastBanner")
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
