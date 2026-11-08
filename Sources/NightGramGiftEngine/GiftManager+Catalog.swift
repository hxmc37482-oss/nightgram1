import Foundation

public extension GiftManager {
    @discardableResult
    func createGift(from template: GiftTemplate, ownerProfileID: String) async throws -> LocalGift {
        try await createGift(
            title: template.title,
            assetName: template.assetName,
            rarity: template.rarity,
            visualValue: template.suggestedVisualValue,
            ownerProfileID: ownerProfileID
        )
    }
}
