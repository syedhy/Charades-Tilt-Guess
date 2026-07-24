import SwiftUI

enum GameMode: String, Codable, CaseIterable, Hashable, Identifiable {
    case normal
    case emoji
    case pasteAndPlay
    case mixAndMatch
    case infinite
    case randomMode
    case teamVsTeam

    var id: String { rawValue }

    static let homeModes: [GameMode] = [.normal, .emoji, .mixAndMatch, .infinite, .randomMode, .teamVsTeam]

    var title: String {
        switch self {
        case .normal:
            return "Normal"
        case .emoji:
            return "Emoji Mode"
        case .pasteAndPlay:
            return "Paste & Play"
        case .mixAndMatch:
            return "Mix & Match"
        case .infinite:
            return "Infinite"
        case .randomMode:
            return "Random Mode"
        case .teamVsTeam:
            return "Team vs Team"
        }
    }

    var description: String {
        switch self {
        case .normal:
            return "Classic timed charades with a deck you choose"
        case .emoji:
            return "Guess the secret meaning behind emoji puzzles"
        case .pasteAndPlay:
            return "Paste any list and jump into a round in seconds"
        case .mixAndMatch:
            return "Play a random mix of cards from your decks"
        case .infinite:
            return "No timer! Play until the deck is done"
        case .randomMode:
            return "Surprise game mode & deck combination"
        case .teamVsTeam:
            return "Divide into two teams and compete for the highest score"
        }
    }

    var purpose: String {
        switch self {
        case .normal:
            return "Fast party rounds"
        case .emoji:
            return "Emoji puzzles"
        case .pasteAndPlay:
            return "Instant custom lists"
        case .mixAndMatch:
            return "A fresh mix of cards"
        case .infinite:
            return "Finish every card"
        case .randomMode:
            return "Surprise setup"
        case .teamVsTeam:
            return "Competitive team play"
        }
    }

    var symbolName: String {
        switch self {
        case .normal:
            return "play.fill"
        case .emoji:
            return "face.smiling.fill"
        case .pasteAndPlay:
            return "doc.on.clipboard"
        case .mixAndMatch:
            return "square.stack.3d.up.fill"
        case .infinite:
            return "infinity"
        case .randomMode:
            return "die.face.5.fill"
        case .teamVsTeam:
            return "person.2.fill"
        }
    }

    var accentColor: Color {
        switch self {
        case .normal:
            return AppTheme.Colors.mint
        case .emoji:
            return AppTheme.Colors.yellow
        case .pasteAndPlay:
            return AppTheme.Colors.yellow
        case .mixAndMatch:
            return AppTheme.Colors.orange
        case .infinite:
            return AppTheme.Colors.blue
        case .randomMode:
            return AppTheme.Colors.coral
        case .teamVsTeam:
            return AppTheme.Colors.coral
        }
    }

    var usesDeckSelection: Bool {
        switch self {
        case .normal, .emoji, .infinite, .teamVsTeam:
            return true
        case .pasteAndPlay, .mixAndMatch, .randomMode:
            return false
        }
    }

    var showsDurationPicker: Bool {
        switch self {
        case .normal, .emoji, .pasteAndPlay, .mixAndMatch, .randomMode, .teamVsTeam:
            return true
        case .infinite:
            return false
        }
    }

    var instruction: ModeInstruction {
        switch self {
        case .normal:
            return ModeInstruction(
                title: "Classic charades",
                summary: "Pick a deck, set a timer, and race through as many cards as you can.",
                rules: [
                    "Hold the phone on your forehead so your team can see the card.",
                    "Tilt down or swipe down when your team guesses correctly.",
                    "Tilt up or swipe up to pass a card.",
                    "The score is your correct count before time runs out."
                ],
                scoring: "Correct cards score one point. Passed cards are tracked but do not score."
            )
        case .emoji:
            return ModeInstruction(
                title: "Emoji Charades",
                summary: "Guess the secret meaning behind the emojis on screen.",
                rules: [
                    "Hold the phone on your forehead.",
                    "Your team acts out or describes the emoji puzzle.",
                    "Tilt down for correct, tilt up to pass.",
                    "Check results at the end of the round to reveal all emoji meanings!"
                ],
                scoring: "Correct cards score one point. Secret meanings revealed in round results."
            )
        case .pasteAndPlay:
            return ModeInstruction(
                title: "Paste & Play",
                summary: "Turn any quick list into a temporary deck.",
                rules: [
                    "Paste words separated by lines, commas, or numbered list markers.",
                    "Review the parsed cards, then tap Play.",
                    "The deck is temporary and disappears after the session."
                ],
                scoring: "Scoring matches Normal mode."
            )
        case .mixAndMatch:
            return ModeInstruction(
                title: "Mix every deck",
                summary: "Start with freshly shuffled cards from built-in and custom decks.",
                rules: [
                    "The app combines cards from your chosen decks.",
                    "Equivalent duplicate words are removed before shuffling.",
                    "Each new round selects a fresh set of random cards."
                ],
                scoring: "Scoring matches Normal mode."
            )
        case .infinite:
            return ModeInstruction(
                title: "No timer",
                summary: "Play through the whole deck without a countdown.",
                rules: [
                    "Pick any deck and start when everyone is ready.",
                    "Correct or pass each card.",
                    "The round ends automatically when every card has appeared."
                ],
                scoring: "Correct cards score one point. Passed cards are tracked but do not score."
            )
        case .randomMode:
            return ModeInstruction(
                title: "Random Mode",
                summary: "Surprise game mode and deck selection.",
                rules: [
                    "Tap the refresh button to reroll a random mode and deck setup.",
                    "Filter whether to include custom decks or built-in decks.",
                    "Tap Start Game to play the surprise roll!"
                ],
                scoring: "Scoring matches the rolled game mode."
            )
        case .teamVsTeam:
            return ModeInstruction(
                title: "Team vs Team",
                summary: "Split into two teams and compete.",
                rules: [
                    "Form two teams.",
                    "Teams alternate turns to guess words.",
                    "The team with the most points wins."
                ],
                scoring: "Correct cards score one point. Passed cards do not score."
            )
        }
    }
}

struct ModeInstruction: Hashable {
    let title: String
    let summary: String
    let rules: [String]
    let scoring: String
}
