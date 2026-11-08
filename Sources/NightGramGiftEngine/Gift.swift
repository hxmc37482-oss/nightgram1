import Foundation

public enum GiftRarity: String, Codable, CaseIterable, Sendable {
    case common, uncommon, rare, epic, legendary
}

/// Currency values used only by NightGram's local demo economy.
/// TON is stored in nanoTON; rubles are stored in kopecks; Stars are whole units.
public enum LocalGiftCurrency: String, Codable, CaseIterable, Sendable {
    case stars, ton, rub
}

public struct LocalGiftPrice: Codable, Equatable, Sendable {
    public let amount: Int64
    public let currency: LocalGiftCurrency

    public init(amount: Int64, currency: LocalGiftCurrency) {
        self.amount = max(0, amount)
        self.currency = currency
    }
}

/// A visual gift stored on this device only. It is not a Telegram StarGift,
/// server transaction, transferable collectible, or proof of payment.
public struct LocalGift: Codable, Identifiable, Equatable, Sendable {
    public let id: UUID
    public var title: String
    public var assetName: String
    public var rarity: GiftRarity
    public var visualValue: Int
    public var ownerProfileID: String
    public let createdAt: Date
    public var purchasePrice: LocalGiftPrice?
    public var isReceived: Bool
    public var isPinned: Bool
    public var isHidden: Bool
    public var soldAt: Date?
    public var isWorn: Bool
    public var marketPrice: LocalGiftPrice?
    public var marketListedAt: Date?

    public init(
        id: UUID = UUID(), title: String, assetName: String,
        rarity: GiftRarity = .common, visualValue: Int = 0,
        ownerProfileID: String, createdAt: Date = .now,
        purchasePrice: LocalGiftPrice? = nil, isReceived: Bool = false,
        isPinned: Bool = false, isHidden: Bool = false, soldAt: Date? = nil,
        isWorn: Bool = false, marketPrice: LocalGiftPrice? = nil,
        marketListedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.assetName = assetName
        self.rarity = rarity
        self.visualValue = max(0, visualValue)
        self.ownerProfileID = ownerProfileID
        self.createdAt = createdAt
        self.purchasePrice = purchasePrice
        self.isReceived = isReceived
        self.isPinned = isPinned
        self.isHidden = isHidden
        self.soldAt = soldAt
        self.isWorn = isWorn
        self.marketPrice = marketPrice
        self.marketListedAt = marketListedAt
    }

    private enum CodingKeys: String, CodingKey {
        case id, title, assetName, rarity, visualValue, ownerProfileID, createdAt
        case purchasePrice, isReceived, isPinned, isHidden, soldAt, isWorn
        case marketPrice, marketListedAt
    }

    /// Backward-compatible decoding for gifts saved before these fields existed.
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(UUID.self, forKey: .id)
        title = try values.decode(String.self, forKey: .title)
        assetName = try values.decode(String.self, forKey: .assetName)
        rarity = try values.decodeIfPresent(GiftRarity.self, forKey: .rarity) ?? .common
        visualValue = try values.decodeIfPresent(Int.self, forKey: .visualValue) ?? 0
        ownerProfileID = try values.decode(String.self, forKey: .ownerProfileID)
        createdAt = try values.decode(Date.self, forKey: .createdAt)
        purchasePrice = try values.decodeIfPresent(LocalGiftPrice.self, forKey: .purchasePrice)
        isReceived = try values.decodeIfPresent(Bool.self, forKey: .isReceived) ?? false
        isPinned = try values.decodeIfPresent(Bool.self, forKey: .isPinned) ?? false
        isHidden = try values.decodeIfPresent(Bool.self, forKey: .isHidden) ?? false
        soldAt = try values.decodeIfPresent(Date.self, forKey: .soldAt)
        isWorn = try values.decodeIfPresent(Bool.self, forKey: .isWorn) ?? false
        marketPrice = try values.decodeIfPresent(LocalGiftPrice.self, forKey: .marketPrice)
        marketListedAt = try values.decodeIfPresent(Date.self, forKey: .marketListedAt)
    }
}

public enum GiftEventKind: String, Codable, Sendable {
    case created, purchased, received, transferred
    case pinned, unpinned, hidden, unhidden
    case listed, unlisted, worn, unworn, sold
}

public struct GiftEvent: Codable, Identifiable, Sendable {
    public let id: UUID
    public let giftID: UUID
    public let kind: GiftEventKind
    public let fromProfileID: String?
    public let toProfileID: String?
    public let createdAt: Date

    public init(
        id: UUID = UUID(), giftID: UUID, kind: GiftEventKind,
        fromProfileID: String? = nil, toProfileID: String? = nil,
        createdAt: Date = .now
    ) {
        self.id = id
        self.giftID = giftID
        self.kind = kind
        self.fromProfileID = fromProfileID
        self.toProfileID = toProfileID
        self.createdAt = createdAt
    }
}
