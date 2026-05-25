//
//  Typealias.swift
//  WWSQLite3Manager
//
//  Created by William.Weng on 2026/5/20.
//

import Foundation

// MARK: - typealias
public extension WWSQLite3Manager {
    
    typealias SelectResult = (sql: String, array: [[String: Any]])
    typealias SelectDistinctResult = (sql: String, array: [Any])
    typealias InsertItem = (key: String, value: Any)
}

// MARK: - typealias
extension WWSQLite3Manager {
    
    typealias CompareType = (key: String, symbol: String, value: Any)   // 比較用符號 (height >= 10)
    typealias OrderType = (key: String, symbol: String)                 // 排序用符號 (height ASC)
}
