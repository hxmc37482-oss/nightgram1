# NightGram

NightGram is an unofficial Telegram-iOS-derived client concept. The repository currently contains an isolated local-gifts foundation and a SwiftUI collection preview.

## Modules

- **NightGramGiftEngine** — local gift models, SQLite persistence, collection manager, event history and starter catalogue.
- **LocalWallet** — simulated local points balance and ledger. It is not a Telegram Stars wallet.
- **NightGramGiftUI** — SwiftUI gift-grid preview with a visible local/demo label.

## Current features

- Create local demo gifts from a starter catalogue.
- Store gift records and event history in SQLite.
- List a profile's collection.
- Transfer a gift between local profile IDs.
- Pin and hide local gifts.
- Keep a bounded history of simulated points adjustments.
- Render a SwiftUI collection grid.

## Important: local-only gifts

All gifts and wallet values in this project are client-side demo data. A transfer changes only this local database. It does not send a Telegram gift, change a Telegram account balance, or create an on-chain asset. Keep the local/demo disclosure visible in the interface so these items cannot be mistaken for real Telegram transactions.

## Build

Requires macOS, Xcode with Swift 5.9+, and SQLite headers.

```bash
swift test
```

Windows can be used to edit the source. Building, signing and producing an iOS app requires macOS with Xcode. The package has not yet been built or tested in an Xcode environment.

## Repository layout

```
Sources/
  CSQLite/
  NightGramGiftEngine/
  NightGramGiftUI/
Tests/
  NightGramGiftEngineTests/
Docs/
```

## Next steps

See [Docs/ROADMAP.md](Docs/ROADMAP.md). The next major task is integrating these modules into a pinned upstream Telegram-iOS checkout and adding the profile entry point. That work requires reviewing the upstream license and build system first.

NightGram is unofficial. Use original iconography and clearly identify it as an unofficial client.
