# Contributing to NightGram

Thanks for helping with NightGram.

## Development rules

- Keep local/demo data separate from Telegram server data.
- Never describe simulated points as Telegram Stars or local gifts as real Telegram collectibles.
- Keep the local/demo disclosure visible in user-facing screens.
- Do not add payment, wallet, or network code without documenting its trust and security model.
- Prefer small changes with tests.

## Before opening a pull request

1. Run `swift test` on macOS with Xcode.
2. Add tests for new storage and state-management behavior.
3. Update the README or roadmap when behavior changes.
4. Do not include signing certificates, API secrets, session files, or personal data.

## Upstream integration

Changes derived from Telegram-iOS must preserve applicable upstream notices and comply with the upstream license. Keep upstream code changes isolated and document the source commit.
