# NightGram

NightGram is an unofficial Telegram-iOS-derived client concept. This repository currently contains the first isolated feature module: a local-only gift engine.

## Current status

- Swift Package targeting iOS 16+
- SQLite-backed local gift storage
- Local gift collection, visual transfers, pin/hide actions
- Per-gift operation history
- No Telegram payment, Stars, TON, or collectible API calls

## Important: local-only gifts

`LocalGift` and `visualValue` are client-side presentation data. A transfer changes only this local database. It does not send a Telegram gift, change a Telegram account balance, or create an on-chain asset. The interface must label these items as local/demo content so they cannot be mistaken for real Telegram transactions.

## Build

Requires macOS, Xcode with Swift 5.9+, and SQLite headers.

```bash
swift test
```

To integrate into a Telegram-iOS fork, add this package as a local package or port its sources into a dedicated Bazel target. Keep the feature isolated from TelegramCore and Postbox initially.

## Next steps

1. Review Telegram-iOS licensing and attribution requirements before redistributing a derivative.
2. Obtain a dedicated Telegram API ID and configure a unique bundle identifier and signing team.
3. Add NightGram UI entry points in the profile screen.
4. Connect the profile's local gift grid to `GiftManager.collection(for:)`.
5. Add original artwork, UI tests, and macOS/Xcode CI.

NightGram is unofficial. Use its own name and original iconography, and clearly identify it as an unofficial client.