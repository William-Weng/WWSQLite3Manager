//
//  File.swift
//  
//
//  Created by iOS on 2022/1/18.
//

import Foundation

// MARK: - Limit
public extension SQLite3Condition.Limit {
    
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
