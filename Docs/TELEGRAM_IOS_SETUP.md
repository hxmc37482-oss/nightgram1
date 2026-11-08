# Upstream Telegram-iOS setup

The upstream Telegram-iOS repository documents a Bazel-backed build workflow.

1. Install the Xcode version required by upstream `versions.json`.
2. Clone the upstream repository with submodules:

   `git clone --recursive -j8 https://github.com/TelegramMessenger/Telegram-iOS.git`

3. Obtain a dedicated Telegram API ID.
4. Create a unique app identifier and configure signing.
5. Review the upstream README and licence/attribution requirements before redistributing a fork.
6. Generate the Xcode project using upstream `build-system/Make/Make.py`.

Do not copy Telegram's official logo. Clearly label NightGram as an unofficial client.
