import Foundation

struct ClipboardImportPreview: Equatable {
    let cards: [String]
    let blankLineCount: Int
    let duplicateCount: Int
    let tooLongLines: [String]

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
            messages.append("\(tooLongLines.count) \(tooLongLines.count == 1 ? "card is" : "cards are") over 50 characters.")
        }

        return messages
    }
}

struct ClipboardImportService {
    let maxCardLength: Int

    init(maxCardLength: Int = 50) {
        self.maxCardLength = maxCardLength
    }

    func previewCards(from text: String, existingCards: [GameWord] = []) -> ClipboardImportPreview {
        var cards: [String] = []
        var blankLineCount = 0
        var duplicateCount = 0
        var tooLongLines: [String] = []
        var seen = Set(existingCards.map { normalized($0.text) })

        for rawLine in text.components(separatedBy: .newlines) {
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
            tooLongLines: tooLongLines
        )
    }

    private func normalized(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}
