//
//  File.swift
//  WWSQLite3Manager
//
//  Created by iOS on 2026/5/25.
//

import Foundation

public extension WWSQLite3Manager.Condition {
    
    /// [數量取得條件](https://www.runoob.com/sqlite/sqlite-limit-clause.html)
    public class Limit: NSObject {
        var items: String = ""
    }
}

// MARK: - Limit
public extension WWSQLite3Manager.Condition.Limit {
    
    /// 產生數量取得條件
    /// - LIMIT 3 OFFSET 2
    /// - Parameters:
    ///   - count: Int
    ///   - offset: Int
    /// - Returns: self
    func build(count: Int, offset: Int = 0) -> Self {
        items = "LIMIT \(count) OFFSET \(offset)"
        return self
    }
}
