//
//  GroupBy.swift
//  WWSQLite3Manager
//
//  Created by William.Weng on 2026/5/26.
//

import Foundation

public extension WWSQLite3Manager {
    
    /// [SQL GROUP BY 條件建構器](https://blog.csdn.net/HD243608836/article/details/88813269)
    ///
    /// 用來指定查詢結果的分組欄位
    class GroupBy {
        
        private var items: String = ""
        
        public required init() {}
    }
}

// MARK: - GroupBy
public extension WWSQLite3Manager.GroupBy {
    
    var sqlString: String { items }     // 轉成 SQL GROUP BY 子句字串
}

// MARK: - GroupBy
public extension WWSQLite3Manager.GroupBy {
    
    /// 產生 GROUP BY 條件
    ///
    /// - Parameters:
    ///   - keys: 要分組的欄位名稱陣列
    /// - Returns: 自身實例，方便鏈式呼叫
    @discardableResult
    func build(keys: [String]) -> Self {
        
        let validKeys = keys.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        
        guard !validKeys.isEmpty else { items = ""; return self }
        
        items = "GROUP BY " + validKeys.joined(separator: ", ")
        return self
    }
    
    /// 產生單一欄位的 GROUP BY 條件
    ///
    /// - Parameter key: 要分組的欄位名稱
    /// - Returns: 自身實例，方便鏈式呼叫
    @discardableResult
    func build(key: String) -> Self { build(keys: [key]) }
}
