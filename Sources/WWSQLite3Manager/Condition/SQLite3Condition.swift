//
//  SQLCondition.swift
//  WWSQLite3Manager
//
//  Created by William.Weng on 2022/1/12.
//
//  http://tw.gitbook.net/sqlite/sqlite_where_clause.html

import UIKit

open class SQLite3Condition: NSObject {
    
    public typealias Attribute = (isNotNull: Bool, isNoCase: Bool, isUnique: Bool)

    /// 排序 => 小到大 / 大到小
    public enum OrderByType: String {
        case ascending = "ASC"
        case descending = "DESC"
    }
    
    /// 大於 / 等於 / 小於
    public enum CompareType: String {
        case equal = "="
        case greaterThan = ">"
        case greaterOrEqual = ">="
        case lessThan = "<"
        case lessOrEqual = "<="
    }
    
    /// [SQLite3的資料類型](https://www.sqlite.org/datatype3.html)
    public enum DataType: CustomStringConvertible {
        
        public var description: String { toString() }
        
        case INTEGER(attribute: Attribute = (false, false, false), defaultValue: Int? = nil)
        case TEXT(attribute: Attribute = (false, false, false), defaultValue: String? = nil)
        case BLOB(attribute: Attribute = (false, false, false), defaultValue: String? = nil)
        case REAL(attribute: Attribute = (false, false, false), defaultValue: Double? = nil)
        case NUMERIC(attribute: Attribute = (false, false, false), defaultValue: Double? = nil)
        case TIMESTAMP(defaultValue: String = "CURRENT_TIMESTAMP")
    }
    
    /// [篩選條件](https://www.fooish.com/sql/where.html)
    public class Where: NSObject {
        
        var items: String = ""
        
        private let isNull = "IS NULL"
        private let isNotNull = "IS NOT NULL"
    }
    
    /// [排序條件](https://ithelp.ithome.com.tw/articles/10217026)
    public class OrderBy: NSObject {
        var items: String = ""
    }
}
