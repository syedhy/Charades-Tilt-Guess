import Foundation
import SwiftUI

enum GamePlayPhase: Equatable {
    case preparing
    case countdown
    case playing
    case paused
    case timeUp
    case finished
}

@MainActor
final class GameViewModel: ObservableObject {
    @Published private(set) var phase: GamePlayPhase = .preparing
    @Published private(set) var timeRemaining: Int
    @Published private(set) var elapsedSeconds = 0
    @Published private(set) var countdownValue: Int?
    @Published private(set) var currentWordText: String
    @Published private(set) var currentChallenge: ChallengeCard?
    @Published private(set) var score: Int = 0
    @Published private(set) var passedCount: Int = 0
    @Published private(set) var feedback: WordStatus?
    @Published private(set) var tiltStatusText = "Hold steady to start"
    @Published private(set) var isTiltAvailable = false
    @Published var isPaused = false

    private var engine: GameEngine
    private var timerTask: Task<Void, Never>?
    private var countdownTask: Task<Void, Never>?
    private var timeUpTask: Task<Void, Never>?
    private var finishPresentationTask: Task<Void, Never>?
    private var motionManager: MotionManager?
    private let configuration: GameConfiguration
    private let settings: GameSettings
    private let hapticsManager: HapticsManager
    private let soundService: SoundService
    private let cardRotationStore: CardRotationStore
    private var hasFinished = false
    private var hasStartedSystems = false
    private let onFinish: (RoundResult) -> Void

    init(
        configuration: GameConfiguration,
        settings: GameSettings = .default,
        hapticsManager: HapticsManager = .shared,
        soundService: SoundService = .shared,
        cardRotationStore: CardRotationStore = CardRotationStore(),
        onFinish: @escaping (RoundResult) -> Void
    ) {
        let orderedWords = configuration.isTemporaryDeck
            ? configuration.deck.cards.shuffled()
            : cardRotationStore.orderedCards(for: configuration.deck)
        let engine = GameEngine(configuration: configuration, orderedWords: orderedWords)

        self.configuration = configuration
        self.engine = engine
        self.timeRemaining = configuration.activeDuration ?? 0
        self.currentWordText = engine.currentWord?.text ?? "No cards"
        self.currentChallenge = engine.currentChallenge
        self.settings = settings.normalized
        self.hapticsManager = hapticsManager
        self.soundService = soundService
        self.cardRotationStore = cardRotationStore
        self.onFinish = onFinish
    }

    deinit {
        timerTask?.cancel()
        countdownTask?.cancel()
        timeUpTask?.cancel()
        finishPresentationTask?.cancel()

        if let motionManager {
            Task { @MainActor in
                motionManager.stop()
            }
        }
    }

    var isPreparing: Bool {
        phase == .preparing
    }

    var isCountingDown: Bool {
        phase == .countdown
    }

    var isTimeUp: Bool {
        phase == .timeUp
    }

    var shouldShowManualReadyButton: Bool {
        phase == .preparing && (!settings.motionControlsEnabled || !isTiltAvailable)
    }

    var shouldShowSwipeControls: Bool {
        settings.effectiveSwipeControlsEnabled && phase == .playing
    }

    var timerText: String {
        guard configuration.usesTimer else { return "∞" }
        return configuration.hidesTimer ? "?" : "\(timeRemaining)"
    }

    var preparationTitle: String {
        if settings.motionControlsEnabled && isTiltAvailable {
            return "Place phone on your forehead"
        }

        return "Ready position"
    }

    var preparationMessage: String {
        if settings.motionControlsEnabled && isTiltAvailable {
            return "Hold the phone steady in neutral. Countdown starts automatically."
        }

        return "Hold the phone up, then tap Ready. Swipe controls will handle the round."
    }

    func startRoundSystemsIfNeeded() {
        guard !hasStartedSystems else { return }

        hasStartedSystems = true
        startPreparation()
    }

    func beginCountdownManually() {
        guard shouldShowManualReadyButton else { return }
        beginCountdown()
    }

    func mark(_ status: WordStatus) {
        guard !hasFinished, phase == .playing else { return }

        feedback = status
        playFeedback(for: status)

        let result = engine.markCurrentWord(status)
        syncFromEngine()

        Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(240))
            await MainActor.run {
                guard let self, !self.hasFinished, self.phase == .playing else { return }
                self.feedback = nil
            }
        }

        if let result {
            finishRound(with: result, wasTimeUp: false)
        }
    }

    func handleSwipe(translation: CGSize) {
        guard shouldShowSwipeControls else { return }

        if translation.height < -40 {
            mark(.passed)
        } else if translation.height > 40 {
            mark(.correct)
        }
    }

    func togglePause() {
        if phase == .paused {
            resume()
        } else if phase == .playing {
            pause()
        }
    }

    func pause() {
        guard phase == .playing else { return }

        phase = .paused
        isPaused = true
        motionManager?.stop()
        if settings.hapticsEnabled {
            hapticsManager.playPause()
        }
    }

    func resume() {
        guard phase == .paused else { return }

        phase = .playing
        isPaused = false
        startMotionForGameplay()
    }

    func endRound() {
        finishRound(wasTimeUp: false)
    }

    private func startPreparation() {
        phase = .preparing
        isPaused = false

        guard settings.motionControlsEnabled else {
            isTiltAvailable = false
            tiltStatusText = "Swipe controls are ready"
            return
        }

        startMotionForPreparation()
    }

    private func startMotionForPreparation() {
        if motionManager == nil {
            motionManager = MotionManager(sensitivity: settings.tiltSensitivity)
        }

        guard let motionManager, motionManager.isAvailable else {
            isTiltAvailable = false
            tiltStatusText = "Motion unavailable. Swipe controls are ready."
            return
        }

        isTiltAvailable = true
        tiltStatusText = "Find neutral position"
        motionManager.start(
            onAction: { _ in },
            onNeutralDetected: { [weak self] in
                self?.handleNeutralDetected()
            }
        )
    }

    private func handleNeutralDetected() {
        guard phase == .preparing else { return }

        tiltStatusText = "Neutral locked"
        if settings.hapticsEnabled {
            hapticsManager.playPreparationReady()
        }
        beginCountdown()
    }

    private func beginCountdown() {
        guard phase == .preparing else { return }

        motionManager?.stop()
        phase = .countdown
        countdownTask?.cancel()
        countdownTask = Task { @MainActor [weak self] in
            guard let self else { return }

            for value in [3, 2, 1] {
                guard !Task.isCancelled, !self.hasFinished else { return }
                self.countdownValue = value
                if self.settings.soundsEnabled {
                    self.soundService.play(.startCountdown, enabled: true)
                }
                if self.settings.hapticsEnabled {
                    self.hapticsManager.playCountdownTick(urgency: Double(4 - value) / 3.0)
                }
                try? await Task.sleep(for: .seconds(1))
            }

            guard !Task.isCancelled, !self.hasFinished else { return }
            self.countdownValue = nil
            self.phase = .playing
            if self.settings.soundsEnabled {
                self.soundService.play(.gameStart, enabled: true)
            }
            if self.settings.hapticsEnabled {
                self.hapticsManager.playCountdownStart()
            }
            self.startTimerIfNeeded()
            self.startMotionForGameplay()
        }
    }

    private func startTimerIfNeeded() {
        guard timerTask == nil else { return }

        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))

                await MainActor.run {
                    guard let self, !self.hasFinished, self.phase == .playing else { return }

                    self.elapsedSeconds += 1

                    guard self.configuration.usesTimer else { return }

                    if self.timeRemaining > 0 {
                        self.timeRemaining -= 1
                        self.handleFinalFiveSecondsIfNeeded()
                    }

                    if self.timeRemaining <= 0 {
                        self.showTimeUpThenFinish()
                    }
                }
            }
        }
    }

    private func handleFinalFiveSecondsIfNeeded() {
        guard !configuration.hidesTimer, (1...5).contains(timeRemaining) else { return }

        if settings.soundsEnabled {
            soundService.play(.endCountdown, enabled: true)
        }

        if settings.hapticsEnabled {
            let urgency = 0.35 + (Double(6 - timeRemaining) * 0.12)
            hapticsManager.playCountdownTick(urgency: urgency)
        }
    }

    private func startMotionForGameplay() {
        guard settings.motionControlsEnabled, !hasFinished, phase == .playing else { return }

        if motionManager == nil {
            motionManager = MotionManager(sensitivity: settings.tiltSensitivity)
        }

        guard let motionManager, motionManager.isAvailable else {
            isTiltAvailable = false
            tiltStatusText = "Swipe controls are ready"
            return
        }

        isTiltAvailable = true
        tiltStatusText = "Tilt or swipe to score"
        motionManager.start { [weak self] action in
            self?.handleTiltAction(action)
        }
    }

    private func handleTiltAction(_ action: TiltAction) {
        guard !hasFinished, phase == .playing else { return }

        switch action {
        case .correct:
            mark(.correct)
        case .pass:
            mark(.passed)
        case .neutral:
            feedback = nil
        }
    }

    private func playFeedback(for status: WordStatus) {
        if settings.soundsEnabled {
            soundService.play(status == .correct ? .correct : .pass, enabled: true)
        }

        if settings.hapticsEnabled {
            hapticsManager.play(status)
        }
    }

    private func syncFromEngine() {
        currentWordText = engine.currentWord?.text ?? "All done"
        currentChallenge = engine.currentChallenge
        score = engine.session.score
        passedCount = engine.session.passedWords.count
    }

    private func showTimeUpThenFinish() {
        guard !hasFinished, phase != .timeUp else { return }

        phase = .timeUp
        timerTask?.cancel()
        timerTask = nil
        motionManager?.stop()

        if settings.soundsEnabled {
            soundService.play(.timeout, enabled: true)
        }

        if settings.hapticsEnabled {
            hapticsManager.playTimeUp()
        }

        timeUpTask?.cancel()
        timeUpTask = Task { @MainActor [weak self] in
            try? await Task.sleep(for: .milliseconds(1450))
            self?.finishRound(wasTimeUp: true)
        }
    }

    private func finishRound(wasTimeUp: Bool) {
        finishRound(with: engine.finishRound(timeUsed: elapsedSeconds, wasTimeUp: wasTimeUp), wasTimeUp: wasTimeUp)
    }

    private func finishRound(with result: RoundResult, wasTimeUp: Bool) {
        guard !hasFinished else { return }

        hasFinished = true
        phase = .finished
        isPaused = false
        feedback = nil
        timerTask?.cancel()
        timerTask = nil
        countdownTask?.cancel()
        countdownTask = nil
        timeUpTask?.cancel()
        timeUpTask = nil
        finishPresentationTask?.cancel()
        finishPresentationTask = nil
        motionManager?.stop()

        var finalResult = result
        finalResult.timeUsed = elapsedSeconds
        finalResult.wasTimeUp = wasTimeUp

        if !configuration.isTemporaryDeck {
            let seenWords = finalResult.attempts.map(\.word)
            cardRotationStore.recordSeenCards(seenWords, for: configuration.deck)
        }

        if settings.soundsEnabled, !wasTimeUp {
            soundService.play(.timeout, enabled: true)
        }

        if settings.hapticsEnabled, !wasTimeUp {
            hapticsManager.playRoundFinished()
        }

        finishPresentationTask = Task { @MainActor [weak self] in
            try? await Task.sleep(for: .milliseconds(850))
            guard let self, !Task.isCancelled else { return }
            self.onFinish(finalResult)
        }
    }
}
