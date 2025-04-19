//
//  SQLite3Condition+OrderBy.swift
//  WWSQLite3Manager
//
//  Created by William.Weng on 2022/1/17.
//

import Foundation

// MARK: - OrderBy
public extension SQLite3Condition.OrderBy {
    
    /// 組成排序用字串 => name ASC
    /// - Parameters:
    ///   - type: SQLite3Condition.OrderByType
    /// - Returns: Self
    func item(type: SQLite3Condition.OrderByType) -> Self {
        
        let info = parseOrderByTypeInfo(type)
        self.items += "\(info.key) \(info.symbol)"
        
        return self
    }
    
    /// 組成排序用字串 => , height DESC
    /// - Parameters:
    ///   - type: SQLite3Condition.OrderByType
    /// - Returns: Self
    func addItem(type: SQLite3Condition.OrderByType) -> Self {
        
        let info = parseOrderByTypeInfo(type)
        self.items += ", \(info.key) \(info.symbol)"
        
        return self
    }
}

// MARK: - 小工具
private extension SQLite3Condition.OrderBy {
    
    /// 解析SQLite3Condition.OrderByType
    /// - Parameter type: SQLite3Condition.OrderByType
    /// - Returns: Constant.OrderType
    func parseOrderByTypeInfo(_ type: SQLite3Condition.OrderByType) -> Constant.OrderType {
        
        let key: String
        let symbol = type.symbol()
        
        switch type {
        case .ascending(let _key): key = _key
        case .descending(let _key): key = _key
        case .random: key = ""
        }
        
        return (key: key, symbol: type.symbol())
    }
}
