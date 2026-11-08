import Foundation

public enum LocalGiftLedgerError: Error, Equatable {
    case invalidAmount, insufficientBalance, balanceOverflow
}

public enum LocalGiftLedgerKind: String, Codable, Sendable {
    case purchase, receivedDemoGift, sale, manualAdjustment
}

public struct LocalGiftLedgerEntry: Codable, Identifiable, Equatable, Sendable {
    public let id: UUID
    public let currency: LocalGiftCurrency
    public let kind: LocalGiftLedgerKind
    public let delta: Int64
    public let title: String
    public let details: String?
    public let balanceAfter: Int64
    public let createdAt: Date

    public init(
        id: UUID = UUID(), currency: LocalGiftCurrency, kind: LocalGiftLedgerKind,
        delta: Int64, title: String, details: String? = nil,
        balanceAfter: Int64, createdAt: Date = .now
    ) {
        self.id = id
        self.currency = currency
        self.kind = kind
        self.delta = delta
        self.title = title
        self.details = details
        self.balanceAfter = balanceAfter
        self.createdAt = createdAt
    }
}

/// PampGram-inspired local ledger, isolated from Telegram balances and payment history.
public actor LocalGiftLedger {
    private let defaults: UserDefaults
    private let profileID: String
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    public init(profileID: String, defaults: UserDefaults = .standard) {
        self.profileID = profileID
        self.defaults = defaults
    }

    public func balance(for currency: LocalGiftCurrency) -> Int64 {
        defaults.object(forKey: balanceKey(currency)) as? Int64 ?? 0
    }

    public func balances() -> [LocalGiftCurrency: Int64] {
        Dictionary(uniqueKeysWithValues: LocalGiftCurrency.allCases.map { ($0, balance(for: $0)) })
    }

    public func history(for currency: LocalGiftCurrency? = nil) -> [LocalGiftLedgerEntry] {
        guard let data = defaults.data(forKey: historyKey),
              let entries = try? decoder.decode([LocalGiftLedgerEntry].self, from: data) else { return [] }
        return entries.filter { currency == nil || $0.currency == currency }
            .sorted { $0.createdAt > $1.createdAt }
    }

    public func setDemoBalance(_ amount: Int64, for currency: LocalGiftCurrency, reason: String = "Демо-корректировка") throws {
        guard amount >= 0 else { throw LocalGiftLedgerError.invalidAmount }
        let old = balance(for: currency)
        defaults.set(amount, forKey: balanceKey(currency))
        append(.init(currency: currency, kind: .manualAdjustment, delta: amount - old,
                     title: reason, balanceAfter: amount))
    }

    public func debit(_ price: LocalGiftPrice, title: String, details: String? = nil) throws {
        guard price.amount > 0 else { throw LocalGiftLedgerError.invalidAmount }
        let old = balance(for: price.currency)
        guard old >= price.amount else { throw LocalGiftLedgerError.insufficientBalance }
        let updated = old - price.amount
        defaults.set(updated, forKey: balanceKey(price.currency))
        append(.init(currency: price.currency, kind: .purchase, delta: -price.amount,
                     title: title, details: details, balanceAfter: updated))
    }

    public func credit(_ price: LocalGiftPrice, kind: LocalGiftLedgerKind,
                       title: String, details: String? = nil) throws {
        guard price.amount > 0 else { throw LocalGiftLedgerError.invalidAmount }
        let old = balance(for: price.currency)
        let (updated, overflow) = old.addingReportingOverflow(price.amount)
        guard !overflow else { throw LocalGiftLedgerError.balanceOverflow }
        defaults.set(updated, forKey: balanceKey(price.currency))
        append(.init(currency: price.currency, kind: kind, delta: price.amount,
                     title: title, details: details, balanceAfter: updated))
    }

    private func balanceKey(_ currency: LocalGiftCurrency) -> String {
        "nightgram.localGiftLedger.\(profileID).\(currency.rawValue).balance"
    }

    private var historyKey: String {
        "nightgram.localGiftLedger.\(profileID).history"
    }

    private func append(_ entry: LocalGiftLedgerEntry) {
        var entries = history()
        entries.insert(entry, at: 0)
        if entries.count > 500 { entries = Array(entries.prefix(500)) }
        if let data = try? encoder.encode(entries) { defaults.set(data, forKey: historyKey) }
    }
}
