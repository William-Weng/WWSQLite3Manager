//
//  SQLite3SchemeDelegate.swift
//  WWSQLite3Manager
//
//  Created by William.Weng on 2022/1/11.
//

import UIKit

// MARK: - SQLite3SchemeDelegate
public protocol SQLite3SchemeDelegate {
    
    /// 欄位順序
    static func structure() -> [(key: String, type: SQLite3Condition.DataType)]
    
    /// 主Key
    static func primaryKey(_ key: String?) -> String?
}

// MARK: - protocol實作
public extension SQLite3SchemeDelegate {
    
    /// [主鍵 (Primary Key) - INTEGER](https://www.1keydata.com/tw/sql/sql-primary-key.html)
    /// - Parameter index: String?
    /// - Returns: String?
    static func primaryKey(_ key: String?) -> String? {
        guard let key = key else { return nil }
        return "PRIMARY KEY(\(key))"
    }
}
