//
//  OrderBy.swift
//  WWSQLite3Manager
//
//  Created by William.Weng on 2026/5/26.
//

import Foundation

public extension WWSQLite3Manager {
        
    /// [SQL ORDER BY 條件建構器](https://www.runoob.com/sqlite/sqlite-limit-clause.html)
    ///
    /// 用來指定查詢結果的排序欄位與排序方向
    class OrderBy {
        
        private var items: String = ""
        
        public required init() {}
    }
}

// MARK: - OrderBy
public extension WWSQLite3Manager.OrderBy {
    
    var sqlString: String { items }     // 轉成 SQL ORDER BY 子句字串
}

// MARK: - OrderBy
public extension WWSQLite3Manager.OrderBy {
        
    /// 產生 ORDER BY 條件
    ///
    /// - Note:
    ///   - `symbol` 通常為 `ASC` 或 `DESC`
    ///   - 可同時指定多個排序欄位
    ///
    /// - Parameters:
    ///   - orderTypes: 排序規則陣列
    /// - Returns: 自身實例，方便鏈式呼叫
    @discardableResult
    func build(orderTypes: [WWSQLite3Manager.OrderType]) -> Self {
        
        let validItems = orderTypes.compactMap { item -> String? in
            
            let key = item.key.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !key.isEmpty else { return nil }
            
            return "\(key) \(item.direction.rawValue)"
        }
        
        guard !validItems.isEmpty else { items = ""; return self }
        
        items = "ORDER BY " + validItems.joined(separator: ", ")
        return self
    }
    
    /// 產生單一欄位的 ORDER BY 條件
    ///
    /// - Parameters:
    ///   - key: 排序欄位名稱
    ///   - direction: 排序方向，預設為升冪
    /// - Returns: 自身實例，方便鏈式呼叫
    @discardableResult
    func build(key: String, direction: WWSQLite3Manager.SortDirection = .asc) -> Self {
        build(orderTypes: [(key: key, direction: direction)])
    }
}
