//
//  SQLite3Database.swift
//  WWSQLite3Manager
//
//  Created by William.Weng on 2022/1/13.
//
/// SELECT word, count(word) as Count FROM English GROUP BY word HAVING Count > 3 ORDER BY Count DESC LIMIT 0, 10

import Foundation
import SQLite3

// MARK: - 資料庫
public extension WWSQLite3Manager {
    
    /// 已開啟的 SQLite 資料庫連線資訊
    ///
    /// 封裝資料庫檔案位置與底層 SQLite connection handle，可用來描述目前已建立的資料庫連線狀態。
    struct Database {
        
        public let fileURL: URL                 // 資料庫檔案位置
        public let database: OpaquePointer      // SQLite 資料庫連線物件
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
        
        let prepareCode = sql.withCString { cString in sqlite3_prepare_v3(database, cString, -1, 0, &statement, nil) }
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
    func query(sql: String, result: ((OpaquePointer?) -> Void)) throws {
        
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

// MARK: - 公開函式
public extension WWSQLite3Manager.Database {
    
    /// 取得該Table的結構組成
    /// - PRAGMA TABLE_INFO(students)
    /// - Parameter tableName: String
    /// - Returns: SelectResult
    func scheme(tableName: String) -> WWSQLite3Manager.SelectResult {
        return tableInformation(tableName: tableName, type: WWSQLite3Manager.TableScheme.self)
    }
    
    /// 取得全資料表資訊
    /// - Returns: SelectResult
    func tables() -> WWSQLite3Manager.SelectResult {
        let `where`: WWSQLite3Manager.Where = .init().compare("type", .equal, .text("table"))
        return select(tableName: "sqlite_master", type: WWSQLite3Manager.SqliteMaster.self, where: `where`)
    }
    
    /// [建立資料表](https://www.sqlitetutorial.net/sqlite-create-table/)
    /// - CREATE TABLE IF NOT EXISTS "students" ("id" INTEGER DEFAULT 1, "name" TEXT, "height" REAL, "image" BLOB, "time" TEXT, PRIMARY KEY ("id"))
    /// - Parameters:
    ///   - tableName: [資料表名稱](https://www.1keydata.com/tw/sql/sql-primary-key.html)
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
        let primaryKeySQL = makePrimaryKeySQL(type: type, primaryKeys: primaryKeys)
        let definitions = [fields, primaryKeySQL].compactMap { $0 }.joined(separator: ", ")
        let name = tableName.sqlIdentifier()
        
        let sql = ifNotExists ? "CREATE TABLE IF NOT EXISTS \(name) (\(definitions))" : "CREATE TABLE \(name) (\(definitions))"
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
    
    /// 重新命名資料表
    ///
    /// 產生 `ALTER TABLE ... RENAME TO ...` SQL 語句，將既有資料表重新命名。
    ///
    /// - Note:
    ///   - 舊資料表名稱與新資料表名稱都會自動轉成 SQL identifier 格式
    ///   - 此操作只改變資料表名稱，不會變更表內資料
    ///
    /// - Parameters:
    ///   - tableName: 原始資料表名稱
    ///   - newTableName: 新的資料表名稱
    /// - Returns:
    ///   實際執行的 SQL 字串
    /// - Throws:
    ///   若 SQL 執行失敗，拋出對應錯誤
    @discardableResult
    func rename(tableName: String, newTableName: String) throws -> String {
        
        let sourceName = tableName.sqlIdentifier()
        let targetName = newTableName.sqlIdentifier()
        
        let sql = "ALTER TABLE \(sourceName) RENAME TO \(targetName)"
        try execute(sql: sql)
        
        return sql
    }
}

// MARK: - 事務處理
public extension WWSQLite3Manager.Database {
    
    /// [開始交易](https://www.itread01.com/p/398053.html)
    ///
    /// 依照指定的交易模式執行 `BEGIN ... TRANSACTION`，
    /// 用來建立一個新的 SQLite transaction。
    ///
    /// - Note:
    ///   - `type` 可指定 `DEFERRED`、`IMMEDIATE` 或 `EXCLUSIVE` 模式
    ///   - `DEFERRED` 為 SQLite 的預設交易模式
    ///   - 若目前已有尚未結束的 transaction，再次呼叫 `BEGIN` 可能會失敗
    ///
    /// - Parameter type: 交易開始模式
    /// - Returns:
    ///   實際執行的 SQL 字串
    /// - Throws:
    ///   若 SQL 執行失敗，拋出對應錯誤
    @discardableResult
    func begin(type: WWSQLite3Manager.BeginTransactionType) throws -> String {
        
        let sql = type.rawValue
        try execute(sql: sql)
        
        return sql
    }
    
    /// 提交交易
    ///
    /// 執行 `COMMIT TRANSACTION`，將目前 transaction 中的所有變更正式寫入資料庫
    ///
    /// - Note:
    ///   - 只有在 transaction 成功完成後才應呼叫 `commit()`
    ///   - 若目前沒有進行中的 transaction，執行結果可能會失敗
    ///
    /// - Returns:
    ///   實際執行的 SQL 字串
    /// - Throws:
    ///   若 SQL 執行失敗，拋出對應錯誤
    @discardableResult
    func commit() throws -> String {
        
        let sql = "COMMIT TRANSACTION"
        try execute(sql: sql)
        
        return sql
    }
    
    /// 回滾交易
    ///
    /// 執行 `ROLLBACK TRANSACTION`，取消目前 transaction 中所有尚未提交的變更
    ///
    /// - Note:
    ///   - 當 transaction 中途發生錯誤時，通常應呼叫 `rollback()`
    ///   - 若目前沒有進行中的 transaction，執行結果可能會失敗
    ///
    /// - Returns:
    ///   實際執行的 SQL 字串
    /// - Throws:
    ///   若 SQL 執行失敗，拋出對應錯誤
    @discardableResult
    func rollback() throws -> String {
        
        let sql = "ROLLBACK TRANSACTION"
        try execute(sql: sql)
        
        return sql
    }
    
    /// 在 transaction 範圍內執行指定工作
    ///
    /// 會先依指定模式開始 transaction，若 block 內所有操作都成功，則自動提交；若中途拋出錯誤，則自動回滾
    ///
    /// - Note:
    ///   - 成功時會自動執行 `commit()`
    ///   - 發生錯誤時會自動執行 `rollback()`
    ///   - SQLite 的 `BEGIN ... COMMIT` 不支援巢狀 transaction；若有巢狀需求，建議改用 `SAVEPOINT`
    ///
    /// - Parameters:
    ///   - type: transaction 開始模式
    ///   - block: 要在 transaction 內執行的工作內容
    /// - Returns:
    ///   block 執行成功後回傳的結果
    /// - Throws:
    ///   - block 內拋出的錯誤
    ///   - transaction 開始、提交或回滾失敗時的錯誤
    @discardableResult
    func transaction<T>(type: WWSQLite3Manager.BeginTransactionType = .deferred, _ block: () throws -> T) throws -> T {
        
        try begin(type: type)
        
        do {
            let result = try block()
            try commit()
            return result
        } catch {
            try? rollback()
            throw error
        }
    }
}

// MARK: - CRUD
public extension WWSQLite3Manager.Database {
    
    /// [執行 INSERT 查詢](https://www.1keydata.com/tw/sql/sqlinsert.html)
    ///
    /// 將多筆資料組合成單一 `INSERT INTO ... VALUES ...` SQL 語句，並送交 SQLite 執行
    ///
    /// - Note:
    ///   - 會依第一筆資料的欄位順序建立欄位清單
    ///   - 所有資料列的欄位數量與欄位名稱順序必須一致
    ///   - 字串內容會自動處理單引號跳脫
    ///   - `NULL` 會輸出為 SQL 的 `NULL` 關鍵字
    ///
    /// - Parameters:
    ///   - tableName: [要插入資料的資料表名稱](https://www.fooish.com/sql/insert-into.html)
    ///   - itemsArray: 多筆待新增資料，每一筆資料由多個 `InsertItem` 組成
    /// - Returns:
    ///   實際執行的 SQL 字串
    /// - Throws:
    ///   當 `itemsArray` 為空，或欄位結構不一致，或 SQL 執行失敗時拋出錯誤
    @discardableResult
    func insert(tableName: String, itemsArray: [[WWSQLite3Manager.InsertItem]]) throws -> String {
        
        guard let firstItems = itemsArray.first, !firstItems.isEmpty else { throw WWSQLite3Manager.CustomError.missingItems }
        
        let baseKeys = firstItems.map(\.key)
        
        for items in itemsArray {
            let currentKeys = items.map(\.key)
            guard currentKeys == baseKeys else { throw WWSQLite3Manager.CustomError.missingItems }
        }
        
        let keys = baseKeys.joined(separator: ", ")
        let placeholders = "(" + Array(repeating: "?", count: baseKeys.count).joined(separator: ", ") + ")"
        let valuesSQL = Array(repeating: placeholders, count: itemsArray.count).joined(separator: ", ")
        let sql = "INSERT INTO \(tableName) (\(keys)) VALUES \(valuesSQL)"
        
        var statement: OpaquePointer?
        
        let prepareCode = sql.withCString { cString in sqlite3_prepare_v3(database, cString, -1, 0, &statement, nil) }
        guard prepareCode == SQLITE_OK else { throw makeError(.prepare, code: prepareCode) }
        
        defer { sqlite3_finalize(statement) }
        
        let transient = unsafeBitCast(OpaquePointer(bitPattern: -1), to: sqlite3_destructor_type.self)
        let dateFormatter = defaultDateFormatter()
        
        var bindIndex: Int32 = 1
        
        for items in itemsArray {
            
            for item in items {
                
                guard let statement else { throw makeError(.prepare, code: SQLITE_MISUSE) }
                
                try bindValue(item.value, to: statement, index: bindIndex, transient: transient, dateFormatter: dateFormatter)
                bindIndex += 1
            }
        }
        
        let stepCode = sqlite3_step(statement)
        guard stepCode == SQLITE_DONE else { throw makeError(.execute, code: stepCode) }
        
        return sql
    }
    
    /// [執行 UPDATE 查詢](https://www.1keydata.com/tw/sql/sqlupdate.html)
    ///
    /// 將指定欄位值組合成 `UPDATE ... SET ...` SQL 語句，並可選擇搭配 `WHERE` 條件更新符合條件的資料列
    ///
    /// - Note:
    ///   - 若 `whereConditions` 為 `nil` 或內容為空，將更新整個資料表的所有資料列
    ///   - 字串內容會自動處理單引號跳脫
    ///   - `nil` 會轉成 SQL 的 `NULL`
    ///
    /// - Parameters:
    ///   - tableName: 要更新的資料表名稱
    ///   - items: 要更新的欄位與值
    ///   - whereConditions: 選用的 WHERE 條件建構器
    /// - Returns:
    ///   實際執行的 SQL 字串
    /// - Throws:
    ///   當 `items` 為空，或 SQL 執行失敗時拋出錯誤
    @discardableResult
    func update(tableName: String, items: [WWSQLite3Manager.InsertItem], where whereConditions: WWSQLite3Manager.Where? = nil) throws -> String {
        
        guard !items.isEmpty else { throw WWSQLite3Manager.CustomError.missingItems }
                
        let assignments = items.map { "\($0.key) = \(sqlValue($0.value))" }.joined(separator: ", ")
        var sql = "UPDATE \(tableName) SET \(assignments)"
        
        if let whereConditions = whereConditions, !whereConditions.sqlString.isEmpty { sql += " " + whereConditions.sqlString }
        try prepare(sql: sql)
        
        return sql
    }
    
    /// [執行 DELETE 查詢](https://www.1keydata.com/tw/sql/sqldelete.html)
    ///
    /// 產生 `DELETE FROM ...` SQL 語句，
    /// 並可選擇搭配 `WHERE` 條件刪除符合條件的資料列。
    ///
    /// - Note:
    ///   - 若 `whereConditions` 為 `nil` 或內容為空，將刪除整個資料表的所有資料列
    ///   - 使用時應特別注意是否真的要省略 `WHERE` 條件
    ///
    /// - Parameters:
    ///   - tableName: 要刪除資料的資料表名稱
    ///   - whereConditions: 選用的 WHERE 條件建構器
    /// - Returns:
    ///   實際執行的 SQL 字串
    /// - Throws:
    ///   若 SQL 執行失敗，拋出對應錯誤
    @discardableResult
    func delete(tableName: String, where whereConditions: WWSQLite3Manager.Where? = nil) throws -> String {
        
        var sql = "DELETE FROM \(tableName)"
        
        if let whereConditions = whereConditions, !whereConditions.sqlString.isEmpty { sql += " " + whereConditions.sqlString }
        try prepare(sql: sql)
        
        return sql
    }
    
    /// [執行 SELECT 查詢](https://www.1keydata.com/tw/sql/sqlselect.html)
    ///
    /// 依照 `SchemeDelegate` 定義的欄位結構，自動組合查詢欄位，並將查詢結果轉成 `[[String: Any]]` 型式回傳
    ///
    /// - Parameters:
    ///   - tableName: [資料表名稱](https://www.fooish.com/sql/count-function.html)
    ///   - type: [資料表結構描述型別，用來取得欄位名稱與欄位型別](https://www.1keydata.com/tw/sql/sqldistinct.html)
    ///   - whereConditions: 選用的 WHERE 條件建構器
    ///   - groupByConditions: 選用的 GROUP BY 條件建構器
    ///   - havingConditions: 選用的 HAVING 條件建構器
    ///   - orderByConditions: 選用的 ORDER BY 條件建構器
    ///   - limitConditions: 選用的 LIMIT 條件建構器
    /// - Returns:
    ///   包含實際執行的 SQL 字串，以及查詢結果陣列
    func select(tableName: String, type: WWSQLite3Manager.SchemeDelegate.Type, where whereConditions: WWSQLite3Manager.Where? = nil, groupBy groupByConditions: WWSQLite3Manager.GroupBy? = nil, having havingConditions: WWSQLite3Manager.Having? = nil, orderBy orderByConditions: WWSQLite3Manager.OrderBy? = nil, limit limitConditions: WWSQLite3Manager.Limit? = nil) -> WWSQLite3Manager.SelectResult {
        
        let structure = type.structure()
        let fields = structure.map { $0.key.sqlIdentifier() }.joined(separator: ", ")
        
        return selectCore(tableName: tableName, fields: fields, decode: { statement in
            
            var array: [[String: Any]] = []
            
            while sqlite3_step(statement) == SQLITE_ROW {
                
                var dict: [String: Any] = [:]
                
                structure.enumerated().forEach { index, column in
                    dict[column.key] = statement?.value(at: Int32(index), dataType: column.type)
                }
                
                array.append(dict)
            }
            
            return array
            
        }, where: whereConditions, groupBy: groupByConditions, having: havingConditions, orderBy: orderByConditions, limit: limitConditions)
    }
    
    /// 查詢指定欄位或函數結果
    ///
    /// 依照 `SelectMethod` 陣列產生 `SELECT` 欄位清單，
    /// 可支援一般欄位、聚合函數、`DISTINCT` 與欄位別名等查詢需求。
    ///
    /// - Note:
    ///   - `methods` 會決定 `SELECT` 子句中的 result-column 內容
    ///   - 查詢結果的欄位名稱會以 `SelectMethod.aliasName()` 為主
    ///   - 查詢結果的資料型別會以 `SelectMethod.dataType()` 進行解析
    ///   - 若需查詢資料表全部原始欄位，建議使用 `selectAll(...)`
    ///
    /// - Parameters:
    ///   - tableName: 要查詢的資料表名稱
    ///   - methods: `SELECT` 欄位描述陣列，可為一般欄位或 SQL 函數欄位
    ///   - whereConditions: `WHERE` 條件
    ///   - groupByConditions: `GROUP BY` 條件
    ///   - havingConditions: `HAVING` 條件
    ///   - orderByConditions: `ORDER BY` 條件
    ///   - limitConditions: `LIMIT` 條件
    /// - Returns:
    ///   實際執行的 SQL 字串與查詢結果陣列
    @discardableResult
    func select(tableName: String, methods: [WWSQLite3Manager.SelectMethod], where whereConditions: WWSQLite3Manager.Where? = nil, groupBy groupByConditions: WWSQLite3Manager.GroupBy? = nil, having havingConditions: WWSQLite3Manager.Having? = nil, orderBy orderByConditions: WWSQLite3Manager.OrderBy? = nil, limit limitConditions: WWSQLite3Manager.Limit? = nil
    ) -> WWSQLite3Manager.SelectResult {
        
        guard !methods.isEmpty else { return ("", []) }
        
        let fields = methods.map(\.sql).joined(separator: ", ")
        
        return selectCore(tableName: tableName, fields: fields, decode: { statement in
            
            var array: [[String: Any]] = []
            
            while sqlite3_step(statement) == SQLITE_ROW {
                
                var dict: [String: Any] = [:]
                
                methods.enumerated().forEach { index, method in
                    dict[method.aliasName()] = statement?.value(at: Int32(index), dataType: method.dataType())
                }
                
                array.append(dict)
            }
            
            return array
            
        }, where: whereConditions, groupBy: groupByConditions, having: havingConditions, orderBy: orderByConditions, limit: limitConditions)
    }
}

// MARK: - 小工具
extension WWSQLite3Manager.Database {
    
    ///  query(sql:result:) 的 async 版本
    /// - Parameter sql: String
    /// - Returns: [WWSQLite3Manager.SQLiteRow]
    func query(sql: String) throws -> [WWSQLite3Manager.SQLiteRow] {
        
        var statement: OpaquePointer? = nil
        defer { sqlite3_finalize(statement) }
        
        let prepareCode = sqlite3_prepare_v3(database, sql.cString(using: .utf8), -1, 0, &statement, nil)
        guard prepareCode == SQLITE_OK else { throw makeError(.prepare, code: prepareCode) }

        var rows: [WWSQLite3Manager.SQLiteRow] = []

        while true {
            
            let stepCode = sqlite3_step(statement)

            switch stepCode {
            case SQLITE_ROW: rows.append(readRow(statement))
            case SQLITE_DONE: return rows
            default: throw makeError(.step, code: stepCode)
            }
        }
    }
}

// MARK: - 小工具
private extension WWSQLite3Manager.Database {
    
    /// 執行 SELECT 查詢核心邏輯
    ///
    /// 將欄位字串、條件子句與解碼流程組合成完整 `SELECT` 語句，
    /// 並透過 prepared statement 執行查詢後回傳結果。
    ///
    /// - Note:
    ///   - `fields` 需為合法的 result-column 字串，例如欄位清單、`*` 或函數表達式
    ///   - `decode` 用來定義每一列查詢結果如何轉成 `[[String: Any]]`
    ///   - `WHERE` 會先於 `GROUP BY` 套用；`HAVING` 則是在分組後過濾群組
    ///   - `ORDER BY` 會影響結果排序；`LIMIT` 會限制回傳筆數
    ///
    /// - Parameters:
    ///   - tableName: 要查詢的資料表名稱
    ///   - fields: `SELECT` 子句中的欄位字串
    ///   - decode: 查詢結果解碼閉包，用來將 statement 內容轉成結果陣列
    ///   - whereConditions: `WHERE` 條件
    ///   - groupByConditions: `GROUP BY` 條件
    ///   - havingConditions: `HAVING` 條件
    ///   - orderByConditions: `ORDER BY` 條件
    ///   - limitConditions: `LIMIT` 條件
    /// - Returns:
    ///   實際執行的 SQL 字串與查詢結果陣列
    func selectCore(tableName: String, fields: String, decode: (_ statement: OpaquePointer?) -> [[String: Any]], where whereConditions: WWSQLite3Manager.Where?, groupBy groupByConditions: WWSQLite3Manager.GroupBy?, having havingConditions: WWSQLite3Manager.Having?, orderBy orderByConditions: WWSQLite3Manager.OrderBy?, limit limitConditions: WWSQLite3Manager.Limit?) -> WWSQLite3Manager.SelectResult {
        
        let name = tableName.sqlIdentifier()
        var sql = "SELECT \(fields) FROM \(name)"
        var statement: OpaquePointer? = nil
        
        if let whereConditions = whereConditions, !whereConditions.sqlString.isEmpty { sql += " " + whereConditions.sqlString }
        if let groupByConditions = groupByConditions, !groupByConditions.sqlString.isEmpty { sql += " " + groupByConditions.sqlString }
        if let havingConditions = havingConditions, !havingConditions.sqlString.isEmpty { sql += " " + havingConditions.sqlString }
        if let orderByConditions = orderByConditions, !orderByConditions.sqlString.isEmpty { sql += " " + orderByConditions.sqlString }
        if let limitConditions = limitConditions, !limitConditions.sqlString.isEmpty { sql += " " + limitConditions.sqlString }
        
        defer { sqlite3_finalize(statement) }
        sqlite3_prepare_v3(database, sql.cString(using: .utf8), -1, 0, &statement, nil)
        
        let array = decode(statement)
        return (sql, array)
    }
    
    /// [讀取資料表欄位資訊](https://stackoverflow.com/questions/39824274/sqlite-pragma-table-infotable-not-returning-column-names-using-data-sqlite-in)
    ///
    /// 使用 `PRAGMA TABLE_INFO(...)` 查詢指定資料表的欄位結構，
    /// 並依照 `SchemeDelegate` 定義的欄位型別，將結果轉成 `[String: Any]` 陣列。
    ///
    /// - Note:
    ///   - `PRAGMA TABLE_INFO` 會針對資料表中的每個欄位回傳一筆資料
    ///   - 常見欄位包含：`cid`、`name`、`type`、`notnull`、`dflt_value`、`pk`
    ///
    /// - Parameters:
    ///   - tableName: 要查詢欄位資訊的資料表名稱
    ///   - type: 欄位結構描述型別，用來定義結果欄位的名稱與資料型別
    /// - Returns:
    ///   包含實際執行的 SQL 字串，以及欄位資訊結果陣列
    func tableInformation(tableName: String, type: WWSQLite3Manager.SchemeDelegate.Type) -> WWSQLite3Manager.SelectResult {
        
        let sql = "PRAGMA TABLE_INFO(\(tableName))"
        
        var statement: OpaquePointer? = nil
        var array: [[String : Any]] = []
        
        defer { sqlite3_finalize(statement) }
        
        sqlite3_prepare_v2(database, sql.cString(using: .utf8), -1, &statement, nil)
        
        while sqlite3_step(statement) == SQLITE_ROW {
            
            var dict: [String : Any] = [:]
            
            type.structure()._forEach { (index, paramater, _) in
                dict[paramater.key] = statement?.value(at: Int32(index), dataType: paramater.type) ?? nil
            }
            
            array.append(dict)
        }
        
        return (sql, array)
    }
    
    /// 產生 PRIMARY KEY 子句字串
    ///
    /// 依照傳入的主鍵欄位名稱陣列，建立單一主鍵或複合主鍵的 SQL 片段。
    ///
    /// - Note:
    ///   - 若 `primaryKeys` 為空，預設會使用 `structure()` 的第一個欄位作為主鍵候選
    ///   - 會自動過濾 `nil`、空字串與前後空白
    ///   - 欄位名稱會自動轉成 SQL identifier 格式
    ///   - 若有多個有效欄位，會建立複合主鍵，例如 `PRIMARY KEY("id", "name")`
    ///
    /// - Parameters:
    ///   - type: 欄位結構描述型別
    ///   - primaryKeys: 主鍵欄位名稱陣列，可為單一主鍵或複合主鍵
    /// - Returns:
    ///   `PRIMARY KEY(...)` SQL 字串；若沒有有效欄位名稱則回傳 `nil`
    func makePrimaryKeySQL(type: WWSQLite3Manager.SchemeDelegate.Type, primaryKeys: [String?]) -> String? {
        
        let keyCandidates = primaryKeys.isEmpty ? [type.structure().first?.key] : primaryKeys
        let validPrimaryKeys = keyCandidates.compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }.map { $0.sqlIdentifier() }
        
        guard !validPrimaryKeys.isEmpty else { return nil }
        
        return "PRIMARY KEY(\(validPrimaryKeys.joined(separator: ", ")))"
    }
    
    /// 將值轉成 SQLite 可用的字串
    /// - Parameter value: 任意型別的欄位值
    /// - Returns: 可直接拼接到 SQL 的字串
    /// 將值轉成 SQLite 可用的字串
    /// - Parameter value: 任意型別的欄位值
    /// - Returns: 可直接拼接到 SQL 的字串
    func sqlValue(_ value: WWSQLite3Manager.InsertValue?) -> String {
        
        guard let value else { return "NULL" }
        
        switch value {
        case .null: return "NULL"
        case .int(let int): return "\(int)"
        case .double(let double): return "\(double)"
        case .bool(let bool): return bool ? "1" : "0"
        case .date(let date): return "\(date.timeIntervalSince1970)"
        case .string(let string): let escaped = string.replacingOccurrences(of: "'", with: "\'"); return "'\(escaped)'"
        case .data(let data): let hex = data.map { String(format: "%02X", $0) }.joined(); return "X'\(hex)'"
        }
    }
    
    /// 將 Swift 型別封裝的 InsertValue 綁定到 SQLite prepared statement 的指定 index
    ///
    /// - Parameters:
    ///   - value: 要綁定的值（enum 包裝，對應 SQLite 支援型別）
    ///   - statement: SQLite prepared statement (sqlite3_stmt *)
    ///   - index: 欄位索引（從 1 開始）
    ///   - transient: SQLite destructor，用來指定資料生命週期（通常使用 SQLITE_TRANSIENT）
    ///   - dateFormatter: Date → String 的格式轉換器
    ///
    /// - Throws: 當 sqlite3_bind_* 回傳非 SQLITE_OK 時拋出錯誤
    func bindValue(_ value: WWSQLite3Manager.InsertValue, to statement: OpaquePointer, index: Int32, transient: sqlite3_destructor_type, dateFormatter: DateFormatter) throws {
        
        let result: Int32
        
        switch value {
        case .null: result = sqlite3_bind_null(statement, index)
        case .string(let text): result = text.withCString { sqlite3_bind_text(statement, index, $0, -1, transient) }
        case .int(let number): result = sqlite3_bind_int64(statement, index, number)
        case .double(let number): result = sqlite3_bind_double(statement, index, number)
        case .bool(let flag): result = sqlite3_bind_int(statement, index, flag ? 1 : 0)
        case .data(let data):
            result = data.withUnsafeBytes { buffer in
                guard let baseAddress = buffer.baseAddress else { return sqlite3_bind_null(statement, index) }
                return sqlite3_bind_blob(statement, index, baseAddress, Int32(buffer.count), transient)
            }
        case .date(let date):
            let text = dateFormatter.string(from: date)
            result = text.withCString { sqlite3_bind_text(statement, index, $0, -1, transient) }
        }
        
        guard result == SQLITE_OK else { throw makeError(.execute, code: result) }
    }
    
    /// 建立預設的 DateFormatter（用於 SQLite 儲存 Date）
    ///
    /// 設計重點：
    /// - 使用固定格式避免 locale 影響
    /// - 使用 UTC（GMT+0）確保跨時區一致
    /// - 使用 POSIX locale 避免 12/24 小時或地區差異
    ///
    /// 格式：yyyy-MM-dd HH:mm:ss ZZZ
    /// 範例：2026-05-29 01:30:00 +0000
    func defaultDateFormatter() -> DateFormatter {
        
        let formatter = DateFormatter()
        
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        
        return formatter
    }
    
    /// 讀取目前 statement 所在的一列資料，並轉成 SQLiteRow。
    /// - Parameter statement: SQLite 查詢目前的資料列指標。
    /// - Returns: 以欄位名稱為 key、欄位值為 value 的字典。
    func readRow(_ statement: OpaquePointer?) -> WWSQLite3Manager.SQLiteRow {
        
        guard let statement else { return [:] }

        let columnCount = sqlite3_column_count(statement)
        var row: WWSQLite3Manager.SQLiteRow = [:]

        for index in 0..<columnCount {
            
            let name = String(cString: sqlite3_column_name(statement, index))
            let type = sqlite3_column_type(statement, index)
            
            switch type {
            case SQLITE_INTEGER: row[name] = sqlite3_column_int64(statement, index)
            case SQLITE_FLOAT: row[name] = sqlite3_column_double(statement, index)
            case SQLITE_TEXT: row[name] = sqlite3_column_text(statement, index).map { String(cString: $0) }
            case SQLITE_NULL: row[name] = nil
            case SQLITE_BLOB: if let bytes = sqlite3_column_blob(statement, index) { let size = Int(sqlite3_column_bytes(statement, index)); row[name] = Data(bytes: bytes, count: size) }
            default: break
            }
        }

        return row
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
