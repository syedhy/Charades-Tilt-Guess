import XCTest
@testable import CharadesTiltGuess

final class GameEngineTests: XCTestCase {
    func testStartsOnFirstShuffledWord() {
        let deck = makeDeck()
        let shuffledWords = [deck.cards[1], deck.cards[0]]
        let engine = GameEngine(deck: deck, duration: 60, shuffledWords: shuffledWords)

        XCTAssertEqual(engine.currentWord, shuffledWords[0])
    }

    func testMarksCorrectAndAdvancesWithoutRepeating() {
        let deck = makeDeck()
        var engine = GameEngine(deck: deck, duration: 60, shuffledWords: deck.cards)

        let result = engine.markCurrentWord(.correct)

        XCTAssertNil(result)
        XCTAssertEqual(engine.session.correctWords, [deck.cards[0]])
        XCTAssertEqual(engine.currentWord, deck.cards[1])
        XCTAssertEqual(engine.session.totalAttempted, 1)
    }

    func testMarksPassAndFinishesWhenDeckRunsOut() {
        let deck = makeDeck(cards: [GameWord(id: "one", text: "Only Word")])
        var engine = GameEngine(deck: deck, duration: 30, shuffledWords: deck.cards)

        let result = engine.markCurrentWord(.passed)

        XCTAssertEqual(result?.passedWords, deck.cards)
        XCTAssertEqual(result?.correctWords, [])
        XCTAssertEqual(result?.totalAttempted, 1)
        XCTAssertEqual(result?.finalScore, 0)
    }

    func testFinishRoundUsesCurrentSessionSnapshot() {
        let deck = makeDeck()
        var engine = GameEngine(deck: deck, duration: 90, shuffledWords: deck.cards)

        _ = engine.markCurrentWord(.correct)
        let result = engine.finishRound()

        XCTAssertEqual(result.deck, deck)
        XCTAssertEqual(result.duration, 90)
        XCTAssertEqual(result.correctWords, [deck.cards[0]])
        XCTAssertEqual(result.passedWords, [])
    }

    func testTracksAttemptsForResultStatistics() {
        let deck = makeDeck()
        var engine = GameEngine(deck: deck, duration: 60, shuffledWords: deck.cards)

        _ = engine.markCurrentWord(.correct)
        _ = engine.markCurrentWord(.passed)

        let result = engine.finishRound(timeUsed: 12)
        XCTAssertEqual(result.attempts.map(\.status), [.correct, .passed])
        XCTAssertEqual(result.accuracyPercentage, 50)
        XCTAssertEqual(result.cardsSeen, 2)
        XCTAssertEqual(result.timeUsed, 12)
    }

    func testChallengeModeAssignsReusableChallengeCards() {
        let deck = makeDeck(cards: [
            GameWord(id: "one", text: "One"),
            GameWord(id: "two", text: "Two"),
            GameWord(id: "three", text: "Three"),
            GameWord(id: "four", text: "Four")
        ])
        var engine = GameEngine(
            configuration: .challengeCards(deck: deck, duration: 60),
            orderedWords: deck.cards,
            challengeProvider: ChallengeCardProvider(challengeEvery: 2, challenges: [.silentAct])
        )

        _ = engine.markCurrentWord(.correct)
        _ = engine.markCurrentWord(.correct)

        XCTAssertNil(engine.session.attempts[0].challenge)
        XCTAssertEqual(engine.session.attempts[1].challenge, .silentAct)
    }

    func testInfiniteModeRefillsWhenDeckIsExhausted() {
        let deck = makeDeck(cards: [GameWord(id: "one", text: "Only Word")])
        var engine = GameEngine(configuration: .infinite(deck: deck), orderedWords: deck.cards)

        let result = engine.markCurrentWord(.correct)

        XCTAssertNil(result)
        XCTAssertEqual(engine.currentWord, deck.cards[0])
        XCTAssertEqual(engine.session.correctWords, deck.cards)
    }

    private func makeDeck(cards: [GameWord]? = nil) -> Deck {
        Deck(
            id: "test-deck",
            name: "Test Deck",
            cards: cards ?? [
                GameWord(id: "one", text: "Phone"),
                GameWord(id: "two", text: "Laptop")
            ],
            type: .default,
            color: .mint,
            symbolName: "star"
        )
    }
}
