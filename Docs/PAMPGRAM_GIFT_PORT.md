# PampGram gift-flow port

NightGram's local gift engine now follows the data model and state separation used by
PampGram's `PhantomGiftKit`, adapted to the standalone Swift Package in this repository.

## Reference implementation

The implementation was reviewed in the user's PampGram repository:

- `mod/components/PhantomGiftKit/Sources/PampGramPhantomGift.swift`
- `mod/components/PhantomGiftKit/Sources/PampGramPhantomGiftStore.swift`
- `mod/components/PhantomGiftKit/Sources/PampGramPhantomGiftManager.swift`
- `mod/components/PhantomGiftKit/Sources/PampGramFakeTransactions.swift`
- `mod/components/PampGramSettingsUI/Sources/PampGramGiftMarketScreen.swift`

NightGram cannot compile those files verbatim because they depend on TelegramCore,
Postbox, AccountContext and SwiftSignalKit. The concepts have therefore been ported
into the existing NightGram types and SQLite/UserDefaults storage.

## Ported local-only behavior

- Gift records carry owner, acquisition price/currency, received flag, pin/hide state,
  worn state, sold timestamp and optional local market listing.
- The local ledger has separate demo balances for Stars, TON and rubles, plus an
  append-only operation history.
- Demo purchase debits only the NightGram ledger.
- Demo receive adds a local record and a clearly labelled demo credit.
- Pin, hide, wear, list, unlist, sell and local-profile transfer update only NightGram data.
- Sold gifts remain stored for history but are excluded from the active profile grid.

## Deliberate safety and integration boundary

These are local preview features, not Telegram account features. NightGram does not
create fake Telegram payments, modify Telegram's real Stars/TON balances, inject false
rows into Telegram's transaction history, send a gift card to another user, or claim
that a real person sent a gift. The UI labels the collection as `LOCAL DEMO`.

The current package is still a domain/UI module, not yet a fully integrated Telegram-iOS
application target. Connecting the module to Telegram's own profile and gift screens
requires the Telegram-iOS source checkout, compatible build configuration and an
explicit integration patch. No IPA or device build is claimed by this commit.
