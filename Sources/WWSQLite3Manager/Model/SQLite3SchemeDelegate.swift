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
    
    /// 複合主鍵
    static func primaryKeys(_ keys: [String?]) -> String?
}

// MARK: - protocol實作
public extension SQLite3SchemeDelegate {
    
    /// [主鍵 (Primary Key) - INTEGER](https://www.1keydata.com/tw/sql/sql-primary-key.html)
    /// - Parameter index: [String?](https://www.runoob.com/sqlite/sqlite-constraints.html)
    /// - Returns: String?
    static func primaryKeys(_ keys: [String?]) -> String? {
        
        guard let keys = Optional.some(keys.compactMap { key in return key }),
              !keys.isEmpty,
              let fields = Optional.some(keys.joined(separator: ", "))
        else {
            return nil
        }
        
        return "PRIMARY KEY(\(fields))"
    }
}
