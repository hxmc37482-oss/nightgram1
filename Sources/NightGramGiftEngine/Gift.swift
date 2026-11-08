import Foundation

public enum GiftRarity: String, Codable, CaseIterable, Sendable {
    case common, uncommon, rare, epic, legendary
}

/// A client-side visual item. It is not a Telegram collectible or payment.
public struct LocalGift: Codable, Identifiable, Equatable, Sendable {
    public let id: UUID
    public var title: String
    public var assetName: String
    public var rarity: GiftRarity
    public var visualValue: Int
    public var ownerProfileID: String
    public let createdAt: Date
    public var isPinned: Bool
    public var isHidden: Bool

    public init(
        id: UUID = UUID(),
        title: String,
        assetName: String,
        rarity: GiftRarity = .common,
        visualValue: Int = 0,
        ownerProfileID: String,
        createdAt: Date = .now,
        isPinned: Bool = false,
        isHidden: Bool = false
    ) {
        self.id = id
        self.title = title
        self.assetName = assetName
        self.rarity = rarity
        self.visualValue = max(0, visualValue)
        self.ownerProfileID = ownerProfileID
        self.createdAt = createdAt
        self.isPinned = isPinned
        self.isHidden = isHidden
    }
}

public enum GiftEventKind: String, Codable, Sendable {
    case created, transferred, pinned, unpinned, hidden, unhidden
}

public struct GiftEvent: Codable, Identifiable, Sendable {
    public let id: UUID
    public let giftID: UUID
    public let kind: GiftEventKind
    public let fromProfileID: String?
    public let toProfileID: String?
    public let createdAt: Date

    public init(
        id: UUID = UUID(),
        giftID: UUID,
        kind: GiftEventKind,
        fromProfileID: String? = nil,
        toProfileID: String? = nil,
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
