import Foundation

struct ClipboardImportPreview: Equatable {
    let cards: [String]
    let blankLineCount: Int
    let duplicateCount: Int
    let tooLongLines: [String]
    let overDeckLimitCount: Int
    let maxCardLength: Int

    var hasImportableCards: Bool {
        !cards.isEmpty
    }

    var summaryMessages: [String] {
        var messages: [String] = []

        if blankLineCount > 0 {
            messages.append("\(blankLineCount) blank \(blankLineCount == 1 ? "line was" : "lines were") ignored.")
        }

        if duplicateCount > 0 {
            messages.append("\(duplicateCount) duplicate \(duplicateCount == 1 ? "card was" : "cards were") skipped.")
        }

        if !tooLongLines.isEmpty {
            messages.append("\(tooLongLines.count) \(tooLongLines.count == 1 ? "card is" : "cards are") over \(maxCardLength) characters.")
        }

        if overDeckLimitCount > 0 {
            messages.append("\(overDeckLimitCount) \(overDeckLimitCount == 1 ? "card was" : "cards were") skipped because custom decks are limited to 1500 cards.")
        }

        return messages
    }
}

struct ClipboardImportService {
    let maxCardLength: Int

    init(maxCardLength: Int = 30) {
        self.maxCardLength = maxCardLength
    }

    func previewCards(from text: String, existingCards: [GameWord] = []) -> ClipboardImportPreview {
        var cards: [String] = []
        var blankLineCount = 0
        var duplicateCount = 0
        var tooLongLines: [String] = []
        var seen = Set(existingCards.map { normalized($0.text) })

        for rawLine in candidateCardTexts(from: text) {
            let trimmedLine = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)

            guard !trimmedLine.isEmpty else {
                blankLineCount += 1
                continue
            }

            guard trimmedLine.count <= maxCardLength else {
                tooLongLines.append(trimmedLine)
                continue
            }

            let normalizedLine = normalized(trimmedLine)
            guard seen.insert(normalizedLine).inserted else {
                duplicateCount += 1
                continue
            }

            cards.append(trimmedLine)
        }

        return ClipboardImportPreview(
            cards: cards,
            blankLineCount: blankLineCount,
            duplicateCount: duplicateCount,
            tooLongLines: tooLongLines,
            overDeckLimitCount: 0,
            maxCardLength: maxCardLength
        )
    }

    private func normalized(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private func candidateCardTexts(from text: String) -> [String] {
        text.components(separatedBy: .newlines)
            .flatMap { line in
                line.split(separator: ",", omittingEmptySubsequences: false).map(String.init)
            }
            .map(strippingListMarker)
    }

    private func strippingListMarker(from rawText: String) -> String {
        var text = rawText.trimmingCharacters(in: .whitespacesAndNewlines)

        if let first = text.first, first == "-" || first == "*" || first == "•" {
            text.removeFirst()
            return text.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        var digitPrefix = ""
        for character in text {
            guard character.isNumber else { break }
            digitPrefix.append(character)
        }

        guard !digitPrefix.isEmpty else { return text }

        let index = text.index(text.startIndex, offsetBy: digitPrefix.count)
        guard index < text.endIndex else { return text }

        let marker = text[index]
        guard marker == "." || marker == ")" || marker == "-" || marker == ":" else { return text }

        text.removeSubrange(text.startIndex...index)
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
