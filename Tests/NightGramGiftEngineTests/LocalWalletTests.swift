import XCTest
@testable import NightGramGiftEngine

final class LocalWalletTests: XCTestCase {
    func testDemoLedgerUpdatesBalance() async throws {
        let suiteName = "NightGramTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let wallet = LocalWallet(profileID: "test-profile", defaults: defaults, initialBalance: 100)
        let initial = await wallet.balance()
        XCTAssertEqual(initial, 100)

        try await wallet.spendDemoPoints(30, reason: "Test purchase")
        let afterSpend = await wallet.balance()
        XCTAssertEqual(afterSpend, 70)

        try await wallet.addDemoPoints(10, reason: "Test credit")
        let afterCredit = await wallet.balance()
        XCTAssertEqual(afterCredit, 80)

        let entries = await wallet.history()
        XCTAssertEqual(entries.count, 2)
        XCTAssertEqual(entries.map(\.delta), [10, -30])
    }

    func testCatalogHasUniqueIdentifiers() {
        let identifiers = GiftCatalog.all.map(\.id)
        XCTAssertEqual(Set(identifiers).count, identifiers.count)
        XCTAssertFalse(GiftCatalog.all.isEmpty)
    }
}
