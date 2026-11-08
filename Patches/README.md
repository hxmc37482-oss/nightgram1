# Applying the NightGram profile gifts patch

Patch file: [nightgram-profile-gifts.patch](nightgram-profile-gifts.patch)

Target repository: `hxmc37482-oss/Nightgram`, branch `master`, base commit
`da12a534a2fc561f1be6dc6753ee64d62f5f5cbf`.

The patch is stored in this separate repository; it does **not** modify the large
Telegram-iOS source repository.

From the root of a checkout at the target base commit:

```sh
git apply --check nightgram-profile-gifts.patch
git apply nightgram-profile-gifts.patch
```

It adds a local Postbox-backed gift collection and a profile entry that opens it
through the existing NightGram panel route. The demo Stars balance, gift records,
pin/hide/sell actions and operation ledger stay in a NightGram-reserved preference
key. No gift messages are inserted into chats, nothing is sent to other users,
and Telegram's real Stars, gifts and transaction history are not modified.

The patch has not been built with Xcode yet. Validate it with `git apply --check`
and the repository's normal iOS build before using it in an app.
