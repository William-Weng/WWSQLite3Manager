//
//  Typealias.swift
//  WWSQLite3Manager
//
//  Created by William.Weng on 2026/5/20.
//

import Foundation

// MARK: - typealias
public extension WWSQLite3Manager {
    
    typealias SchemeColumn = (key: String, type: DataType)                      // 建立表格時的欄位 / 類型
    typealias SelectResult = (sql: String, array: [[String: Any]])              // 表示 SELECT 查詢的回傳結果 (SQL字串, 查詢結果)
    
    typealias InsertItem = (key: String, value: Any)                            // 表示一條插入資料的欄位與值對應 (欄位名稱, 要插入的值)
    
    typealias Attribute = (isNotNull: Bool, isNoCase: Bool, isUnique: Bool)     // 表示欄位的屬性描述 (是否不可為空, 是否忽略大小寫比對, 是否要求唯一)
    typealias CompareValue = (key: String, symbol: String, value: Any)          // 表示一個比較條件的三元素 (欄位名稱, 比較運算子字串, 比較值)
    typealias OrderType = (key: String, direction: SortDirection)               // 表示一個排序規則 (欄位名稱, 排序類型)
}
