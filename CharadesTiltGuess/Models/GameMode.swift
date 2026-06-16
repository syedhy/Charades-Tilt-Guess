import SwiftUI

enum GameMode: String, Codable, CaseIterable, Hashable, Identifiable {
    case normal
    case pasteAndPlay
    case infinite
    case hotPotato
    case challengeCards
    case wikipedia

    var id: String { rawValue }

    var title: String {
        switch self {
        case .normal:
            return "Normal"
        case .pasteAndPlay:
            return "Paste & Play"
        case .infinite:
            return "Infinite"
        case .hotPotato:
            return "Hot Potato"
        case .challengeCards:
            return "Challenge Cards"
        case .wikipedia:
            return "Wikipedia Mode"
        }
    }

    var description: String {
        switch self {
        case .normal:
            return "Classic timed charades with a deck you choose."
        case .pasteAndPlay:
            return "Paste any list and jump into a round in seconds."
        case .infinite:
            return "No timer. Keep guessing until you end the round."
        case .hotPotato:
            return "Pass the phone around before the hidden timer explodes."
        case .challengeCards:
            return "Classic play, but surprise rules make some cards harder."
        case .wikipedia:
            return "Play with random article titles from Wikipedia."
        }
    }

    var purpose: String {
        switch self {
        case .normal:
            return "Fast party rounds"
        case .pasteAndPlay:
            return "Instant custom lists"
        case .infinite:
            return "Practice or chill play"
        case .hotPotato:
            return "High-pressure group chaos"
        case .challengeCards:
            return "Sillier acting prompts"
        case .wikipedia:
            return "Unexpected trivia energy"
        }
    }

    var symbolName: String {
        switch self {
        case .normal:
            return "play.fill"
        case .pasteAndPlay:
            return "doc.on.clipboard"
        case .infinite:
            return "infinity"
        case .hotPotato:
            return "timer"
        case .challengeCards:
            return "sparkles"
        case .wikipedia:
            return "globe"
        }
    }

    var accentColor: Color {
        switch self {
        case .normal:
            return AppTheme.Colors.mint
        case .pasteAndPlay:
            return AppTheme.Colors.yellow
        case .infinite:
            return AppTheme.Colors.blue
        case .hotPotato:
            return AppTheme.Colors.coral
        case .challengeCards:
            return AppTheme.Colors.orange
        case .wikipedia:
            return Color(red: 0.66, green: 0.58, blue: 0.86)
        }
    }

    var usesDeckSelection: Bool {
        switch self {
        case .normal, .infinite, .hotPotato, .challengeCards:
            return true
        case .pasteAndPlay, .wikipedia:
            return false
        }
    }

    var showsDurationPicker: Bool {
        switch self {
        case .normal, .pasteAndPlay, .challengeCards, .wikipedia:
            return true
        case .infinite, .hotPotato:
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
        case .infinite:
            return ModeInstruction(
                title: "No timer",
                summary: "Play continuously until someone ends the round.",
                rules: [
                    "Pick any deck and start when everyone is ready.",
                    "Cards keep rotating, even after the deck is exhausted.",
                    "Use pause to resume or end the round manually."
                ],
                scoring: "Results are created when you end the round."
            )
        case .hotPotato:
            return ModeInstruction(
                title: "Hidden timer",
                summary: "Players pass the phone around. Whoever holds it when time expires loses.",
                rules: [
                    "Choose a deck, then start without knowing the timer length.",
                    "After each guess or pass, hand the phone to the next player.",
                    "When Time Up appears, the current holder loses."
                ],
                scoring: "Correct and passed cards are tracked, but the main outcome is survival."
            )
        case .challengeCards:
            return ModeInstruction(
                title: "Surprise rules",
                summary: "Some cards carry a challenge like silent acting or one-word clues.",
                rules: [
                    "Play like Normal mode.",
                    "When a challenge banner appears, follow that rule for the current card.",
                    "New challenges can be added without changing the game loop."
                ],
                scoring: "Correct challenge cards score the same as normal cards."
            )
        case .wikipedia:
            return ModeInstruction(
                title: "Random article titles",
                summary: "The app loads public random Wikipedia article titles into a temporary deck.",
                rules: [
                    "Load a fresh pack when you enter the mode.",
                    "Retry if the network fails or Wikipedia returns no usable titles.",
                    "The deck is temporary and is not saved."
                ],
                scoring: "Scoring matches Normal mode."
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
