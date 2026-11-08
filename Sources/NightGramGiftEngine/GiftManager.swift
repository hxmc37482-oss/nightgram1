import Foundation

public actor GiftManager {
    private let store: GiftStore

    public init(store: GiftStore) {
        self.store = store
    }

    @discardableResult
    public func createGift(
        title: String,
        assetName: String,
        rarity: GiftRarity = .common,
        visualValue: Int = 0,
        ownerProfileID: String
    ) async throws -> LocalGift {
        let gift = LocalGift(
            title: title,
            assetName: assetName,
            rarity: rarity,
            visualValue: visualValue,
            ownerProfileID: ownerProfileID
        )
        try await store.save(gift)
        try await store.append(
            GiftEvent(giftID: gift.id, kind: .created, toProfileID: ownerProfileID)
        )
        return gift
    }

    public func collection(for profileID: String, includeHidden: Bool = false) async throws -> [LocalGift] {
        try await store.gifts(ownerProfileID: profileID, includeHidden: includeHidden)
    }

    public func transfer(giftID: UUID, to profileID: String) async throws {
        guard var gift = try await store.gift(id: giftID) else {
            throw GiftStoreError.giftNotFound
        }
        let previousOwner = gift.ownerProfileID
        gift.ownerProfileID = profileID
        gift.isPinned = false
        try await store.save(gift)
        try await store.append(
            GiftEvent(
                giftID: giftID,
                kind: .transferred,
                fromProfileID: previousOwner,
                toProfileID: profileID
            )
        )
    }

    public func setPinned(_ pinned: Bool, giftID: UUID) async throws {
        guard var gift = try await store.gift(id: giftID) else {
            throw GiftStoreError.giftNotFound
        }
        gift.isPinned = pinned
        try await store.save(gift)
        try await store.append(
            GiftEvent(giftID: giftID, kind: pinned ? .pinned : .unpinned, toProfileID: gift.ownerProfileID)
        )
    }

    public func setHidden(_ hidden: Bool, giftID: UUID) async throws {
        guard var gift = try await store.gift(id: giftID) else {
            throw GiftStoreError.giftNotFound
        }
        gift.isHidden = hidden
        try await store.save(gift)
        try await store.append(
            GiftEvent(giftID: giftID, kind: hidden ? .hidden : .unhidden, toProfileID: gift.ownerProfileID)
        )
    }

    public func history(for giftID: UUID) async throws -> [GiftEvent] {
        try await store.history(giftID: giftID)
    }
}
