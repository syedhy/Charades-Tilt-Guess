# Charades Production Upgrade Plan

## Current Architecture Snapshot

- `AppRouter` owns `NavigationStack` routes and presents `GameView` as a full-screen landscape overlay through `ActiveGame`.
- Models are lightweight value types: `Deck`, `GameWord`, `GameSession`, `RoundResult`, `GameSettings`, `WordStatus`, `TiltSensitivity`.
- Persistence is local and JSON-based: `DefaultDeckLoader` reads bundled decks, `CustomDeckStore` saves user decks, `SettingsStore` persists settings in `UserDefaults`.
- `GameEngine` is platform-agnostic and owns scoring/advancing one shuffled queue, but it currently assumes one timed normal round.
- `MotionManager` converts Core Motion gravity into `TiltAction` through `TiltGestureDetector`; it starts only during gameplay and is simulator-safe.
- `HapticsManager` is simple UIKit impact/notification feedback.
- Existing UI language is cream doodle paper, black ink strokes, bold rounded typography, hard offset shadows, playful rotations, and saturated accent colors.
- Tests cover stores, settings, import parsing, game engine, motion detector, router, and UI smoke flows. Baseline before this upgrade has two existing `TiltGestureDetectorTests` failures around the opposite-action cooldown.

## Design Direction

Visual thesis: preserve the playful doodle-paper party-game identity, but make every screen feel intentionally composed through shared spacing, cards, buttons, stats, overlays, and motion timing.

Content plan: the app opens on game modes, moves into mode-specific deck/setup screens with help, uses a focused preparation/countdown flow before gameplay, and ends with dense fixed-height results that can be scanned without page-length scrolling.

Interaction plan: add first-launch onboarding with illustrated motion cards, preparation neutral-detection feedback before countdown, stronger per-action haptics/sounds, final-five-second urgency, and a short animated Time Up state before results.

## Architecture Decisions

- Introduce `GameMode` and `GameConfiguration` so mode rules live in one explicit model instead of branching by screen.
- Keep one `GameEngine`, but extend it with mode rules, elapsed-time tracking, attempts, streaks, optional timers, hidden timers, and challenge prompts.
- Add `CardRotationStore`/`CardRotationService` to persist seen card IDs by deck ID and build queues with unseen cards first.
- Add `SoundService` with no-op-safe placeholder lookup for `correct.wav`, `pass.wav`, `countdown.wav`, and `timeout.wav`.
- Add `WikipediaService` as an async service that loads random article titles via the public MediaWiki API and returns temporary playable decks.
- Keep custom deck editing local; do not save Paste & Play or Wikipedia decks.
- Normalize settings so users cannot end up with no controls: if motion controls are off, swipe controls are always available.
- Keep source files focused by adding feature files for modes, onboarding, deck selection, paste setup, instructions, reusable result/stat components, and services.

## Implementation Tracker

- [x] Analyze current architecture, navigation, models, services, view models, UI, assets, and tests.
- [x] Establish branch and baseline verification state.
- [x] Add mode/config/result models and settings upgrades.
- [x] Add card rotation, sound, Wikipedia, and improved paste parsing services.
- [x] Refactor router and view models around explicit game configurations.
- [x] Redesign home as Game Modes with prominent Add Deck, Random Deck, and Paste & Play actions.
- [x] Add mode deck selection and polished mode instructions sheets.
- [x] Add onboarding and settings revisit action.
- [x] Add preparation, neutral detection/fallback, countdown, final-five urgency, Time Up, swipe controls, and redesigned pause UI.
- [x] Redesign results with fixed internal scrolling sections and richer statistics.
- [x] Expand built-in decks and separate custom/built-in ordering.
- [x] Add/update unit and UI tests.
- [x] Run final build/tests and polish/cleanup pass.

## Implementation Notes

- Baseline test command: `xcodebuild -project CharadesTiltGuess.xcodeproj -scheme CharadesTiltGuess -destination 'platform=iOS Simulator,name=iPhone 17' test`.
- Baseline result before edits: app builds, but `TiltGestureDetectorTests.testDetectorStaysOnCorrectUntilPhoneReturnsToNeutral` and `testDetectorStaysOnPassUntilPhoneReturnsToNeutral` fail because opposite-action cooldown blocks immediate opposite triggers.
- Wikipedia API shape verified with `https://en.wikipedia.org/w/api.php?action=query&generator=random&grnnamespace=0&grnlimit=5&prop=info&format=json&origin=*`; titles arrive under `query.pages`.
- The Xcode project uses explicit PBX groups/build phases, so new Swift files and tests must be added to `project.pbxproj`.
- Final verification: `xcodebuild -project CharadesTiltGuess.xcodeproj -scheme CharadesTiltGuess -destination 'platform=iOS Simulator,name=iPhone 17' test` passed with 51 unit tests and 4 UI tests.
- Visual polish screenshot captured at `/tmp/charades-home-final.png`.
- Final cleanup pass fixed Infinite Mode elapsed-time tracking, crisped action-button shadows, and corrected Paste & Play blank-line feedback.

## Future Improvements

- Real sound assets and a volume/mute polish pass.
- Real illustrated bitmap assets for onboarding and App Store screenshots.
- Optional deck search and duplicate-as-custom for built-in decks.
- Player names for Hot Potato loser tracking.
- More robust Wikipedia category packs beyond random article titles.
