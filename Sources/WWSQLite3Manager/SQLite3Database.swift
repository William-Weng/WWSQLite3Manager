//
//  SQLite3Database.swift
//  WWSQLite3Manager
//
//  Created by William.Weng on 2022/1/13.
//
/// SELECT word, count(word) as Count FROM English GROUP BY word HAVING Count > 3 ORDER BY Count DESC LIMIT 0, 10

import Foundation
import SQLite3

// MARK: - 執行資料庫的功能
public extension WWSQLite3Manager {
    
    struct Database {
        public let fileURL: URL
        public let database: OpaquePointer
    }
}

// MARK: - 直讀SQL
public extension WWSQLite3Manager.Database {
    
    /// [直讀SQL](https://www.1keydata.com/tw/sql/sqlcreate.html)
    ///
    /// CREATE TABLE IF NOT EXISTS students (id INTEGER DEFAULT 1, name TEXT, height REAL, image BLOB, time TEXT)
    ///
    /// - Parameter sql: [SQL語句](https://www.runoob.com/sql/sql-syntax.html)
    /// - Throws: [CustomError](https://www.w3school.com.cn/sql/sql_syntax.asp)
    func execute(sql: String) throws {
        let code = sqlite3_exec(database, sql.cString(using: .utf8), nil, nil, nil)
        guard code == SQLITE_OK else { throw makeError(.execute, code: code) }
    }
    
    /// [執行SQL語句 => 直讀SQL](https://www.1keydata.com/tw/sql/sql.html)
    ///
    /// INSERT INTO students ('name', 'height') VALUES ('William', '178.87') / UPDATE students SET name='小胖' WHERE id = 1
    ///
    /// - Parameter sql: [SQL語句](https://www.sqlitetutorial.net/)
    /// - Throws: CustomError
    func prepare(sql: String) throws {
        
        var statement: OpaquePointer? = nil
        defer { sqlite3_finalize(statement) }
        
        let prepareCode = sqlite3_prepare_v3(database, sql.cString(using: .utf8), -1, 0, &statement, nil)
        guard prepareCode == SQLITE_OK else { throw makeError(.prepare, code: prepareCode) }
        
        let stepCode = sqlite3_step(statement)
        guard stepCode == SQLITE_DONE else { throw makeError(.step, code: stepCode) }
    }
    
    /// [執行SELECT SQL](http://jengting.blogspot.com/2014/04/sql-where-having.html)
    ///
    /// SELECT * FROM students GROUP BY height, id HAVING height > 175
    ///
    /// - Parameters:
    ///   - sql: [String](http://sqlqna.blogspot.com/2018/03/havingif-else.html)
    ///   - result: ((OpaquePointer?) -> Void)
    /// - Throws: CustomError
    func select(sql: String, result: ((OpaquePointer?) -> Void)) throws {
        
        var statement: OpaquePointer? = nil
        defer { sqlite3_finalize(statement) }
        
        let prepareCode = sqlite3_prepare_v3(database, sql.cString(using: .utf8), -1, 0, &statement, nil)
        guard prepareCode == SQLITE_OK else { throw makeError(.prepare, code: prepareCode) }
        
        while true {
            
            let stepCode = sqlite3_step(statement)
            
            switch stepCode {
            case SQLITE_ROW: result(statement)
            case SQLITE_DONE: return
            default: throw makeError(.step, code: stepCode)
            }
        }
    }
    
    /// [關閉SQLite連線](https://www.sqlite.org/c3ref/close.html)
    /// - Throws: CustomError
    func close() throws {
        
        let code = sqlite3_close_v2(database)
        guard code == SQLITE_OK else { throw makeError(.close, code: code) }
    }
}

// MARK: - 公開的function
public extension WWSQLite3Manager.Database {

    /// 取得該Table的結構組成
    /// - PRAGMA TABLE_INFO(students)
    /// - Parameter tableName: String
    /// - Returns: SelectResult
    func tableScheme(tableName: String) -> WWSQLite3Manager.SelectResult {
        return tableInfomation(tableName: tableName, type: WWSQLite3Manager.TableScheme.self)
    }
    
    /// [建立資料表](https://www.sqlitetutorial.net/sqlite-create-table/)
    /// - CREATE TABLE IF NOT EXISTS "students" ("id" INTEGER DEFAULT 1, "name" TEXT, "height" REAL, "image" BLOB, "time" TEXT, PRIMARY KEY ("id"))
    /// - Parameters:
    ///   - tableName: 資料表名稱
    ///   - type: 資料表結構定義型別
    ///   - primaryKeys: 主鍵欄位名稱陣列，可用於單一主鍵或複合主鍵
    ///   - ifNotExists: 是否只在資料表不存在時才建立；`true` 時使用 `CREATE TABLE IF NOT EXISTS`
    /// - Throws: `WWSQLite3Manager.CustomError`
    /// - Returns: 最終執行的 SQL 字串。
    /// - Note:
    ///   - `type.structure()` 應回傳欄位名稱與對應 SQLite 型別。
    ///   - 若 `primaryKeys` 為空，預設會嘗試使用第一個欄位作為主鍵。
    ///   - 若有多個主鍵欄位，會建立複合主鍵，例如 `PRIMARY KEY ("id", "name")`。
    @discardableResult
    func create(tableName: String, type: WWSQLite3Manager.SchemeDelegate.Type, primaryKeys: [String?] = [], ifNotExists: Bool = false) throws -> String {
        
        let fields = type.structure().map { key, type in "\(key.sqlIdentifier()) \(type.toSQL())" }.joined(separator: ", ")
        let keys = primaryKeys.isEmpty ? [type.structure().first?.key] : primaryKeys
        let name = tableName.sqlIdentifier()
        
        var sql = (!ifNotExists) ? "CREATE TABLE \(name) (\(fields)" : "CREATE TABLE IF NOT EXISTS \(name) (\(fields)"
        
        if let primaryKey = type.primaryKeys(keys) { sql += ", \(primaryKey)" }
        sql += ")"
        
        try execute(sql: sql)
        return sql
    }
    
    /// [刪除資料表](https://www.sqlitetutorial.net/sqlite-drop-table/)
    /// - Parameters:
    ///   - tableName: 資料表名稱
    ///   - ifExists: 是否只在資料表存在時才刪除；`true` 時可避免資料表不存在時發生錯誤。
    /// - Throws: CustomError
    /// - Returns: 最終執行的 SQL
    @discardableResult
    func drop(tableName: String, ifExists: Bool = false) throws -> String {
        
        let name = tableName.sqlIdentifier()
        let sql = (!ifExists) ? "DROP TABLE \(name)" : "DROP TABLE IF EXISTS \(name)"
        
        try execute(sql: sql)
        return sql
    }
    
    /// [事務處理](https://www.itread01.com/p/398053.html)
    /// - Parameter type: TransactionType
    /// - Returns: Bool
    @discardableResult
    func transaction(type: WWSQLite3Manager.TransactionType) throws -> String {
        
        let sql = "\(type.rawValue) TRANSACTION"
        try execute(sql: sql)
        
        return sql
    }
}

// MARK: - CRUD
public extension WWSQLite3Manager.Database {

    /// [插入資料](https://www.1keydata.com/tw/sql/sqlinsert.html)
    ///
    /// NSERT INTO students ('name', 'height') VALUES ('William', '178.87'), ('Curry', '196.38')
    ///
    /// - Parameters:
    ///   - tableName: [String](https://www.fooish.com/sql/insert-into.html)
    ///   - itemsArray: [[InsertItem]]
    /// - Throws: CustomError
    /// - Returns: String
    @discardableResult
    func insert(tableName: String, itemsArray: [[WWSQLite3Manager.InsertItem]]) throws -> String {
                
        guard let keys = itemsArray.first?.map({ $0.key }).joined(separator: ", ") else { throw WWSQLite3Manager.CustomError.missingItems }
        
        let values = itemsArray.map { items -> String in
            let values = items.map({ "'\($1)'" }).joined(separator: ", ")
            return "(\(values))"
        }.joined(separator: ", ")
        
        let sql = "INSERT INTO \(tableName) (\(keys)) VALUES \(values)"
        let isSuccess = try prepare(sql: sql)
        
        return sql
    }
    
    /// [更新資料](https://www.1keydata.com/tw/sql/sqlupdate.html)
    /// - UPDATE students SET name='小胖' WHERE id = 1
    /// - Parameters:
    ///   - tableName: String
    ///   - items: [String: String]
    ///   - whereConditions: SQLite3Condition.Where?
    /// - Throws: CustomError
    /// - Returns: String
    @discardableResult
    func update(tableName: String, items: [WWSQLite3Manager.InsertItem], where whereConditions: WWSQLite3Manager.Condition.Where?) throws -> String {
        
        let _items = items.map { "\($0) = '\($1)'" }.joined(separator: ", ")
        var sql = "UPDATE \(tableName) SET \(_items)"
        
        if let whereConditions = whereConditions { sql += " WHERE\(whereConditions.items)" }
        let isSuccess = try prepare(sql: sql)
        
        return sql
    }
    
    /// [刪除資料](https://www.1keydata.com/tw/sql/sqldelete.html)
    /// - DELETE FROM students WHERE id = 1
    /// - Parameters:
    ///   - tableName: String
    ///   - whereConditions: SQLite3Condition.Where
    /// - Throws: CustomError
    /// - Returns: ExecuteResult
    @discardableResult
    func delete(tableName: String, where whereConditions: WWSQLite3Manager.Condition.Where?) throws -> String {
        
        var sql = "DELETE FROM \(tableName)"
        
        if let whereConditions = whereConditions { sql += " WHERE\(whereConditions.items)" }
        try prepare(sql: sql)
        
        return sql
    }
    
    /// [查詢資訊](https://www.1keydata.com/tw/sql/sqlselect.html)
    /// - SELECT * FROM students WHERE id = 1
    /// - Parameters:
    ///   - tableName: String
    ///   - type: SchemeDelegate.Type
    ///   - whereConditions: Where語句
    ///   - groupByConditions: GroupBy語句
    ///   - havingConditions: HAVING語句
    ///   - orderByConditions: OrderBy語句
    ///   - limitConditions: Limit語句
    /// - Returns: SelectResult
    func select(tableName: String, type: WWSQLite3Manager.SchemeDelegate.Type, where whereConditions: WWSQLite3Manager.Condition.Where? = nil, groupBy groupByConditions: WWSQLite3Manager.Condition.GroupBy? = nil, having havingConditions: WWSQLite3Manager.Condition.Having? = nil, orderBy orderByConditions: WWSQLite3Manager.Condition.OrderBy? = nil, limit limitConditions: WWSQLite3Manager.Condition.Limit? = nil) -> WWSQLite3Manager.SelectResult {
        
        let fields = type.structure().map { $0.key }.joined(separator: ", ")
        
        var sql = "SELECT \(fields) FROM \(tableName)"
        var statement: OpaquePointer? = nil
        var array: [[String : Any]] = []
        
        if let _whereConditions = whereConditions { sql += " WHERE\(_whereConditions.items)" }
        if let _groupByConditions = groupByConditions { sql += " GROUP BY \(_groupByConditions.items)" }
        if let _havingConditions = havingConditions { sql += " HAVING\(_havingConditions.items)" }
        if let _orderByConditions = orderByConditions { sql += " ORDER BY \(_orderByConditions.items)" }
        if let _limitConditions = limitConditions { sql += " \(_limitConditions.items)" }
        
        defer { sqlite3_finalize(statement) }
        
        sqlite3_prepare_v3(database, sql.cString(using: .utf8), -1, 0, &statement, nil)

        while sqlite3_step(statement) == SQLITE_ROW {
            
            var dict: [String : Any] = [:]
            
            type.structure()._forEach { (index, paramater, _) in
                dict[paramater.key] = statement?._value(at: Int32(index), dataType: paramater.type) ?? nil
            }
            
            array.append(dict)
        }
        
        return (sql, array)
    }
    
    /// [搜尋資料 with functions](https://www.fooish.com/sql/count-function.html)
    /// - Parameters:
    ///   - tableName: [資料庫](https://www.1keydata.com/tw/sql/sqldistinct.html)
    ///   - functions: [常用函數]
    ///   - whereConditions: Where語句
    ///   - groupByConditions: GroupBy語句
    ///   - havingConditions: HAVING語句
    ///   - orderByConditions: OrderBy語句
    ///   - limitConditions: Limit語句
    /// - Returns: SelectResult
    func select(tableName: String, functions: [SQLite3Method.SelectFunction] = [], where whereConditions: WWSQLite3Manager.Condition.Where? = nil, groupBy groupByConditions: WWSQLite3Manager.Condition.GroupBy? = nil, having havingConditions: WWSQLite3Manager.Condition.Having? = nil, orderBy orderByConditions: WWSQLite3Manager.Condition.OrderBy? = nil, limit limitConditions: WWSQLite3Manager.Condition.Limit? = nil) -> WWSQLite3Manager.SelectResult {
        
        var sql = "SELECT * FROM \(tableName)"
        
        if !functions.isEmpty {
            let funcs = functions.map { $0.sql() }.joined(separator: ", ")
            sql = "SELECT \(funcs) FROM \(tableName)"
        }
        
        var statement: OpaquePointer? = nil
        var array: [[String : Any]] = []
        
        if let _whereConditions = whereConditions { sql += " WHERE\(_whereConditions.items)" }
        if let _groupByConditions = groupByConditions { sql += " GROUP BY \(_groupByConditions.items)" }
        if let _havingConditions = havingConditions { sql += " HAVING\(_havingConditions.items)" }
        if let _orderByConditions = orderByConditions { sql += " ORDER BY \(_orderByConditions.items)" }
        if let _limitConditions = limitConditions { sql += " \(_limitConditions.items)" }
        
        defer { sqlite3_finalize(statement) }
        
        sqlite3_prepare_v3(database, sql.cString(using: .utf8), -1, 0, &statement, nil)
        
        while sqlite3_step(statement) == SQLITE_ROW {
            
            var dict: [String : Any] = [:]
            
            for (index, function) in functions.enumerated() {
                dict[function.aliasName()] = statement?._value(at: Int32(index), dataType: function.dataType()) ?? nil
            }
            
            array.append(dict)
        }
        
        return (sql, array)
    }
}

// MARK: - 小工具
private extension WWSQLite3Manager.Database {
    
    /// [取得該Table的結構組成](https://stackoverflow.com/questions/39824274/sqlite-pragma-table-infotable-not-returning-column-names-using-data-sqlite-in)
    /// - Parameters:
    ///   - tableName: String
    ///   - type: SchemeDelegate.Type
    /// - Returns: SelectResult
    func tableInfomation(tableName: String, type: WWSQLite3Manager.SchemeDelegate.Type) -> WWSQLite3Manager.SelectResult {
        
        let sql = "PRAGMA TABLE_INFO(\(tableName))"
        
        var statement: OpaquePointer? = nil
        var array: [[String : Any]] = []
        
        defer { sqlite3_finalize(statement) }
        
        sqlite3_prepare_v2(database, sql.cString(using: .utf8), -1, &statement, nil)
        
        while sqlite3_step(statement) == SQLITE_ROW {
            
            var dict: [String : Any] = [:]
            
            type.structure()._forEach { (index, paramater, _) in
                dict[paramater.key] = statement?._value(at: Int32(index), dataType: paramater.type) ?? nil
            }
            
            array.append(dict)
        }
        
        return (sql, array)
    }
    
    /// 將值轉成 SQLite 可用的字串
    /// - Parameter value: 任意型別的欄位值
    /// - Returns: 可直接拼接到 SQL 的字串
    func sqlValue(_ value: Any?) -> String {
        
        guard let value else { return "NULL" }
        
        switch value {
        
        /* Bool */
        case let bool as Bool: return bool ? "1" : "0"
            
        /* SignedInteger */
        case let number as Int: return "\(number)"
        case let number as Int8: return "\(number)"
        case let number as Int16: return "\(number)"
        case let number as Int32: return "\(number)"
        case let number as Int64: return "\(number)"
            
        /* UnsignedInteger */
        case let number as UInt: return "\(number)"
        case let number as UInt8: return "\(number)"
        case let number as UInt16: return "\(number)"
        case let number as UInt32: return "\(number)"
        case let number as UInt64: return "\(number)"
            
        /* BinaryFloatingPoint */
        case let number as Float: return "\(number)"
        case let number as Double: return "\(number)"
            
        /* String */
        case let text as String:
            let escaped = text.replacingOccurrences(of: "'", with: "''")
            return "'\(escaped)'"
            
        default:
            let escaped = "\(value)".replacingOccurrences(of: "'", with: "''")
            return "'\(escaped)'"
        }
    }
    
    /// 建立 SQLite 錯誤
    /// - Parameters:
    ///   - operation: 發生錯誤的 SQLite 操作階段。
    ///   - code: SQLite 回傳的錯誤碼。
    /// - Returns: `WWSQLite3Manager.CustomError`
    func makeError(_ operation: WWSQLite3Manager.Operation, code: Int32) -> WWSQLite3Manager.CustomError {
        
        let message = sqlite3_errmsg(database).flatMap { String(cString: $0) } ?? "No SQLite error message."
        return .sqlite(operation: operation, code: code, message: message)
    }
}
