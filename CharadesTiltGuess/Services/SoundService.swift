import AVFoundation
import Foundation

enum SoundEffect: String, CaseIterable {
    case correct
    case pass
    case startCountdown
    case gameStart
    case endCountdown
    case timeout

    var resourceName: String {
        switch self {
        case .correct, .pass, .gameStart, .timeout:
            return rawValue
        case .startCountdown:
            return "countdown"
        case .endCountdown:
            return "endCountDown"
        }
    }
}

final class SoundService {
    static let shared = SoundService()

    private var players: [SoundEffect: AVAudioPlayer] = [:]

    init(bundle: Bundle = .main) {
        for effect in SoundEffect.allCases {
            guard let url = bundle.url(forResource: effect.resourceName, withExtension: "wav"),
                  let player = try? AVAudioPlayer(contentsOf: url)
            else {
                continue
            }

            player.prepareToPlay()
            players[effect] = player
        }
    }

    func play(_ effect: SoundEffect, enabled: Bool) {
        guard enabled, let player = players[effect] else { return }

        player.currentTime = 0
        player.play()
    }
}
