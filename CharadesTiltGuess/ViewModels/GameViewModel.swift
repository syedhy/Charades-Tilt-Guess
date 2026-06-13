import Foundation
import SwiftUI

@MainActor
final class GameViewModel: ObservableObject {
    @Published private(set) var timeRemaining: Int
    @Published private(set) var currentWordText: String
    @Published private(set) var score: Int = 0
    @Published private(set) var passedCount: Int = 0
    @Published private(set) var feedback: WordStatus?
    @Published var isPaused = false

    private var engine: GameEngine
    private var timerTask: Task<Void, Never>?
    private var hasFinished = false
    private let onFinish: (RoundResult) -> Void

    init(deck: Deck, duration: Int, onFinish: @escaping (RoundResult) -> Void) {
        let engine = GameEngine(deck: deck, duration: duration)
        self.engine = engine
        self.timeRemaining = duration
        self.currentWordText = engine.currentWord?.text ?? "No cards"
        self.onFinish = onFinish
    }

    deinit {
        timerTask?.cancel()
    }

    func startTimerIfNeeded() {
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
    }

    func resume() {
        isPaused = false
    }

    func endRound() {
        finishRound()
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
        onFinish(result)
    }
}
