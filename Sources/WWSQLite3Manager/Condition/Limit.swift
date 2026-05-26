//
//  Limit.swift
//  WWSQLite3Manager
//
//  Created by William.Weng on 2026/5/26.
//

import Foundation

public extension WWSQLite3Manager {
    
    /// [SQL LIMIT 條件建構器](https://www.runoob.com/sqlite/sqlite-limit-clause.html)
    ///
    /// 用來限制 SELECT 查詢回傳的資料筆數，並可搭配 OFFSET 指定略過的資料筆數
    ///
    /// - Example:
    ///   `LIMIT 3 OFFSET 2`
    class Limit {
        
        /// LIMIT 子句內容
        private var items: String = ""
        
        public required init() {}
    }
}

// MARK: - Limit
public extension WWSQLite3Manager.Limit {
    
    var sqlString: String { items }    // 轉成 SQL LIMIT 子句字串
}

// MARK: - Limit
public extension WWSQLite3Manager.Limit {
        
    /// 產生 LIMIT 條件
    ///
    /// - Note:
    ///   - `count` 代表最多回傳幾筆資料
    ///   - `offset` 代表查詢時要先略過幾筆資料
    ///   - SQLite 常見語法為 `LIMIT count OFFSET offset`
    ///
    /// - Parameters:
    ///   - count: 最多回傳的資料筆數
    ///   - offset: 要略過的資料筆數，預設為 0
    /// - Returns: 自身實例，方便鏈式呼叫
    @discardableResult
    func build(count: Int, offset: Int = 0) -> Self {
        
        let safeCount = max(0, count)
        let safeOffset = max(0, offset)
        
        items = "LIMIT \(safeCount) OFFSET \(safeOffset)"
        return self
    }
}
