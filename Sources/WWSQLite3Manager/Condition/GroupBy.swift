//
//  File.swift
//  WWSQLite3Manager
//
//  Created by iOS on 2026/5/25.
//

import Foundation

public extension WWSQLite3Manager {
        
    /// [分組條件](https://blog.csdn.net/HD243608836/article/details/88813269)
    public class GroupBy: NSObject {
        var items: String = ""
    }
}

// MARK: - OrderBy
public extension WWSQLite3Manager.GroupBy {
    
    /// 組成排序用字串
    /// - Parameters:
    ///   - key: String
    ///   - type: SQLite3Condition.OrderByType
    /// - Returns: Self
    func item(key: String) -> Self {
        self.items += "\(key)"
        return self
    }
    
    /// 組成排序用字串
    /// - Parameters:
    ///   - key: String
    /// - Returns: Self
    func addItem(key: String) -> Self {
        self.items += ", \(key)"
        return self
    }
}
