# Charades: Tilt & Guess

A native iPhone charades-style party game built with Swift and SwiftUI.

Players choose a deck, start a timed round, hold the phone up, and guess the word shown on screen. The gameplay uses iPhone motion sensors so tilting down marks a word correct and tilting up passes it. You can also swipe the screen to mark correct or pass.

## Current Features

- **Tilt & Swipe Controls**: Use CoreMotion to tilt the device, or swipe on screen, to mark guesses.
- **Built-in Decks**: Play immediately with a variety of bundled word decks.
- **Custom Decks**: Create and store your own custom decks locally. Enter cards manually or paste a newline-separated list.
- **Picture Mode**: Visual, image-based cards for quick guessing and accessibility.
- **Tip Jar**: Optional "Buy Me a Coffee" tips supported via StoreKit in-app purchases.
- **Privacy First**: No ads, no tracking, no account, and no mandatory subscriptions. Everything works entirely offline.

## Tech Stack

- Swift
- SwiftUI
- CoreMotion (tilt detection)
- StoreKit (optional tip jar)

## Project Structure

```text
CharadesTiltGuess/
  App/
  Models/
  Views/
  Services/

CharadesTiltGuessTests/
CharadesTiltGuessUITests/
docs/
```

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

## Repository

GitHub remote:

```text
https://github.com/syedhy/Charades-Tilt-Guess.git
```
