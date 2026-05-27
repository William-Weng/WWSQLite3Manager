//
//  FTS5Configuration.swift
//  WWSQLite3Manager
//
//  Created by William.Weng on 2026/5/26.
//

import Foundation
import SQLite3

// MARK: - FTS5 Configuration
public extension WWSQLite3Manager {
    
    /// FTS5 表設定
    struct FTS5Configuration {
        
        public let table: String
        public let ftsTable: String
        public let rowID: String
        public let indexedColumns: [String]
        public let tokenizer: FTS5Tokenizer
        
        /// 建立 FTS5 設定
        /// - Parameters:
        ///   - table: 原始資料表名稱
        ///   - ftsTable: FTS5 虛擬表名稱
        ///   - rowID: 主鍵欄位名稱
        ///   - indexedColumns: 要索引的欄位清單
        ///   - tokenizer: tokenizer 設定 (預設 "unicode61")
        public init(table: String, ftsTable: String, rowID: String = "id", indexedColumns: [String], tokenizer: FTS5Tokenizer = .unicode61) {
            self.table = table
            self.ftsTable = ftsTable
            self.rowID = rowID
            self.indexedColumns = indexedColumns
            self.tokenizer = tokenizer
        }
    }
}

// MARK: - 公開函式
public extension WWSQLite3Manager.Database {
    
    /// 建立 FTS5 虛擬表 (外部內容表模式 - 推薦)
    /// - Parameter config: FTS5 設定
    /// - Throws: SQLite 錯誤
    func createFTS5Table(_ config: WWSQLite3Manager.FTS5Configuration) throws {
        
        guard !config.indexedColumns.isEmpty else { throw WWSQLite3Manager.CustomError.missingItems }
        
        let columnsSQL = config.indexedColumns.map { "\"\($0)\"" }.joined(separator: ", ")
        let sql = #"CREATE VIRTUAL TABLE "\#(config.ftsTable)" USING fts5(\#(columnsSQL), content="\#(config.table)", content_rowid="\#(config.rowID)", tokenize="\#(config.tokenizer.rawValue)")"#
        
        try execute(sql: sql)
    }
    
    /// 建立 FTS5 虛擬表 (獨立表模式，不參照原表)
    /// - Parameters:
    ///   - ftsTable: FTS5 虛擬表名稱
    ///   - indexedColumns: 要索引的欄位清單
    ///   - tokenizer: tokenizer 設定
    /// - Throws: SQLite 錯誤
    func createFTS5Table(ftsTable: String, indexedColumns: [String], tokenizer: String = "unicode61") throws {
        
        let columnsSQL = indexedColumns.map { "\"\($0)\"" }.joined(separator: ", ")
        let sql = "CREATE VIRTUAL TABLE \"\(ftsTable)\" USING fts5(\n\(columnsSQL),\ntokenize=\"\(tokenizer)\"\n)"
        
        try execute(sql: sql)
    }

    /// 建立 FTS5 自動同步 triggers (INSERT, DELETE, UPDATE)
    /// - Parameter config: FTS5 設定
    /// - Throws: SQLite 錯誤
    func createFTS5Triggers(_ config: WWSQLite3Manager.FTS5Configuration) throws {
        
        let columns = config.indexedColumns.map { "\"\($0)\"" }.joined(separator: ", ")
        let columnsWithNew = config.indexedColumns.map { "\"\($0)\" = new.\"\($0)\"" }.joined(separator: ", ")
        let columnsWithOld = config.indexedColumns.map { "\"\($0)\" = old.\"\($0)\"" }.joined(separator: ", ")
        
        let insertTrigger = """
            CREATE TRIGGER IF NOT EXISTS "\(config.table)_ai" AFTER INSERT ON "\(config.table)" BEGIN
                INSERT INTO "\(config.ftsTable)"(rowid, \(columns))
                VALUES (new."\(config.rowID)", new.\(columnsWithNew));
            END
            """
        try execute(sql: insertTrigger)
        
        let deleteTrigger = """
            CREATE TRIGGER IF NOT EXISTS "\(config.table)_ad" AFTER DELETE ON "\(config.table)" BEGIN
                INSERT INTO "\(config.ftsTable)"("\(config.ftsTable)", rowid, \(columns))
                VALUES ('delete', old."\(config.rowID)", old.\(columnsWithOld));
            END
            """
        try execute(sql: deleteTrigger)
        
        let updateTrigger = """
            CREATE TRIGGER IF NOT EXISTS "\(config.table)_au" AFTER UPDATE ON "\(config.table)" BEGIN
                INSERT INTO "\(config.ftsTable)"("\(config.ftsTable)", rowid, \(columns))
                VALUES ('delete', old."\(config.rowID)", old.\(columnsWithOld));
            
                INSERT INTO "\(config.ftsTable)"(rowid, \(columns))
                VALUES (new."\(config.rowID)", new.\(columnsWithNew));
            END
            """
        try execute(sql: updateTrigger)
    }
    
    /// 刪除 FTS5 triggers
    /// - Parameter config: FTS5 設定
    /// - Throws: SQLite 錯誤
    func dropFTS5Triggers(_ config: WWSQLite3Manager.FTS5Configuration) throws {
        try execute(sql: #"DROP TRIGGER IF EXISTS "\#(config.table)_ai""#)
        try execute(sql: #"DROP TRIGGER IF EXISTS "\#(config.table)_ad""#)
        try execute(sql: #"DROP TRIGGER IF EXISTS "\#(config.table)_au""#)
    }
    
    /// 重建 FTS5 索引 (當原表已有舊資料時使用)
    /// - Parameter ftsTable: FTS5 表名稱
    /// - Throws: SQLite 錯誤
    func rebuildFTS5Index(ftsTable: String) throws {
        let sql = "INSERT INTO \"\(ftsTable)\"(\"\(ftsTable)\") VALUES('rebuild')"
        try execute(sql: sql)
    }
    
    /// FTS5 搜尋
    /// - Parameters:
    ///   - ftsTable: FTS5 表名稱
    ///   - keyword: 搜尋關鍵字
    ///   - highlightColumn: 高亮欄位 (nil = 不高亮)
    ///   - snippetColumn: 摘要欄位 (nil = 不產生摘要)
    ///   - snippetLength: 摘要長度
    ///   - limit: 結果數量限制
    ///   - offset: 結果偏移量
    /// - Returns: FTS5Result 陣列
    /// - Throws: SQLite 錯誤
    func searchFTS5(ftsTable: String, keyword: String, highlightColumn: Int? = nil, snippetColumn: Int? = nil, snippetLength: Int = 40, limit: Int = 20, offset: Int = 0) throws -> [WWSQLite3Manager.FTS5Result] {
        
        var selects = ["rowid", "rank"]
        var highlightedIndex: Int? = nil
        var snippetIndex: Int? = nil
        var outputIndex = 2

        if let col = highlightColumn {
            let highlightSQL = #"highlight("\#(ftsTable)", \#(col), '<b>', '</b>') AS highlighted"#
            selects.append(highlightSQL)
        }
        
        if let col = snippetColumn {
            let snippetSQL = #"snippet("\#(ftsTable)", \#(col), '<b>', '</b>', '...', \#(snippetLength)) AS snippet"#
            selects.append(snippetSQL)
        }
        
        var sql = #"SELECT \#(selects.joined(separator: ", ")) FROM "\#(ftsTable)""#
        sql += #" WHERE "\#(ftsTable)" MATCH '\#(keyword.escapingSingleQuote())'"#
        sql += " ORDER BY rank"
        
        if limit > 0 { sql += " LIMIT \(limit) OFFSET \(offset)" }
                
        let rows = try query(sql: sql)
        
        let items: [WWSQLite3Manager.FTS5Result] = rows.map { row in
            
            let rowID = row["rowid"] as? Int64 ?? 0
            let rank = row["rank"] as? Double
            let highlightedText = row["highlighted"] as? String
            let snippet = row["snippet"] as? String
            
            return .init(rowID: rowID, rank: rank, highlightedText: highlightedText, snippet: snippet)
        }
        
        return items
    }
    
    /// 簡易 FTS5 搜尋 (只回傳 rowid + rank)
    /// - Parameters:
    ///   - ftsTable: FTS5 表名稱
    ///   - query: 搜尋關鍵字
    ///   - limit: 結果數量限制
    ///   - offset: 結果偏移量
    /// - Returns: [Int64] rowid 陣列
    /// - Throws: SQLite 錯誤
    func searchFTS5Simple(ftsTable: String, keyword: String, limit: Int = 20, offset: Int = 0) async throws -> [Int64] {
        
        let sql = #"SELECT rowid, rank FROM "\#(ftsTable)" WHERE "\#(ftsTable)" MATCH '\#(keyword.escapingSingleQuote())' ORDER BY rank LIMIT \#(limit) OFFSET \#(offset)"#
        let rows = try await query(sql: sql)

        return rows.compactMap { $0["rowid"] as? Int64 }
    }
}
