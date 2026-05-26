//
//  SQLite3SchemeDelegate.swift
//  WWSQLite3Manager
//
//  Created by William.Weng on 2022/1/11.
//

import UIKit

// MARK: - SchemeDelegate
public extension WWSQLite3Manager {
    
    /// 建立資料庫的欄位 / 主鍵設定
    protocol SchemeDelegate {
        
        static func structure() -> [(key: String, type: WWSQLite3Manager.DataType)]     // 欄位結構順序
        static func primaryKeys(_ keys: [String?]) -> String?                           // 複合主鍵名稱
    }
}

// MARK: - protocol實作
public extension WWSQLite3Manager.SchemeDelegate {
    
    /// [建立主鍵限制字串 (Primary Key)](https://www.1keydata.com/tw/sql/sql-primary-key.html)
    /// - Parameter keys: 主鍵欄位名稱陣列，可為單一主鍵或複合主鍵
    /// - Returns: `PRIMARY KEY(...)` 字串；若沒有有效欄位名稱則回傳 `nil`
    /// - Note:
    ///   - 會自動過濾 `nil` 與空字串欄位名稱
    ///   - 若有多個欄位，會產生複合主鍵，例如 `PRIMARY KEY("id", "name")`
    ///   - 若傳入多個欄位，會建立複合主鍵，例如：`PRIMARY KEY("id", "name")`
    static func primaryKeys(_ keys: [String?]) -> String? {
        
        let fields = keys
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map { $0.sqlIdentifier() }
        
        guard !fields.isEmpty else { return nil }
        
        return "PRIMARY KEY(\(fields.joined(separator: ", ")))"
    }
}


