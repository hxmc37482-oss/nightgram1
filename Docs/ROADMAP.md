# NightGram roadmap

## Phase 1 — local feature foundation

- [x] Local gift model and SQLite store
- [x] Gift lifecycle manager and event history
- [x] Starter catalogue
- [x] Simulated local points ledger
- [x] SwiftUI collection preview with a persistent local/demo label

## Phase 2 — client integration

- [ ] Import upstream Telegram-iOS source and record the exact upstream commit
- [ ] Add a dedicated Bazel target for the NightGram modules
- [ ] Add profile-screen entry point and load the local collection
- [ ] Add gift detail, create, pin, hide and transfer screens
- [ ] Add app icon, original assets and accessibility labels

## Phase 3 — quality and release

- [ ] Run `swift test` on macOS/Xcode
- [ ] Add persistence, migration and UI tests
- [ ] Add macOS CI and code signing instructions
- [ ] Review Telegram API terms, upstream license and trademark requirements
- [ ] Produce a signed development build on macOS

## Platform note

The source can be edited on Windows. Building, signing and distributing an iOS app requires macOS with Xcode. The current repository is a feature foundation, not an installable iOS app.