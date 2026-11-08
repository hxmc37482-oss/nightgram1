import Foundation

public enum LocalWalletError: Error, Equatable {
    case invalidAmount
    case insufficientBalance
}

public struct LocalWalletEntry: Codable, Identifiable, Equatable, Sendable {
    public let id: UUID
    public let delta: Int
    public let reason: String
    public let createdAt: Date

    public init(id: UUID = UUID(), delta: Int, reason: String, createdAt: Date = .now) {
        self.id = id
        self.delta = delta
        self.reason = reason
        self.createdAt = createdAt
    }
}

/// Simulated balance stored only on this device. It is not a Telegram Stars wallet.
public actor LocalWallet {
    private let defaults: UserDefaults
    private let balanceKey: String
    private let historyKey: String
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    public init(profileID: String, defaults: UserDefaults = .standard, initialBalance: Int = 0) {
        self.defaults = defaults
        self.balanceKey = "nightgram.localWallet.\(profileID).balance"
        self.historyKey = "nightgram.localWallet.\(profileID).history"
        if defaults.object(forKey: balanceKey) == nil {
            defaults.set(max(0, initialBalance), forKey: balanceKey)
        }
    }

    public func balance() -> Int {
        defaults.integer(forKey: balanceKey)
    }

    public func history() -> [LocalWalletEntry] {
        guard let data = defaults.data(forKey: historyKey),
              let entries = try? decoder.decode([LocalWalletEntry].self, from: data) else { return [] }
        return entries
    }

    public func setDemoBalance(_ amount: Int, reason: String = "Manual demo adjustment") throws {
        guard amount >= 0 else { throw LocalWalletError.invalidAmount }
        let old = balance()
        defaults.set(amount, forKey: balanceKey)
        append(.init(delta: amount - old, reason: reason))
    }

    public func spendDemoPoints(_ amount: Int, reason: String) throws {
        guard amount > 0 else { throw LocalWalletError.invalidAmount }
        let old = balance()
        guard old >= amount else { throw LocalWalletError.insufficientBalance }
        defaults.set(old - amount, forKey: balanceKey)
        append(.init(delta: -amount, reason: reason))
    }

    public func addDemoPoints(_ amount: Int, reason: String) throws {
        guard amount > 0 else { throw LocalWalletError.invalidAmount }
        let old = balance()
        let (newValue, overflow) = old.addingReportingOverflow(amount)
        guard !overflow else { throw LocalWalletError.invalidAmount }
        defaults.set(newValue, forKey: balanceKey)
        append(.init(delta: amount, reason: reason))
    }

    private func append(_ entry: LocalWalletEntry) {
        var entries = history()
        entries.insert(entry, at: 0)
        if entries.count > 250 { entries = Array(entries.prefix(250)) }
        if let data = try? encoder.encode(entries) { defaults.set(data, forKey: historyKey) }
    }
}
