import Foundation

enum ChallengeCard: String, Codable, CaseIterable, Hashable, Identifiable {
    case silentAct
    case oneWordOnly
    case slowMotion
    case soundEffectsOnly

    var id: String { rawValue }

    var title: String {
        switch self {
        case .silentAct:
            return "Act silently"
        case .oneWordOnly:
            return "One word only"
        case .slowMotion:
            return "Slow motion"
        case .soundEffectsOnly:
            return "Sound effects only"
        }
    }

    var description: String {
        switch self {
        case .silentAct:
            return "No words or sounds for this card."
        case .oneWordOnly:
            return "You may say one clue word total."
        case .slowMotion:
            return "Act everything in dramatic slow motion."
        case .soundEffectsOnly:
            return "Use noises only. No clue words."
        }
    }

    var symbolName: String {
        switch self {
        case .silentAct:
            return "speaker.slash.fill"
        case .oneWordOnly:
            return "textformat.abc"
        case .slowMotion:
            return "tortoise.fill"
        case .soundEffectsOnly:
            return "waveform"
        }
    }
}

struct ChallengeCardProvider: Hashable {
    var challengeEvery: Int = 4
    var challenges: [ChallengeCard] = ChallengeCard.allCases

    func challenge(forSequence sequence: Int) -> ChallengeCard? {
        guard challengeEvery > 0,
              sequence > 0,
              sequence % challengeEvery == 0,
              !challenges.isEmpty
        else {
            return nil
        }

        return challenges[(sequence / challengeEvery - 1) % challenges.count]
    }
}
