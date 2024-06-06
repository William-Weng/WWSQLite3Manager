//
//  SQLCondition.swift
//  WWSQLite3Manager
//
//  Created by William.Weng on 2022/1/12.
//
//  http://tw.gitbook.net/sqlite/sqlite_where_clause.html

import UIKit

// MARK: - Where主設定
open class SQLite3Condition: NSObject {
    
    /// [篩選條件](https://www.fooish.com/sql/where.html)
    public class Where: NSObject {
        
        var items: String = ""
        
        private let isNull = "IS NULL"
        private let isNotNull = "IS NOT NULL"
    }
    
    /// [分組條件](https://blog.csdn.net/HD243608836/article/details/88813269)
    public class GroupBy: NSObject {
        var items: String = ""
    }
    
    /// [篩選後的過濾條件](https://www.mysql.tw/2014/06/sqlwherehaving.html)
    public class Having: SQLite3Condition.Where {}
    
    /// [排序條件](https://ithelp.ithome.com.tw/articles/10217026)
    public class OrderBy: NSObject {
        var items: String = ""
    }
    
    /// [數量取得條件](https://www.runoob.com/sqlite/sqlite-limit-clause.html)
    public class Limit: NSObject {
        var items: String = ""
    }
}

// MARK: - typealias
public extension SQLite3Condition {
    
    typealias Attribute = (isNotNull: Bool, isNoCase: Bool, isUnique: Bool)
}

// MARK: - enum
public extension SQLite3Condition {
    
    /// 排序 => 小到大 / 大到小
    enum OrderByType {
        
        case ascending(key: String)
        case descending(key: String)
        
        /// SQL文字
        /// - Returns: String
        func symbol() -> String {
            
            switch self {
            case .ascending: return "ASC"
            case .descending: return "DESC"
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
    enum DataType: CustomStringConvertible {
        
        public var description: String { toString() }
        
        case INTEGER(attribute: Attribute = (false, false, false), defaultValue: Int? = nil)
        case TEXT(attribute: Attribute = (false, false, false), defaultValue: String? = nil)
        case BLOB(attribute: Attribute = (false, false, false), defaultValue: String? = nil)
        case REAL(attribute: Attribute = (false, false, false), defaultValue: Double? = nil)
        case NUMERIC(attribute: Attribute = (false, false, false), defaultValue: Double? = nil)
        case TIMESTAMP(defaultValue: String? = "CURRENT_TIMESTAMP")
    }
}
