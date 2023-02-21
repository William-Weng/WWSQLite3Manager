//
//  SQLite3Condition+OrderBy.swift
//  WWSQLite3Manager
//
//  Created by William.Weng on 2022/1/17.
//

import Foundation

// MARK: - OrderBy
public extension SQLite3Condition.OrderBy {
    
    /// 組成排序用字串
    /// - name ASC
    /// - Parameters:
    ///   - key: String
    ///   - type: SQLite3Condition.OrderByType
    /// - Returns: Self
    func item(key: String, type: SQLite3Condition.OrderByType) -> Self {
        self.items += "\(key) \(type.rawValue)"
        return self
    }
    
    /// 組成排序用字串
    /// - , height DESC
    /// - Parameters:
    ///   - key: String
    ///   - type: SQLite3Condition.OrderByType
    /// - Returns: Self
    func addItem(key: String, type: SQLite3Condition.OrderByType) -> Self {
        self.items += ", \(key) \(type.rawValue)"
        return self
    }
}
