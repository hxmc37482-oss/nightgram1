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
        try await store.append(GiftEvent(giftID: gift.id, kind: .created, toProfileID: ownerProfileID))
        return gift
    }

    /// PampGram-style local purchase. It charges only NightGram's demo ledger and
    /// never calls Telegram's payment or gift APIs.
    @discardableResult
    public func buyDemoGift(
        title: String,
        assetName: String,
        rarity: GiftRarity = .common,
        visualValue: Int = 0,
        ownerProfileID: String,
        price: LocalGiftPrice,
        ledger: LocalGiftLedger
    ) async throws -> LocalGift {
        guard price.amount > 0 else { throw LocalGiftLedgerError.invalidAmount }
        guard await ledger.balance(for: price.currency) >= price.amount else {
            throw LocalGiftLedgerError.insufficientBalance
        }

        let gift = LocalGift(
            title: title,
            assetName: assetName,
            rarity: rarity,
            visualValue: visualValue,
            ownerProfileID: ownerProfileID,
            purchasePrice: price
        )
        try await store.save(gift)
        do {
            try await ledger.debit(price, title: "Демо-покупка подарка", details: title)
            try await store.append(GiftEvent(giftID: gift.id, kind: .purchased, toProfileID: ownerProfileID))
        } catch {
            try? await store.delete(id: gift.id)
            throw error
        }
        return gift
    }

    /// Local "Подарок мне" flow. This creates a demo record and credits the demo
    /// ledger; it does not claim that another Telegram user actually sent anything.
    @discardableResult
    public func receiveDemoGift(
        title: String,
        assetName: String,
        rarity: GiftRarity = .common,
        visualValue: Int = 0,
        ownerProfileID: String,
        displayedValue: LocalGiftPrice,
        ledger: LocalGiftLedger
    ) async throws -> LocalGift {
        guard displayedValue.amount > 0 else { throw LocalGiftLedgerError.invalidAmount }
        let gift = LocalGift(
            title: title,
            assetName: assetName,
            rarity: rarity,
            visualValue: visualValue,
            ownerProfileID: ownerProfileID,
            purchasePrice: displayedValue,
            isReceived: true
        )
        try await store.save(gift)
        do {
            try await ledger.credit(
                displayedValue,
                kind: .receivedDemoGift,
                title: "Демо-подарок",
                details: title
            )
            try await store.append(GiftEvent(giftID: gift.id, kind: .received, toProfileID: ownerProfileID))
        } catch {
            try? await store.delete(id: gift.id)
            throw error
        }
        return gift
    }

    public func collection(for profileID: String, includeHidden: Bool = false) async throws -> [LocalGift] {
        try await store.gifts(ownerProfileID: profileID, includeHidden: includeHidden)
    }

    public func marketListings() async throws -> [LocalGift] {
        try await store.marketGifts()
    }

    /// Changes ownership only between local NightGram profile records on this device.
    /// It does not send a Telegram message or transfer a collectible to another account.
    public func transferLocally(giftID: UUID, to profileID: String) async throws {
        guard var gift = try await store.gift(id: giftID), gift.soldAt == nil else {
            throw GiftStoreError.giftNotFound
        }
        let previousOwner = gift.ownerProfileID
        gift.ownerProfileID = profileID
        gift.isPinned = false
        gift.isWorn = false
        gift.marketPrice = nil
        gift.marketListedAt = nil
        try await store.save(gift)
        try await store.append(GiftEvent(
            giftID: giftID,
            kind: .transferred,
            fromProfileID: previousOwner,
            toProfileID: profileID
        ))
    }

    public func setPinned(_ pinned: Bool, giftID: UUID) async throws {
        guard var gift = try await store.gift(id: giftID), gift.soldAt == nil else {
            throw GiftStoreError.giftNotFound
        }
        gift.isPinned = pinned
        try await store.save(gift)
        try await store.append(GiftEvent(
            giftID: giftID,
            kind: pinned ? .pinned : .unpinned,
            toProfileID: gift.ownerProfileID
        ))
    }

    public func setHidden(_ hidden: Bool, giftID: UUID) async throws {
        guard var gift = try await store.gift(id: giftID), gift.soldAt == nil else {
            throw GiftStoreError.giftNotFound
        }
        gift.isHidden = hidden
        try await store.save(gift)
        try await store.append(GiftEvent(
            giftID: giftID,
            kind: hidden ? .hidden : .unhidden,
            toProfileID: gift.ownerProfileID
        ))
    }

    public func setWorn(_ worn: Bool, giftID: UUID) async throws {
        guard var gift = try await store.gift(id: giftID), gift.soldAt == nil else {
            throw GiftStoreError.giftNotFound
        }
        if worn {
            let collection = try await store.gifts(ownerProfileID: gift.ownerProfileID, includeHidden: true)
            for var current in collection where current.isWorn && current.id != giftID {
                current.isWorn = false
                try await store.save(current)
                try await store.append(GiftEvent(giftID: current.id, kind: .unworn, toProfileID: current.ownerProfileID))
            }
        }
        gift.isWorn = worn
        try await store.save(gift)
        try await store.append(GiftEvent(
            giftID: giftID,
            kind: worn ? .worn : .unworn,
            toProfileID: gift.ownerProfileID
        ))
    }

    public func setMarketListing(_ price: LocalGiftPrice?, giftID: UUID) async throws {
        guard var gift = try await store.gift(id: giftID), gift.soldAt == nil else {
            throw GiftStoreError.giftNotFound
        }
        if let price, price.amount <= 0 { throw LocalGiftLedgerError.invalidAmount }
        gift.marketPrice = price
        gift.marketListedAt = price == nil ? nil : .now
        try await store.save(gift)
        try await store.append(GiftEvent(
            giftID: giftID,
            kind: price == nil ? .unlisted : .listed,
            toProfileID: gift.ownerProfileID
        ))
    }

    /// Local demo sale: credits the local ledger and archives the gift record.
    /// No real marketplace listing or Telegram transaction is created.
    public func sellDemoGift(giftID: UUID, ledger: LocalGiftLedger) async throws {
        guard var gift = try await store.gift(id: giftID), gift.soldAt == nil else {
            throw GiftStoreError.giftNotFound
        }
        guard let salePrice = gift.marketPrice ?? gift.purchasePrice else {
            throw LocalGiftLedgerError.invalidAmount
        }
        try await ledger.credit(
            salePrice,
            kind: .sale,
            title: "Демо-продажа подарка",
            details: gift.title
        )
        gift.soldAt = .now
        gift.isHidden = true
        gift.isPinned = false
        gift.isWorn = false
        gift.marketPrice = nil
        gift.marketListedAt = nil
        try await store.save(gift)
        try await store.append(GiftEvent(giftID: giftID, kind: .sold, toProfileID: gift.ownerProfileID))
    }

    public func history(for giftID: UUID) async throws -> [GiftEvent] {
        try await store.history(giftID: giftID)
    }
}
