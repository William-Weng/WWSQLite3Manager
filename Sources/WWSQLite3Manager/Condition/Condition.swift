//
//  File.swift
//  WWSQLite3Manager
//
//  Created by iOS on 2026/5/25.
//

import Foundation

// MARK: - TableScheme
public extension WWSQLite3Manager {
    
    struct Condition {}
}

// MARK: - typealias
extension WWSQLite3Manager.Condition {
    
    typealias Attribute = (isNotNull: Bool, isNoCase: Bool, isUnique: Bool)
}

// MARK: - enum
extension WWSQLite3Manager.Condition {
    
    /// 排序 => 小到大 / 大到小
    enum OrderByType {
        
        case ascending(key: String)
        case descending(key: String)
        case random
        
        /// SQL文字
        /// - Returns: String
        func symbol() -> String {
            
            switch self {
            case .ascending: return "ASC"
            case .descending: return "DESC"
            case .random: return "RANDOM()"
            }
        }
    }
    
    /// 大於 / 等於 / 小於
    enum CompareType {
        
        case equal(key: String, value: Any)
        case greaterThan(key: String, value: Any)
        case greaterOrEqual(key: String, value: Any)
        case lessThan(key: String, value: Any)
        case lessOrEqual(key: String, value: Any)
        case notEqual(key: String, value: Any)
        
        /// 運算符號
        /// - Returns: String
        func symbol() -> String {
            
            switch self {
            case .equal(_, _): return "="
            case .greaterThan(_, _): return ">"
            case .greaterOrEqual(_, _): return ">="
            case .lessThan(_, _): return "<"
            case .lessOrEqual(_, _): return "<="
            case .notEqual(_, _): return "!="
            }
        }
    }
    
    /// [SQLite3的資料類型](https://www.sqlite.org/datatype3.html)
    enum DataType {
                
        case INTEGER(attribute: Attribute = (false, false, false), defaultValue: Int? = nil)
        case TEXT(attribute: Attribute = (false, false, false), defaultValue: String? = nil)
        case BLOB(attribute: Attribute = (false, false, false), defaultValue: String? = nil)
        case REAL(attribute: Attribute = (false, false, false), defaultValue: Double? = nil)
        case NUMERIC(attribute: Attribute = (false, false, false), defaultValue: Double? = nil)
        case TIMESTAMP(defaultValue: String? = "CURRENT_TIMESTAMP")
    }
}
