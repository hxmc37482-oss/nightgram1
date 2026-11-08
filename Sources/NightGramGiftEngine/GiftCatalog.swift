import Foundation

public struct GiftTemplate: Identifiable, Codable, Equatable, Sendable {
    public let id: String
    public let title: String
    public let assetName: String
    public let rarity: GiftRarity
    public let suggestedVisualValue: Int

    public init(id: String, title: String, assetName: String, rarity: GiftRarity, suggestedVisualValue: Int) {
        self.id = id
        self.title = title
        self.assetName = assetName
        self.rarity = rarity
        self.suggestedVisualValue = max(0, suggestedVisualValue)
    }
}

/// Starter catalogue for local previews. Values are illustrative, not Telegram prices.
public enum GiftCatalog {
    public static let all: [GiftTemplate] = [
        .init(id: "rose", title: "Rose", assetName: "gift_rose", rarity: .common, suggestedVisualValue: 25),
        .init(id: "heart", title: "Heart", assetName: "gift_heart", rarity: .common, suggestedVisualValue: 50),
        .init(id: "cake", title: "Cake", assetName: "gift_cake", rarity: .uncommon, suggestedVisualValue: 75),
        .init(id: "teddy", title: "Teddy Bear", assetName: "gift_teddy", rarity: .rare, suggestedVisualValue: 100),
        .init(id: "diamond", title: "Diamond", assetName: "gift_diamond", rarity: .epic, suggestedVisualValue: 250),
        .init(id: "crown", title: "Crown", assetName: "gift_crown", rarity: .legendary, suggestedVisualValue: 500)
    ]

    public static func template(id: String) -> GiftTemplate? {
        all.first { $0.id == id }
    }
}
