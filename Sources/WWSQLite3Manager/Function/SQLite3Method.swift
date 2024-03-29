//
//  SQLite3Method.swift
//  WWSQLite3Manager
//
//  Created by William.Weng on 2023/2/21.
//

import Foundation

// MARK: - 常用的SQLite3函數
open class SQLite3Method: NSObject {}

// MARK: - 常用的Select函數
public extension SQLite3Method {
    
    // MARK: - SQL的常用函數 - Select
    enum SelectFunction {
        
        case `default`(_ key: String, _ type: SQLite3Condition.DataType, aliasName: String? = nil)      // 原始的一般欄位
        case count(_ key: String? = nil, _ type: SQLite3Condition.DataType, aliasName: String? = nil)   // 總數量
        case distinct(_ key: String, _ type: SQLite3Condition.DataType, aliasName: String? = nil)       // 未重複值
        case distinctCount(_ key: String, _ type: SQLite3Condition.DataType, aliasName: String? = nil)  // 未重複值的總數量
        case min(_ key: String, _ type: SQLite3Condition.DataType, aliasName: String? = nil)            // 最小值
        case max(_ key: String, _ type: SQLite3Condition.DataType, aliasName: String? = nil)            // 最大值
        case avg(_ key: String, _ type: SQLite3Condition.DataType, aliasName: String? = nil)            // 平均值
        case sum(_ key: String, _ type: SQLite3Condition.DataType, aliasName: String? = nil)            // 全部總和
        
        /// [產生SQL語句](https://ithelp.ithome.com.tw/articles/10208205)
        /// - Returns: [String](https://ithelp.ithome.com.tw/articles/10259378)
        func sql() -> String {
            
            var sql: String
            
            switch self {
            case .default(let key, _, _): sql = key
            case .count(let key, _, _): sql = "COUNT(*)"; if let key = key { sql = "COUNT(\(key))" }
            case .distinct(let key, _, _): sql = "DISTINCT(\(key))"
            case .distinctCount(let key, _, _): sql = "COUNT(DISTINCT(\(key)))"
            case .min(let key, _, _): sql = "MIN(\(key))"
            case .max(let key, _, _): sql = "MAX(\(key))"
            case .avg(let key, _, _): sql = "AVG(\(key))"
            case .sum(let key, _, _): sql = "SUM(\(key))"
            }
            
            sql += " as \(aliasName())"
            return sql
        }
        
        /// [取別名 => as <別名>](https://clay-atlas.com/blog/2019/11/20/sql-avg-count-sum-max-min/)
        /// - Parameter function: [SqlSelectFunction](https://data36.com/sql-functions-beginners-tutorial-ep3/)
        /// - Returns: [String](http://faculty.stust.edu.tw/~jehuang/oracle/ch4/4-10.htm)
        func aliasName() -> String {
            
            var aliasName: String
            
            switch self {
            case .default(let key, _, let _aliasName): aliasName = _aliasName ?? key
            case .count(let key, _, let _aliasName): aliasName = "Count"; if let key = key { aliasName = _aliasName ?? "\(key)Count" }
            case .distinct(let key, _, let _aliasName): aliasName = _aliasName ?? key
            case .distinctCount(let key, _, let _aliasName): aliasName = _aliasName ?? "\(key)DistinctCount"
            case .min(let key, _, let _aliasName): aliasName = _aliasName ?? "\(key)Min"
            case .max(let key, _, let _aliasName): aliasName = _aliasName ?? "\(key)Max"
            case .avg(let key, _, let _aliasName): aliasName = _aliasName ?? "\(key)Avg"
            case .sum(let key, _, let _aliasName): aliasName = _aliasName ?? "\(key)Sum"
            }
            
            return aliasName
        }
        
        /// 回傳資料型態
        /// - Returns: SQLite3Condition.DataType
        func dataType() -> SQLite3Condition.DataType {
            
            var dataType: SQLite3Condition.DataType
            
            switch self {
            case .default(_, let type, _): dataType = type
            case .count(_, let type, _): dataType = type
            case .distinct(_, let type, _): dataType = type
            case .distinctCount(_, let type, _): dataType = type
            case .min(_, let type, _): dataType = type
            case .max(_, let type, _): dataType = type
            case .avg(_, let type, _): dataType = type
            case .sum(_, let type, _): dataType = type
            }
            
            return dataType
        }
    }
}
