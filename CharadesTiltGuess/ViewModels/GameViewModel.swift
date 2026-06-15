import Foundation
import SwiftUI

@MainActor
final class GameViewModel: ObservableObject {
    @Published private(set) var timeRemaining: Int
    @Published private(set) var currentWordText: String
    @Published private(set) var score: Int = 0
    @Published private(set) var passedCount: Int = 0
    @Published private(set) var feedback: WordStatus?
    @Published private(set) var tiltStatusText = "Tilt controls need a real iPhone"
    @Published private(set) var isTiltAvailable = false
    @Published var isPaused = false

    private var engine: GameEngine
    private var timerTask: Task<Void, Never>?
    private var motionManager: MotionManager?
    private let settings: GameSettings
    private let hapticsManager: HapticsManager
    private var hasFinished = false
    private let onFinish: (RoundResult) -> Void

    init(
        deck: Deck,
        duration: Int,
        settings: GameSettings = .default,
        hapticsManager: HapticsManager = .shared,
        onFinish: @escaping (RoundResult) -> Void
    ) {
        let engine = GameEngine(deck: deck, duration: duration)
        self.engine = engine
        self.timeRemaining = duration
        self.currentWordText = engine.currentWord?.text ?? "No cards"
        self.settings = settings
        self.hapticsManager = hapticsManager
        self.onFinish = onFinish
    }

    deinit {
        timerTask?.cancel()

        if let motionManager {
            Task { @MainActor in
                motionManager.stop()
            }
        }
    }

    func startRoundSystemsIfNeeded() {
        startTimerIfNeeded()
        startMotionIfAvailable()
    }

    private func startTimerIfNeeded() {
        guard timerTask == nil else { return }

        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))

                await MainActor.run {
                    guard let self, !self.hasFinished, !self.isPaused else { return }

                    if self.timeRemaining > 0 {
                        self.timeRemaining -= 1
                    }

                    if self.timeRemaining <= 0 {
                        self.finishRound()
                    }
                }
            }
        }
    }

    func mark(_ status: WordStatus) {
        guard !hasFinished, !isPaused else { return }

        feedback = status
        if settings.hapticsEnabled {
            hapticsManager.play(status)
        }

        let result = engine.markCurrentWord(status)
        syncFromEngine()

        Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(280))
            await MainActor.run {
                guard let self, !self.hasFinished else { return }
                self.feedback = nil
            }
        }

        if let result {
            finishRound(with: result)
        }
    }

    func togglePause() {
        isPaused.toggle()

        if isPaused {
            motionManager?.stop()
        } else {
            startMotionIfAvailable()
        }
    }

    func resume() {
        isPaused = false
        startMotionIfAvailable()
    }

    func endRound() {
        finishRound()
    }

    private func startMotionIfAvailable() {
        guard !hasFinished, !isPaused else { return }

        if motionManager == nil {
            motionManager = MotionManager(sensitivity: settings.tiltSensitivity)
        }

        guard let motionManager, motionManager.isAvailable else {
            isTiltAvailable = false
            tiltStatusText = "Tilt controls need a real iPhone"
            return
        }

        isTiltAvailable = true
        tiltStatusText = "Top forward for correct, top back to pass"
        motionManager.start { [weak self] action in
            self?.handleTiltAction(action)
        }
    }

    private func handleTiltAction(_ action: TiltAction) {
        guard !hasFinished, !isPaused else { return }

        switch action {
        case .correct:
            markFromTilt(.correct)
        case .pass:
            markFromTilt(.passed)
        case .neutral:
            feedback = nil
        }
    }

    private func markFromTilt(_ status: WordStatus) {
        feedback = status
        if settings.hapticsEnabled {
            hapticsManager.play(status)
        }

        let result = engine.markCurrentWord(status)
        syncFromEngine()

        if let result {
            finishRound(with: result)
        }
    }

    private func syncFromEngine() {
        currentWordText = engine.currentWord?.text ?? "All done"
        score = engine.session.score
        passedCount = engine.session.passedWords.count
    }

    private func finishRound() {
        finishRound(with: engine.finishRound())
    }

    private func finishRound(with result: RoundResult) {
        guard !hasFinished else { return }

        hasFinished = true
        timerTask?.cancel()
        timerTask = nil
        motionManager?.stop()
        if settings.hapticsEnabled {
            hapticsManager.playRoundFinished()
        }
        onFinish(result)
    }
}
