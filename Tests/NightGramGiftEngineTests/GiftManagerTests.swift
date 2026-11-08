import XCTest
@testable import NightGramGiftEngine

final class GiftManagerTests: XCTestCase {
    func testCreateAndTransferAreLocalAndRecorded() async throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let databaseURL = directory.appendingPathComponent("nightgram.sqlite")
        let store = try GiftStore(databaseURL: databaseURL)
        let manager = GiftManager(store: store)

        let gift = try await manager.createGift(
            title: "Test Star",
            assetName: "gift_star",
            rarity: .rare,
            visualValue: 25,
            ownerProfileID: "local-profile-a"
        )

        let initialCollection = try await manager.collection(for: "local-profile-a")
        XCTAssertEqual(initialCollection.count, 1)

        try await manager.transfer(giftID: gift.id, to: "local-profile-b")

        let oldOwnerCollection = try await manager.collection(for: "local-profile-a")
        let newOwnerCollection = try await manager.collection(for: "local-profile-b")
        XCTAssertEqual(oldOwnerCollection.count, 0)
        XCTAssertEqual(newOwnerCollection.first?.id, gift.id)

        let history = try await manager.history(for: gift.id)
        XCTAssertEqual(history.map(\.kind), [.transferred, .created])

        try? FileManager.default.removeItem(at: directory)
    }
}
