# Charades: Tilt & Guess

A native iPhone charades-style party game built with Swift and SwiftUI.

Players choose a deck, start a timed round, hold the phone up, and guess the word shown on screen. The planned gameplay uses iPhone motion sensors so tilting down marks a word correct and tilting up passes it.

## Current Status

Core MVP systems are now in place:

- SwiftUI iPhone app shell, navigation, and playful doodle visual direction
- Bundled premade decks plus locally stored custom decks
- Custom deck creation, editing, manual cards, and newline paste import
- Game setup, timed button-driven rounds, pause, scoring, and results
- Settings for default duration, haptics, and tilt sensitivity
- Core Motion tilt controls with simulator-safe button fallback
- Unit and UI test coverage for the main flows

Broad UI polish and final visual refinement are intentionally deferred until the functional app is complete. That end-of-build work is tracked in GitHub issue #2.

## Product Direction

The app will focus on:

- Premade word decks
- Custom decks stored locally on device
- Manual card creation
- Clipboard import for newline-separated word lists
- Timed rounds
- Tilt-based correct/pass controls
- Score and results summary
- Playful, bold, readable party-game UI

The MVP intentionally avoids:

- Multiplayer
- Accounts or login
- Backend services
- Cloud sync
- Ads
- In-app purchases

## Tech Stack

- Swift
- SwiftUI
- CoreMotion, planned for tilt detection
- UIKit haptics, planned for feedback
- Local JSON storage, planned for custom decks

## Project Structure

```text
CharadesTiltGuess/
  App/
  Models/
  Views/
    Home/

CharadesTiltGuessTests/
CharadesTiltGuessUITests/
docs/
  plans/
```

This structure will expand phase by phase into views, view models, services, data stores, motion handling, haptics, and game state.

## Open In Xcode

Open:

```text
CharadesTiltGuess.xcodeproj
```

Then choose the `CharadesTiltGuess` scheme and run on an iPhone simulator or a connected iPhone.

## Run Tests

From the project folder:

```sh
xcodebuild -project CharadesTiltGuess.xcodeproj -scheme CharadesTiltGuess -destination 'platform=iOS Simulator,name=iPhone 17' test
```

## First Real iPhone Run

1. Plug your iPhone into your Mac.
2. Unlock the iPhone and tap `Trust This Computer` if prompted.
3. Open `CharadesTiltGuess.xcodeproj` in Xcode.
4. Select the `CharadesTiltGuess` project, then the app target.
5. Open `Signing & Capabilities`.
6. Choose your Apple ID team or Personal Team.
7. Select your iPhone from the run destination list.
8. Press Run.
9. If iPhone blocks launch, open iPhone Settings and trust the developer profile.

Simulator testing is useful for UI and navigation. Tilt detection must be tested on a real iPhone because the simulator cannot fully validate physical motion behavior.

## Roadmap

The detailed build plan is in:

```text
docs/plans/2026-06-03-001-feat-charades-tilt-guess-plan.md
```

Next planned phases:

1. App skeleton and navigation
2. Visual system and reusable components
3. Premade deck data and deck grid
4. Custom deck storage
5. Custom deck creation
6. Manual card entry
7. Clipboard paste import
8. Basic game loop with buttons
9. Timer, pause, score, and results
10. CoreMotion tilt detection
11. End-of-build UI polish and visual refinement

## Repository

GitHub remote:

```text
https://github.com/syedhy/Charades-Tilt-Guess.git
```
