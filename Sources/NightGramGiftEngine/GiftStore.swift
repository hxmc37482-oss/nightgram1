import Foundation
import CSQLite

public enum GiftStoreError: Error {
    case openDatabase(String)
    case sqlite(String)
    case encoding
    case giftNotFound
}

public actor GiftStore {
    private var db: OpaquePointer?
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    public init(databaseURL: URL) throws {
        let directory = databaseURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        guard sqlite3_open(databaseURL.path, &db) == SQLITE_OK, db != nil else {
            let message = db.map { String(cString: sqlite3_errmsg($0)) } ?? "Unknown SQLite error"
            throw GiftStoreError.openDatabase(message)
        }

        try execute("""
            CREATE TABLE IF NOT EXISTS gifts (
                id TEXT PRIMARY KEY NOT NULL,
                payload TEXT NOT NULL
            );
            """)
        try execute("""
            CREATE TABLE IF NOT EXISTS gift_events (
                id TEXT PRIMARY KEY NOT NULL,
                payload TEXT NOT NULL
            );
            """)
        try execute("CREATE INDEX IF NOT EXISTS gifts_id_idx ON gifts(id);")
    }

    deinit {
        if let db { sqlite3_close(db) }
    }

    public func save(_ gift: LocalGift) throws {
        try run(
            "INSERT OR REPLACE INTO gifts(id, payload) VALUES(?, ?);",
            values: [gift.id.uuidString, try json(gift)]
        )
    }

    public func gift(id: UUID) throws -> LocalGift? {
        let rows = try query("SELECT payload FROM gifts WHERE id = ? LIMIT 1;", values: [id.uuidString])
        guard let first = rows.first else { return nil }
        return try decode(LocalGift.self, from: first)
    }

    public func gifts(ownerProfileID: String, includeHidden: Bool = false) throws -> [LocalGift] {
        let rows = try query("SELECT payload FROM gifts;")
        return try rows
            .map { try decode(LocalGift.self, from: $0) }
            .filter {
                $0.ownerProfileID == ownerProfileID
                && (includeHidden || !$0.isHidden)
                && $0.soldAt == nil
            }
            .sorted {
                if $0.isPinned != $1.isPinned { return $0.isPinned }
                return $0.createdAt > $1.createdAt
            }
    }

    public func allGifts(includeSold: Bool = true) throws -> [LocalGift] {
        let rows = try query("SELECT payload FROM gifts;")
        return try rows
            .map { try decode(LocalGift.self, from: $0) }
            .filter { includeSold || $0.soldAt == nil }
            .sorted { $0.createdAt > $1.createdAt }
    }

    public func marketGifts() throws -> [LocalGift] {
        try allGifts(includeSold: false)
            .filter { $0.marketPrice != nil }
            .sorted { ($0.marketListedAt ?? .distantPast) > ($1.marketListedAt ?? .distantPast) }
    }

    public func delete(id: UUID) throws {
        try run("DELETE FROM gifts WHERE id = ?;", values: [id.uuidString])
    }

    public func append(_ event: GiftEvent) throws {
        try run(
            "INSERT INTO gift_events(id, payload) VALUES(?, ?);",
            values: [event.id.uuidString, try json(event)]
        )
    }

    public func history(giftID: UUID) throws -> [GiftEvent] {
        let rows = try query("SELECT payload FROM gift_events;")
        return try rows
            .map { try decode(GiftEvent.self, from: $0) }
            .filter { $0.giftID == giftID }
            .sorted { $0.createdAt > $1.createdAt }
    }

    private func execute(_ sql: String) throws {
        guard let db else { throw GiftStoreError.sqlite("Database is closed") }
        var error: UnsafeMutablePointer<CChar>?
        guard sqlite3_exec(db, sql, nil, nil, &error) == SQLITE_OK else {
            let message = error.map { String(cString: $0) } ?? String(cString: sqlite3_errmsg(db))
            sqlite3_free(error)
            throw GiftStoreError.sqlite(message)
        }
    }

    private func run(_ sql: String, values: [String]) throws {
        guard let db else { throw GiftStoreError.sqlite("Database is closed") }
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            throw GiftStoreError.sqlite(String(cString: sqlite3_errmsg(db)))
        }
        defer { sqlite3_finalize(statement) }
        for (index, value) in values.enumerated() {
            sqlite3_bind_text(statement, Int32(index + 1), value, -1, Self.transient)
        }
        guard sqlite3_step(statement) == SQLITE_DONE else {
            throw GiftStoreError.sqlite(String(cString: sqlite3_errmsg(db)))
        }
    }

    private func query(_ sql: String, values: [String] = []) throws -> [String] {
        guard let db else { throw GiftStoreError.sqlite("Database is closed") }
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            throw GiftStoreError.sqlite(String(cString: sqlite3_errmsg(db)))
        }
        defer { sqlite3_finalize(statement) }
        for (index, value) in values.enumerated() {
            sqlite3_bind_text(statement, Int32(index + 1), value, -1, Self.transient)
        }
        var result: [String] = []
        while sqlite3_step(statement) == SQLITE_ROW {
            guard let text = sqlite3_column_text(statement, 0) else { continue }
            result.append(String(cString: text))
        }
        return result
    }

    private func json<T: Encodable>(_ value: T) throws -> String {
        guard let string = String(data: try encoder.encode(value), encoding: .utf8) else {
            throw GiftStoreError.encoding
        }
        return string
    }

    private func decode<T: Decodable>(_ type: T.Type, from string: String) throws -> T {
        try decoder.decode(type, from: Data(string.utf8))
    }

    private static let transient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
}
