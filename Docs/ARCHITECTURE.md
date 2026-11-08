# NightGram architecture

## Product layers

- **Telegram upstream:** authentication, chats, messages, media, calls, networking.
- **NightGram presentation:** profile additions, settings, gift grid, local wallet screens.
- **GiftEngine:** local gift lifecycle and collection rules.
- **Local persistence:** SQLite database owned by NightGram features.

## Gift lifecycle

`createGift -> save -> append(created event)`

`transfer -> change local owner -> append(transferred event)`

`pin/hide -> update local flags -> append event`

## Data ownership

The local gift engine must never write to Telegram's server-side balance or gift APIs. The owner profile identifier is a local profile key, not proof of Telegram ownership. The initial module intentionally has no network layer.

## Suggested next modules

- `NightGramWallet`: clearly labelled simulated balances and ledger.
- `NightGramProfileUI`: gift grid embedded into the existing profile controller.
- `NightGramSettings`: local feature toggles and appearance preferences.
- `NightGramAssets`: original artwork and rarity frames.
