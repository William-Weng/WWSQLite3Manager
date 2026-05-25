//
//  SQLite3Condition+OrderBy.swift
//  WWSQLite3Manager
//
//  Created by William.Weng on 2022/1/17.
//

import Foundation

public extension WWSQLite3Manager.Condition {
    
    /// [數量取得條件](https://www.runoob.com/sqlite/sqlite-limit-clause.html)
    public class OrderBy: NSObject {
        var items: String = ""
    }
}

// MARK: - OrderBy
public extension WWSQLite3Manager.Condition.OrderBy {

    /// 組成排序用字串 => name ASC
    /// - Parameters:
    ///   - type: SQLite3Condition.OrderByType
    /// - Returns: Self
    func item(type: WWSQLite3Manager.OrderByType) -> Self {
        
        let info = parseOrderByTypeInfo(type)
        self.items += "\(info.key) \(info.symbol)"
        
        return self
    }
    
    /// 組成排序用字串 => , height DESC
    /// - Parameters:
    ///   - type: SQLite3Condition.OrderByType
    /// - Returns: Self
    func addItem(type: WWSQLite3Manager.OrderByType) -> Self {
        
        let info = parseOrderByTypeInfo(type)
        self.items += ", \(info.key) \(info.symbol)"
        
        return self
    }
}

// MARK: - 小工具
public extension WWSQLite3Manager.Condition.OrderBy {

    /// 解析SQLite3Condition.OrderByType
    /// - Parameter type: SQLite3Condition.OrderByType
    /// - Returns: OrderType
    func parseOrderByTypeInfo(_ type: WWSQLite3Manager.OrderByType) -> WWSQLite3Manager.OrderType {
        
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
