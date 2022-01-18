//
//  SQLite3Condition.DataType.swift
//  WWSQLite3Manager
//
//  Created by iOS on 2022/1/17.
//

import Foundation

// MARK: - DataType
public extension SQLite3Condition.DataType {
    
    /// .INTEGER => INTEGER / .TEXT => TEXT
    /// - Returns: String
    func toString() -> String {
        
        switch self {
        case .INTEGER: return "INTEGER"
        case .TEXT: return "TEXT"
        case .BLOB: return "BLOB"
        case .REAL: return "REAL"
        case .NUMERIC: return "NUMERIC"
        case .TIMESTAMP: return "TIMESTAMP"
        }
    }
    
    /// [轉成SQL語法](http://tw.gitbook.net/sqlite/sqlite_using_autoincrement.html)
    /// - number INTEGER DEFAULT 0 NOT NULL COLLATE NOCASE
    /// - Returns: [String](https://www.sqlite.org/datatype3.html)
    func toSQL() -> String {
        
        switch self {
        case .INTEGER(let attribute, let defaultValue): return sqlStringMaker(attribute: attribute, defaultValue: defaultValue)
        case .TEXT(let attribute, let defaultValue): return sqlStringMaker(attribute: attribute, defaultValue: defaultValue)
        case .BLOB(let attribute, let defaultValue): return sqlStringMaker(attribute: attribute, defaultValue: defaultValue)
        case .REAL(let attribute, let defaultValue): return sqlStringMaker(attribute: attribute, defaultValue: defaultValue)
        case .NUMERIC(let attribute, let defaultValue): return sqlStringMaker(attribute: attribute, defaultValue: defaultValue)
        case .TIMESTAMP(let defaultValue): return timestampString(defaultValue: defaultValue)
        }
    }
}

// MARK: - 小工具
private extension SQLite3Condition.DataType {
    
    /// 組成SQL字串
    /// - Parameters:
    ///   - attribute: SQLite3Condition.Attribute
    ///   - defaultValue: T?
    /// - Returns: String
    private func sqlStringMaker<T>(attribute: SQLite3Condition.Attribute, defaultValue: T?) -> String {
        
        var sql = self.toString()
        
        if let defaultValue = defaultValue { sql += " DEFAULT \(defaultValue)" }
        if (attribute.isNotNull) { sql += " NOT NULL" }
        if (attribute.isNoCase) { sql += " COLLATE NOCASE" }
        if (attribute.isUnique) { sql += " UNIQUE" }
        
        return sql
    }
    
    /// [組成TimeStamp字串](https://www.cnblogs.com/endv/p/12129481.html)
    /// - Parameters:
    ///   - defaultValue: String
    /// - Returns: String
    private func timestampString(defaultValue: String?) -> String {
        
        var sql = self.toString()
        if let defaultValue = defaultValue { sql += " DEFAULT \(defaultValue)" }
        
        return sql
    }
}

