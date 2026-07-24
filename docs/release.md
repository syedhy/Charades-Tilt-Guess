# App Store Release Checklist

## 1. App Store Connect Metadata
- [ ] **Name**: Charades Tilt Guess
- [ ] **Subtitle**: Tilt-to-guess party game
- [ ] **Description**: Play the classic game of charades with a modern twist! Tilt your phone up or down to guess the words. Features custom decks and Picture Mode.
- [ ] **Keywords**: charades, party game, tilt, guess, word game, picture mode
- [ ] **Age Rating**: Set appropriately (no mature content). Answer NO to gambling, violence, etc.
- [ ] **Data Privacy Label**: Select **"Data Not Collected"**.

## 2. In-App Purchases (StoreKit)
- [ ] Ensure the three Tip products are created in App Store Connect:
  - `tip.small` (Consumable)
  - `tip.medium` (Consumable)
  - `tip.large` (Consumable)
- [ ] Upload a review screenshot for each IAP product in App Store Connect.

## 3. Privacy Policy
- [ ] Host the contents of `docs/privacy.md` on a website (e.g., GitHub Pages, Notion, or personal site).
- [ ] Link the hosted Privacy Policy URL in App Store Connect.

## 4. Pre-Launch Testing Checklist
- [ ] **Physical iPhone Testing**: Verify tilt controls work accurately on a physical device.
- [ ] **StoreKit Sandbox Testing**: Verify the Tip Jar works by using a Sandbox Apple ID on a physical device. TestFlight / sandbox IAP testing should be used before launch. Testers are not charged real money in the sandbox.
- [ ] **App Icon Verification**: Verify `AppIcon.appiconset` contains NO alpha channels/transparency (will cause rejection).
- [ ] **PrivacyInfo.xcprivacy**: Verify the Privacy Manifest is correctly included in the App Target.

## 5. TestFlight & App Review
- [ ] **TestFlight**: Distribute to internal testers via TestFlight and confirm clean install behavior.
- [ ] **Kids Category**: Do NOT select the "Made for Kids" category in App Store Connect unless intentionally complying with COPPA/GDPR-K restrictions. The app uses standard categorisation (e.g. Games > Word / Party).
- [ ] Provide instructions in the App Review notes explaining how to test the tilt mechanics (since simulators don't support tilt).
