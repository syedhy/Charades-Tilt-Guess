import AVFoundation
import Foundation

enum SoundEffect: String, CaseIterable {
    case correct
    case pass
    case countdown
    case timeout

    var filename: String {
        "\(rawValue).wav"
    }
}

final class SoundService {
    static let shared = SoundService()

    private var players: [SoundEffect: AVAudioPlayer] = [:]

    init(bundle: Bundle = .main) {
        for effect in SoundEffect.allCases {
            guard let url = bundle.url(forResource: effect.rawValue, withExtension: "wav"),
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
