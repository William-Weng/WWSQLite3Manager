//
//  File.swift
//  WWSQLite3Manager
//
//  Created by iOS on 2026/5/26.
//

import Foundation

// MARK: - FTS5 Configuration
public extension WWSQLite3Manager {
    
    /// FTS5 搜尋結果
    struct FTS5Result: Codable {
        
        public let rowID: Int64
        public let rank: Double?
        public let highlightedText: String?
        public let snippet: String?
        
        /// 建立 FTS5 結果
        /// - Parameters:
        ///   - rowID: 原始資料表的 rowid
        ///   - rank: 相關性排名 (rank)
        ///   - highlightedText: 高亮後的欄位 (如果有要求)
        ///   - snippet: 摘要片段 (如果有要求)
        public init(rowID: Int64, rank: Double?, highlightedText: String?, snippet: String?) {
            self.rowID = rowID
            self.rank = rank
            self.highlightedText = highlightedText
            self.snippet = snippet
        }
    }
}
