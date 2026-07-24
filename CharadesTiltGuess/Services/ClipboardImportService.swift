import Foundation

struct ParsedCard: Equatable, Hashable {
    let text: String
    let meaning: String?
}

struct ClipboardImportPreview: Equatable {
    let cards: [ParsedCard]
    let blankLineCount: Int
    let duplicateCount: Int
    let tooLongLines: [String]
    let overDeckLimitCount: Int
    let maxCardLength: Int
    let invalidEmojiCardsCount: Int
    let missingMeaningCardsCount: Int

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

        if invalidEmojiCardsCount > 0 {
            messages.append("\(invalidEmojiCardsCount) \(invalidEmojiCardsCount == 1 ? "card" : "cards") skipped (no emoji found).")
        }

        if missingMeaningCardsCount > 0 {
            messages.append("\(missingMeaningCardsCount) \(missingMeaningCardsCount == 1 ? "card" : "cards") skipped (missing meaning/answer).")
        }

        return messages
    }
}

struct ClipboardImportService {
    let maxCardLength: Int

    init(maxCardLength: Int = 30) {
        self.maxCardLength = maxCardLength
    }

    func previewCards(from text: String, existingCards: [GameWord] = [], isEmoji: Bool = false) -> ClipboardImportPreview {
        var cards: [ParsedCard] = []
        var blankLineCount = 0
        var duplicateCount = 0
        var tooLongLines: [String] = []
        var invalidEmojiCardsCount = 0
        var missingMeaningCardsCount = 0
        var seen = Set(existingCards.map { normalized($0.text) })

        let lines = text.components(separatedBy: .newlines)
        for rawLine in lines {
            let trimmedLine = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedLine.isEmpty else {
                blankLineCount += 1
                continue
            }

            let lineWithoutMarker = strippingListMarker(from: trimmedLine)
            guard !lineWithoutMarker.isEmpty else {
                blankLineCount += 1
                continue
            }

            let candidates: [ParsedCard]
            if isEmoji {
                // For emoji mode, allow :, -, or , as separators
                let separators = [":", " - ", ","]
                var bestSeparatorIndex: String.Index? = nil
                var matchedSeparator: String = ""

                for sep in separators {
                    if let range = lineWithoutMarker.range(of: sep) {
                        let index = range.lowerBound
                        if bestSeparatorIndex == nil || index < bestSeparatorIndex! {
                            bestSeparatorIndex = index
                            matchedSeparator = sep
                        }
                    }
                }

                if let index = bestSeparatorIndex {
                    let left = String(lineWithoutMarker[..<index]).trimmingCharacters(in: .whitespacesAndNewlines)
                    let right = String(lineWithoutMarker[lineWithoutMarker.index(index, offsetBy: matchedSeparator.count)...]).trimmingCharacters(in: .whitespacesAndNewlines)
                    candidates = [ParsedCard(text: left, meaning: right.isEmpty ? nil : right)]
                } else {
                    candidates = [ParsedCard(text: lineWithoutMarker, meaning: nil)]
                }
            } else {
                // For normal decks, clues/meanings do not exist.
                // If line contains commas, split by comma for multiple cards per line.
                if lineWithoutMarker.contains(",") {
                    let parts = lineWithoutMarker.split(separator: ",", omittingEmptySubsequences: false)
                    candidates = parts.compactMap { part in
                        let item = strippingListMarker(from: String(part)).trimmingCharacters(in: .whitespacesAndNewlines)
                        return item.isEmpty ? nil : ParsedCard(text: item, meaning: nil)
                    }
                } else {
                    candidates = [ParsedCard(text: lineWithoutMarker, meaning: nil)]
                }
            }

            for candidate in candidates {
                let itemText = candidate.text
                let itemMeaning = candidate.meaning

                guard !itemText.isEmpty else {
                    blankLineCount += 1
                    continue
                }

                guard itemText.count <= maxCardLength else {
                    tooLongLines.append(itemText)
                    continue
                }

                if isEmoji {
                    if !itemText.containsEmoji {
                        invalidEmojiCardsCount += 1
                        continue
                    }
                    if itemMeaning == nil || itemMeaning!.isEmpty {
                        missingMeaningCardsCount += 1
                        continue
                    }
                }

                let normalizedLine = normalized(itemText)
                guard seen.insert(normalizedLine).inserted else {
                    duplicateCount += 1
                    continue
                }

                cards.append(ParsedCard(text: itemText, meaning: itemMeaning))
            }
        }

        return ClipboardImportPreview(
            cards: cards,
            blankLineCount: blankLineCount,
            duplicateCount: duplicateCount,
            tooLongLines: tooLongLines,
            overDeckLimitCount: 0,
            maxCardLength: maxCardLength,
            invalidEmojiCardsCount: invalidEmojiCardsCount,
            missingMeaningCardsCount: missingMeaningCardsCount
        )
    }

    private func normalized(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
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
