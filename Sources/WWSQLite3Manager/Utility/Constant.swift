//
//  Constant.swift
//  WWSQLite3Manager
//
//  Created by William.Weng on 2022/1/14.
//

import Foundation

// MARK: - enum
public extension WWSQLite3Manager {
    
    /// WWSQLite3Manager 使用的自訂錯誤型別 => 用來描述資料庫開啟失敗、缺少必要資料，或是 SQLite API 執行時發生的錯誤資訊
    enum CustomError: Error, LocalizedError {
        
        case unknown                                                        // 未知錯誤
        case notOpenURL                                                     // 無法開啟指定的資料庫 URL
        case missingItems                                                   // 缺少必要的資料項目
        case sqlite(operation: Operation, code: Int32, message: String)     // SQLite 操作失敗 (操作類型, 錯誤碼, 錯誤訊息)
    }
    
    /// SQLite 執行流程中的操作類型 => 可用來標示錯誤發生於哪一個 SQLite 呼叫階段，方便除錯與記錄
    enum Operation: String {
        
        case execute                                                        // 執行 SQL 指令
        case prepare                                                        // 預備 SQL 語句
        case step                                                           // 執行單步查詢或更新
        case close                                                          // 關閉資料庫連線
    }
    
    /// 資料排序方向
    enum SortDirection: String {
        case asc = "ASC"                                                    // 升冪排序（預設）
        case desc = "DESC"                                                  // 降冪排序
    }
    
    /// SQLite 交易控制指令類型
    ///
    /// 對應 SQLite 常見的交易語法字串，可用於開始、提交或回滾交易
    enum TransactionType: String {
        
        case begin = "BEGIN"                                                // 開始交易
        case commit = "COMMIT"                                              // 提交交易
        case rollback = "ROLLBACK"                                          // 回滾交易
    }
    
    /// 表示 SQL 條件比較運算子 => 用於 WHERE 子句中的欄位比較
    enum CompareOperator: String {
        
        case equal = "="                                                    // 等於 (=)
        case notEqual = "!="                                                // 不等於 (!=)
        case greaterThan = ">"                                              // 大於 (>)
        case greaterThanOrEqual = ">="                                      // 大於等於 (>=)
        case lessThan = "<"                                                 // 小於 (<)
        case lessThanOrEqual = "<="                                         // 小於等於 (<=)
        case like = "LIKE"                                                  // 模糊比對 (LIKE)
    }
    
    /// 表示多個條件之間的邏輯運算子 => 用於 WHERE 子句中條件的串接
    enum JoinType {
        
        case and                                                            // 邏輯且 (AND)
        case or                                                             // 邏輯或 (OR)
    }
    
    /// 表示 SQL 語句中可使用的資料型別 => 用於 INSERT、UPDATE、WHERE 等參數綁定
    enum SQLValue {
        
        case int(Int)                                                       // 整數型別 (INTEGER)
        case double(Double)                                                 // 浮點數型別 (REAL / DOUBLE)
        case text(String)                                                   // 字串型別 (TEXT)
        case null                                                           // 空值 (NULL)
    }
    
    /// 排序 => 小到大 / 大到小
    enum OrderByType {
        
        case ascending(key: String)                                         // 依指定欄位遞增排序 (要排序的欄位名稱)
        case descending(key: String)                                        // 依指定欄位遞減排序 (要排序的欄位名稱)
        case random                                                         // 隨機排序
    }
    
    /// 大於 / 等於 / 小於
    enum CompareType {
        
        case equal(key: String, value: Any)                                 // 等於指定值 (欄位名稱, 要比較的值)
        case greaterThan(key: String, value: Any)                           // 大於指定值 (欄位名稱, 要比較的值)
        case greaterOrEqual(key: String, value: Any)                        // 大於或等於指定值 (欄位名稱, 要比較的值)
        case lessThan(key: String, value: Any)                              // 小於指定值 (欄位名稱, 要比較的值)
        case lessOrEqual(key: String, value: Any)                           // 小於或等於指定值 (欄位名稱, 要比較的值)
        case notEqual(key: String, value: Any)                              // 不等於指定值 (欄位名稱, 要比較的值)
    }
    
    /// [SQLite3的資料類型](https://www.sqlite.org/datatype3.html)
    enum DataType {
                
        case INTEGER(attribute: Attribute = (false, false, false), defaultValue: Int? = nil)        // 整數型別 (欄位屬性設定, 預設值)
        case TEXT(attribute: Attribute = (false, false, false), defaultValue: String? = nil)        // 文字型別 (欄位屬性設定, 預設值)
        case BLOB(attribute: Attribute = (false, false, false), defaultValue: String? = nil)        // 二進位資料型別 (欄位屬性設定, 預設值)
        case REAL(attribute: Attribute = (false, false, false), defaultValue: Double? = nil)        // 浮點數型別 (欄位屬性設定, 預設值)
        case NUMERIC(attribute: Attribute = (false, false, false), defaultValue: Double? = nil)     // 數值型別 (欄位屬性設定, 預設值)
        case TIMESTAMP(defaultValue: String? = "CURRENT_TIMESTAMP")                                 // 時間戳記型別
    }
}

// MARK: - enum (indirect)
public extension WWSQLite3Manager {
    
    /// 表示 SQL WHERE 子句的條件表達式（抽象語法樹）=> 可透過遞迴結構組合複雜查詢條件
    indirect enum WhereExpression {
        
        case compare(key: String, operator: CompareOperator, value: SQLValue)   // 單一欄位比較 => Example: age > 18
        case between(key: String, from: SQLValue, to: SQLValue)                 // 區間查詢（包含邊界）=> Example: age BETWEEN 18 AND 30
        case notBetween(key: String, from: SQLValue, to: SQLValue)              // 區間排除（包含邊界）=> Example: age NOT BETWEEN 18 AND 30
        case like(key: String, pattern: String, escape: Character?)             // 模糊比對（LIKE）=> Example: name LIKE '%abc%' ESCAPE '\'
        case notLike(key: String, pattern: String, escape: Character?)          // 排除模糊比對（NOT LIKE）=> Example: name NOT LIKE '%abc%'
        case `in`(key: String, values: [SQLValue])                              // 集合包含（IN）=> Example: id IN (1, 2, 3)
        case notIn(key: String, values: [SQLValue])                             // 集合排除（NOT IN）=> Example: id NOT IN (1, 2, 3)
        case and(WhereExpression, WhereExpression)                              // 邏輯 AND 組合 => Example: (age > 18) AND (score >= 60)
        case or(WhereExpression, WhereExpression)                               // 邏輯 OR 組合 => Example: (age < 18) OR (age > 65)
        case not(WhereExpression)                                               // 邏輯 NOT 反轉條件 => Example: NOT (age > 18)
        case group(WhereExpression)                                             // 群組條件（對應括號）=> Example: (age > 18 AND score > 60)
    }
}

// MARK: - CustomError (LocalizedError)
public extension WWSQLite3Manager.CustomError {
        
    var errorDescription: String { makeErrorDescription() }
    var failureReason: String { makeFailureReason() }
    var recoverySuggestion: String? { makeRecoverySuggestion() }
}

// MARK: - SQLValue
extension WWSQLite3Manager.SQLValue {
    
    var sqlString: String { makeSqlString() }
}

// MARK: - WhereExpression
extension WWSQLite3Manager.WhereExpression {
    
    var sqlString: String { makeSqlString() }
}

// MARK: - OrderByType
public extension WWSQLite3Manager.OrderByType {
    
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

// MARK: - CompareType
public extension WWSQLite3Manager.CompareType {
    
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

// MARK: - DataType
public extension WWSQLite3Manager.DataType {
    
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

// MARK: - DataType
private extension WWSQLite3Manager.DataType {
    
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
}

// MARK: - 小工具
private extension WWSQLite3Manager.DataType {

    /// 組成SQL字串
    /// - Parameters:
    ///   - attribute: SQLite3Condition.Attribute
    ///   - defaultValue: T?
    /// - Returns: String
    func sqlStringMaker<T>(attribute: WWSQLite3Manager.Attribute, defaultValue: T?) -> String {
        
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
    func timestampString(defaultValue: String?) -> String {
        
        var sql = self.toString()
        if let defaultValue = defaultValue { sql += " DEFAULT \(defaultValue)" }
        
        return sql
    }
}

// MARK: - SQLValue
private extension WWSQLite3Manager.SQLValue {
    
    /// 將 SQLValue 轉成可直接嵌入 SQL 的字串
    /// - Returns: SQL 字串
    /// - Note:
    ///   - String 會自動處理單引號跳脫
    ///   - NULL 會轉成 SQL 的 NULL 關鍵字
    func makeSqlString() -> String {
        
        switch self {
        case .int(let value): return "\(value)"
        case .double(let value): return "\(value)"
        case .text(let value): return "'\(value.replacingOccurrences(of: "'", with: "''"))'"
        case .null: return "NULL"
        }
    }
}

// MARK: - CustomError
private extension WWSQLite3Manager.CustomError {
    
    /// 產生錯誤描述
    /// - Returns: 給使用者或開發者閱讀的錯誤訊息
    /// - Note:
    ///   - `.unknown`：代表目前無法判斷錯誤類型
    ///   - `.notOpenURL`：代表資料庫尚未正確開啟，或資料來源 URL 有問題
    ///   - `.sqlite(...)`：整合 SQLite 操作階段、錯誤碼與原始訊息，方便除錯
    func makeErrorDescription() -> String {
        
        switch self {
        case .unknown: return "未知錯誤"
        case .notOpenURL: return "資料庫尚未開啟或 URL 無效"
        case .missingItems: return "資料缺失"
        case .sqlite(let operation, let code, let message): return "SQLite錯誤 [\(operation.rawValue)] (\(code))：\(message)"
        }
    }
    
    /// 產生錯誤原因
    /// - Returns: 錯誤發生的可能原因說明
    /// - Note:
    ///   - 這裡偏向描述錯誤背景，而不是直接提供處理方式
    ///   - 若是 SQLite 錯誤，會附上操作階段與錯誤碼，方便追蹤問題位置
    func makeFailureReason() -> String {
        
        switch self {
        case .unknown: return "系統無法判斷錯誤原因"
        case .notOpenURL: return "資料庫連線資訊不存在"
        case .missingItems: return "找不到可用的資料項目"
        case .sqlite(let operation, let code, _): return "執行 SQLite 的 \(operation.rawValue) 時失敗，錯誤碼：\(code)"
        }
    }
    
    /// 產生修正建議
    /// - Returns: 發生錯誤時可採取的處理方式；若無明確建議可回傳 `nil`
    /// - Note:
    ///   - `.execute`：偏向執行不需逐列讀取結果的 SQL，像是 CREATE / DROP / PRAGMA
    ///   - `.prepare`：偏向 SQL 預編譯階段失敗，通常和語法、欄位或資料表有關
    ///   - `.step`：偏向 SQL 真正執行時失敗，常見於資料型別、約束條件或綁定參數
    ///   - `.close`：偏向資料庫關閉時仍有未釋放資源，例如尚未 finalize 的 statement
    func makeRecoverySuggestion() -> String? {
        
        switch self {
        case .unknown: return "請重新檢查流程或紀錄錯誤資訊"
        case .notOpenURL: return "請先確認資料庫是否已正確開啟"
        case .missingItems: return "請先確認資料內容不為空，並至少包含一筆可供處理的資料"
        case .sqlite(let operation, _, _):
            switch operation {
            case .execute: return "請檢查 SQL 語法是否正確，像是 CREATE、DROP、PRAGMA 這類語句。"
            case .prepare: return "請檢查 SQL 是否能成功 prepare，包含資料表名稱、欄位名稱與語法。"
            case .step: return "請檢查 SQL 執行內容、資料型別、約束條件與綁定參數是否正確。"
            case .close: return "請確認是否仍有未 finalize 的 statement 或未完成的資料庫操作。"
            }
        }
    }
}

private extension WWSQLite3Manager.WhereExpression {
    
    /// 依照不同的條件節點產生對應 SQL 字串
    /// - Returns: String
    func makeSqlString() -> String {
        
        switch self {
        case .between(let key, let from, let to): return "\(key) BETWEEN \(from.sqlString) AND \(to.sqlString)"
        case .notBetween(let key, let from, let to): return "\(key) NOT BETWEEN \(from.sqlString) AND \(to.sqlString)"
        case .like(let key, let pattern, let escape): return "\(key) LIKE \(quoted(pattern))\(escapeClause(escape))"
        case .notLike(let key, let pattern, let escape): return "\(key) NOT LIKE \(quoted(pattern))\(escapeClause(escape))"
        case .in(let key, let values): return "\(key) IN (\(joined(values)))"
        case .notIn(let key, let values): return "\(key) NOT IN (\(joined(values)))"
        case .and(let lhs, let rhs): return "\(lhs.sqlString) AND \(rhs.sqlString)"
        case .or(let lhs, let rhs): return "\(lhs.sqlString) OR \(rhs.sqlString)"
        case .not(let expression): return "NOT \(wrap(expression))"
        case .group(let expression): return "(\(expression.sqlString))"
        case .compare(let key, let op, let value): return compareAction(key: key, op: op, value: value)
        }
    }
    
    /// 處理一般比較運算式
    /// - Returns: String
    /// - Note:
    ///   - 當 value 為 NULL 時，equal / notEqual 會改寫成 IS NULL / IS NOT NULL
    ///   - 其餘運算子若搭配 NULL，仍保留原始運算子字串
    func compareAction(key: String, op: WWSQLite3Manager.CompareOperator, value: WWSQLite3Manager.SQLValue) -> String {
        
        if case .null = value {
            switch op {
            case .equal: return "\(key) IS NULL"
            case .notEqual: return "\(key) IS NOT NULL"
            default: return "\(key) \(op.rawValue) NULL"
            }
        }
        
        return "\(key) \(op.rawValue) \(value.sqlString)"
    }
    
    /// 依照條件型別決定是否需要補上括號
    /// - Returns: String
    /// - Note:
    ///   - 單一條件不額外包裝
    ///   - 複合條件（AND / OR / NOT）會自動加上括號以確保邏輯正確
    func wrap(_ expression: WWSQLite3Manager.WhereExpression) -> String {
        
        switch expression {
        case .compare, .between, .notBetween, .like, .notLike, .in, .notIn: return expression.sqlString
        case .group: return expression.sqlString
        case .and, .or, .not: return "(\(expression.sqlString))"
        }
    }
    
    /// 將字串加上單引號，並處理 SQL 單引號跳脫
    /// - Returns: String
    func quoted(_ string: String) -> String {
        "'\(string.replacingOccurrences(of: "'", with: "''"))'"
    }
    
    /// 產生 LIKE / NOT LIKE 使用的 ESCAPE 子句
    /// - Parameter escape: 跳脫字元
    /// - Returns: 若 escape 為 nil，則回傳空字串
    func escapeClause(_ escape: Character?) -> String {
        guard let escape else { return "" }
        return " ESCAPE '\(escape)'"
    }
    
    /// 將多個 SQLValue 串接成逗號分隔字串
    /// - Returns: String
    /// - Example: 1, 'A', NULL
    func joined(_ values: [WWSQLite3Manager.SQLValue]) -> String {
        values.map(\.sqlString).joined(separator: ", ")
    }
}
