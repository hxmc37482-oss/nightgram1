import XCTest
@testable import NightGramGiftEngine

final class PampGramGiftPortTests: XCTestCase {
    func testLedgerKeepsDemoCurrenciesSeparate() async throws {
        let suiteName = "NightGramGiftPortTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let ledger = LocalGiftLedger(profileID: "profile", defaults: defaults)
        try await ledger.setDemoBalance(500, for: .stars)
        try await ledger.setDemoBalance(2_000_000_000, for: .ton)

        try await ledger.debit(
            LocalGiftPrice(amount: 125, currency: .stars),
            title: "Demo purchase",
            details: "Rose"
        )
        try await ledger.credit(
            LocalGiftPrice(amount: 50, currency: .stars),
            kind: .receivedDemoGift,
            title: "Demo received gift"
        )

        let stars = await ledger.balance(for: .stars)
        let ton = await ledger.balance(for: .ton)
        XCTAssertEqual(stars, 425)
        XCTAssertEqual(ton, 2_000_000_000)

        let starHistory = await ledger.history(for: .stars)
        XCTAssertEqual(starHistory.count, 3)
        XCTAssertTrue(starHistory.contains { $0.delta == -125 })
        XCTAssertTrue(starHistory.contains { $0.delta == 50 })
    }

    func testOldGiftPayloadDecodesWithDefaultsForNewFields() throws {
        struct LegacyGift: Codable {
            let id: UUID
            let title: String
            let assetName: String
            let rarity: GiftRarity
            let visualValue: Int
            let ownerProfileID: String
            let createdAt: Date
            let isPinned: Bool
            let isHidden: Bool
        }

        let legacy = LegacyGift(
            id: UUID(),
            title: "Rose",
            assetName: "rose",
            rarity: .common,
            visualValue: 10,
            ownerProfileID: "self",
            createdAt: .now,
            isPinned: true,
            isHidden: false
        )
        let data = try JSONEncoder().encode(legacy)
        let decoded = try JSONDecoder().decode(LocalGift.self, from: data)

        XCTAssertTrue(decoded.isPinned)
        XCTAssertFalse(decoded.isReceived)
        XCTAssertFalse(decoded.isWorn)
        XCTAssertNil(decoded.purchasePrice)
        XCTAssertNil(decoded.marketPrice)
        XCTAssertNil(decoded.soldAt)
    }
}
