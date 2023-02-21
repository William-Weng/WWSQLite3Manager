//
//  SQLite3Database.swift
//  WWSQLite3Manager
//
//  Created by William.Weng on 2022/1/13.
//

import Foundation
import SQLite3

// MARK: - 執行資料庫的功能
public struct SQLite3Database {
    
    public enum TransactionType: String {
        case begin = "BEGIN"
        case commit = "COMMIT"
        case rollback = "ROLLBACK"
    }
    
    public typealias ExecuteResult = (sql: String, isSussess: Bool)
    public typealias SelectResult = (sql: String, array: [[String: Any]])
    public typealias SelectDistinctResult = (sql: String, array: [Any])
    public typealias InsertItem = (key: String, value: Any)
    
    public let fileURL: URL
    public let database: OpaquePointer
}

// MARK: - 直讀SQL
public extension SQLite3Database {
    
    /// [直讀SQL](https://www.1keydata.com/tw/sql/sqlcreate.html)
    /// - CREATE TABLE IF NOT EXISTS students (id INTEGER DEFAULT 1, name TEXT, height REAL, image BLOB, time TEXT)
    /// - Parameter sql: [SQL語句](https://www.runoob.com/sql/sql-syntax.html)
    /// - Returns: [Bool](https://www.w3school.com.cn/sql/sql_syntax.asp)
    func execute(sql: String) -> Bool {
        return sqlite3_exec(database, sql.cString(using: .utf8), nil, nil, nil) == SQLITE_OK
    }
        
    /// [執行SQL語句 => 直讀SQL](https://www.1keydata.com/tw/sql/sql.html)
    /// - INSERT INTO students ('name', 'height') VALUES ('William', '178.87') / UPDATE students SET name='小胖' WHERE id = 1
    /// - Parameter sql: [SQL語句](https://www.sqlitetutorial.net/)
    /// - Returns: Bool
    func prepare(sql: String) -> Bool {
        
        var statement: OpaquePointer? = nil
        
        defer { sqlite3_finalize(statement) }
        
        if (sqlite3_prepare_v3(database, sql.cString(using: .utf8), -1, 0, &statement, nil) == SQLITE_OK) {
            if (sqlite3_step(statement) == SQLITE_DONE) { return true }
        }
        
        return false
    }
    
    /// [執行SELECT SQL](http://jengting.blogspot.com/2014/04/sql-where-having.html)
    /// - SELECT * FROM students GROUP BY height, id HAVING height > 175
    /// - Parameters:
    ///   - sql: [String](http://sqlqna.blogspot.com/2018/03/havingif-else.html)
    ///   - result: ((OpaquePointer?) -> Void)
    ///   - completion: ((Bool) -> Void))
    func select(sql: String, result: ((OpaquePointer?) -> Void), completion: ((Bool) -> Void)) {
        
        var statement: OpaquePointer? = nil
        defer { completion(true); sqlite3_finalize(statement) }
        
        sqlite3_prepare_v3(database, sql.cString(using: .utf8), -1, 0, &statement, nil)
        while sqlite3_step(statement) == SQLITE_ROW { result(statement) }
    }
    
    /// [關閉SQLite連線](https://www.sqlite.org/c3ref/close.html)
    /// - Returns: Bool
    func close() -> Bool { return sqlite3_close_v2(database) == SQLITE_OK }
}

// MARK: - 公開的function
public extension SQLite3Database {
    
    /// 取得該Table的結構組成
    /// - PRAGMA TABLE_INFO(students)
    /// - Parameter tableName: String
    /// - Returns: SelectResult
    func tableScheme(tableName: String) -> SelectResult {
        return tableInfomation(tableName: tableName, type: SQLite3TableSchemeInfomation.self)
    }
    
    /// [建立Table](http://tw.gitbook.net/sqlite/sqlite_create_table.html)
    /// - CREATE TABLE IF NOT EXISTS students (id INTEGER DEFAULT 1, name TEXT, height REAL, image BLOB, time TEXT)
    /// - Parameters:
    ///   - tableName: [String](https://www.1keydata.com/tw/sql/sqlcreate.html)
    ///   - type: [SQLite3SchemeDelegate.Type](https://www.runoob.com/sql/sql-syntax.html)
    ///   - isOverwrite: [Bool - 是否要覆蓋過去？](https://www.w3school.com.cn/sql/sql_syntax.asp)
    /// - Returns: ExecuteResult
    func create(tableName: String, type: SQLite3SchemeDelegate.Type, isOverwrite: Bool = false) -> ExecuteResult {
        
        let fields = type.structure().map { (key, type) in return "\(key) \(type.toSQL())" }.joined(separator: ", ")
        var sql: String = (!isOverwrite) ? "CREATE TABLE \(tableName) (\(fields)" : "CREATE TABLE IF NOT EXISTS \(tableName) (\(fields)"
        
        if let primaryKey = type.primaryKey(type.structure().first?.key) { sql += ", \(primaryKey)" }
        sql += ")"
        
        let isSuccess = execute(sql: sql)
        return (sql, isSuccess)
    }
    
    /// [刪除Table](https://www.sqlitetutorial.net/sqlite-drop-table/)
    /// - Parameters:
    ///   - tableName: String
    ///   - isOverwrite: [Bool - 是否要覆蓋過去？](https://www.runoob.com/sqlite/sqlite-drop-table.html)
    /// - Returns: ExecuteResult
    func drop(tableName: String, isOverwrite: Bool = false) -> ExecuteResult {
        
        let sql: String = (!isOverwrite) ? "DROP TABLE \(tableName)" : "DROP TABLE IF NOT EXISTS \(tableName)"
        let isSuccess = execute(sql: sql)
        
        return (sql, isSuccess)
    }
    
    /// [事務處理](https://www.itread01.com/p/398053.html)
    /// - Parameter type: TransactionType
    /// - Returns: Bool
    func transaction(type: TransactionType) -> ExecuteResult {

        let sql = "\(type.rawValue) TRANSACTION"
        let isSuccess = execute(sql: sql)
        
        return (sql, isSuccess)
    }
}

// MARK: - CRUD
public extension SQLite3Database {
        
    /// [插入資料](https://www.1keydata.com/tw/sql/sqlinsert.html)
    /// - INSERT INTO students ('name', 'height') VALUES ('William', '178.87'), ('Curry', '196.38')
    /// - Parameters:
    ///   - tableName: [String](https://www.fooish.com/sql/insert-into.html)
    ///   - itemsArray: [[InsertItem]]
    /// - Returns: ExecuteResult?
    func insert(tableName: String, itemsArray: [[InsertItem]]) -> ExecuteResult? {
        
        guard let keys = itemsArray.first?.map({ $0.key }).joined(separator: ", ") else { return nil }
        
        let values = itemsArray.map { items -> String in
            let values = items.map({ "'\($1)'" }).joined(separator: ", ")
            return "(\(values))"
        }.joined(separator: ", ")
        
        let sql = "INSERT INTO \(tableName) (\(keys)) VALUES \(values)"
        let isSuccess = prepare(sql: sql)
        
        return (sql, isSuccess)
    }
    
    /// [更新資料](https://www.1keydata.com/tw/sql/sqlupdate.html)
    /// - UPDATE students SET name='小胖' WHERE id = 1
    /// - Parameters:
    ///   - tableName: String
    ///   - items: [String: String]
    ///   - whereConditions: SQLite3Condition.Where?
    /// - Returns: ExecuteResult
    func update(tableName: String, items: [InsertItem], where whereConditions: SQLite3Condition.Where?) -> ExecuteResult {
        
        let _items = items.map { "\($0) = '\($1)'" }.joined(separator: ", ")
        var sql = "UPDATE \(tableName) SET \(_items)"
        
        if let whereConditions = whereConditions { sql += " WHERE\(whereConditions.items)" }
        let isSuccess = prepare(sql: sql)
        
        return (sql, isSuccess)
    }
    
    /// [刪除資料](https://www.1keydata.com/tw/sql/sqldelete.html)
    /// - DELETE FROM students WHERE id = 1
    /// - Parameters:
    ///   - tableName: String
    ///   - whereConditions: SQLite3Condition.Where
    /// - Returns: ExecuteResult
    func delete(tableName: String, where whereConditions: SQLite3Condition.Where?) -> ExecuteResult {
        
        var sql = "DELETE FROM \(tableName)"
        if let whereConditions = whereConditions { sql += " WHERE\(whereConditions.items)" }
        
        let isSuccess = prepare(sql: sql)
        
        return (sql, isSuccess)
    }
    
    /// [查詢資訊](https://www.1keydata.com/tw/sql/sqlselect.html)
    /// - SELECT * FROM students WHERE id = 1
    /// - Parameters:
    ///   - tableName: String
    ///   - type: SQLite3SchemeDelegate.Type
    ///   - whereConditions: SQLCondition.Where?
    ///   - orderByConditions: SQLite3Condition.OrderBy?
    ///   - limit: SQLite3Condition.Limit?
    /// - Returns: SelectResult
    func select(tableName: String, type: SQLite3SchemeDelegate.Type, where whereConditions: SQLite3Condition.Where? = nil, orderBy orderByConditions: SQLite3Condition.OrderBy? = nil, limit limitConditions: SQLite3Condition.Limit? = nil) -> SelectResult {
        
        let fields = type.structure().map { $0.key }.joined(separator: ", ")
        
        var sql = "SELECT \(fields) FROM \(tableName)"
        var statement: OpaquePointer? = nil
        var array: [[String : Any]] = []
        
        if let _whereConditions = whereConditions { sql += " WHERE\(_whereConditions.items)" }
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
    
    /// [搜尋欄位數量](https://www.fooish.com/sql/count-function.html)
    /// - Parameters:
    ///   - tableName: String
    ///   - function: SQLite3Function.Count.Function
    ///   - whereConditions: SQLite3Condition.Where?
    ///   - orderByConditions: SQLite3Condition.OrderBy?
    ///   - limitConditions: SQLite3Condition.Limit?
    /// - Returns: SelectResult?
    func selectCount(tableName: String, function: SQLite3Function.Count.Function = .all, where whereConditions: SQLite3Condition.Where? = nil, orderBy orderByConditions: SQLite3Condition.OrderBy? = nil, limit limitConditions: SQLite3Condition.Limit? = nil) -> SelectResult {
        
        var sql = "SELECT \(function.sql()) FROM \(tableName)"
        var statement: OpaquePointer? = nil
        var array: [[String : Any]] = []
        
        if let _whereConditions = whereConditions { sql += " WHERE\(_whereConditions.items)" }
        if let _orderByConditions = orderByConditions { sql += " ORDER BY \(_orderByConditions.items)" }
        if let _limitConditions = limitConditions { sql += " \(_limitConditions.items)" }
        
        defer { sqlite3_finalize(statement) }
        
        sqlite3_prepare_v3(database, sql.cString(using: .utf8), -1, 0, &statement, nil)
        
        while sqlite3_step(statement) == SQLITE_ROW {
            
            var dict: [String : Any] = [:]
            
            switch function {
            case .all: dict["Count"] = statement?._value(at: 0, dataType: .INTEGER())
            case .fields(let _fields), .distinct(let _fields):
                
                for (index, field) in _fields.enumerated() {
                    let aliasName = function.aliasName(with: field)
                    dict[aliasName] = statement?._value(at: Int32(index), dataType: .INTEGER()) ?? nil
                }
            }
            
            array.append(dict)
        }
        
        return (sql, array)
    }
    
    /// [搜尋未重複的欄位資料](https://www.1keydata.com/tw/sql/sqldistinct.html)
    /// - Parameters:
    ///   - tableName: String
    ///   - info: (key: String, type: SQLite3Condition.DataType)
    ///   - whereConditions: SQLite3Condition.Where?
    ///   - orderByConditions: SQLite3Condition.OrderBy?
    ///   - limitConditions: SQLite3Condition.Limit?
    /// - Returns: SelectResult?
    func selectDistinct(tableName: String, info: (key: String, type: SQLite3Condition.DataType), where whereConditions: SQLite3Condition.Where? = nil, orderBy orderByConditions: SQLite3Condition.OrderBy? = nil, limit limitConditions: SQLite3Condition.Limit? = nil) -> SelectDistinctResult {
        
        var sql = "SELECT DISTINCT(\(info.key)) FROM \(tableName)"
        var statement: OpaquePointer? = nil
        var array: [Any] = []
        
        if let _whereConditions = whereConditions { sql += " WHERE\(_whereConditions.items)" }
        if let _orderByConditions = orderByConditions { sql += " ORDER BY \(_orderByConditions.items)" }
        if let _limitConditions = limitConditions { sql += " \(_limitConditions.items)" }
        
        defer { sqlite3_finalize(statement) }
        
        sqlite3_prepare_v3(database, sql.cString(using: .utf8), -1, 0, &statement, nil)
        
        while sqlite3_step(statement) == SQLITE_ROW {
            if let value = statement?._value(at: 0, dataType: info.type) { array.append(value) }
        }
        
        return (sql, array)
    }
}

// MARK: - 小工具
private extension SQLite3Database {
    
    /// [取得該Table的結構組成](https://stackoverflow.com/questions/39824274/sqlite-pragma-table-infotable-not-returning-column-names-using-data-sqlite-in)
    /// - Parameters:
    ///   - tableName: String
    ///   - type: SQLite3SchemeDelegate.Type
    /// - Returns: SelectResult
    func tableInfomation(tableName: String, type: SQLite3SchemeDelegate.Type) -> SelectResult {
        
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
}
