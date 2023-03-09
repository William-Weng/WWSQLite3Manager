//
//  SQLite3Condition+GroupBy.swift
//  
//
//  Created by William.Weng on 2023/3/9.
//

// MARK: - OrderBy
public extension SQLite3Condition.GroupBy {
    
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
