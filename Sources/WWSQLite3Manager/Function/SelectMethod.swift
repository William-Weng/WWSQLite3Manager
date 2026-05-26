//
//  SQLite3Method.swift
//  WWSQLite3Manager
//
//  Created by William.Weng on 2023/2/21.
//

import Foundation

// MARK: - TableScheme
public extension WWSQLite3Manager {
    
    /// SELECT 欄位描述
    ///
    /// 用來定義查詢欄位的 SQL 表達式、別名與回傳資料型別
    enum SelectMethod {
        
        case column(_ key: String, _ type: DataType, aliasName: String? = nil)          // 原始的一般欄位
        case count(_ key: String? = nil, _ type: DataType, aliasName: String? = nil)    // 總數量
        case distinct(_ key: String, _ type: DataType, aliasName: String? = nil)        // 未重複值
        case distinctCount(_ key: String, _ type: DataType, aliasName: String? = nil)   // 未重複值的總數量
        case min(_ key: String, _ type: DataType, aliasName: String? = nil)             // 最小值
        case max(_ key: String, _ type: DataType, aliasName: String? = nil)             // 最大值
        case avg(_ key: String, _ type: DataType, aliasName: String? = nil)             // 平均值
        case sum(_ key: String, _ type: DataType, aliasName: String? = nil)             // 全部總和
    }
}

// MARK: - 公開函式
public extension WWSQLite3Manager.SelectMethod {
    
    var sql: String { makeSQL() }
}

// MARK: - 公開函式
extension WWSQLite3Manager.SelectMethod {
    
    /// [產生 SELECT 欄位對應的 SQL 片段](https://ithelp.ithome.com.tw/articles/10208205)
    ///
    /// - Example:
    ///   - `name AS name`
    ///   - `COUNT(*) AS Count`
    ///   - `COUNT(DISTINCT userId) AS userIdDistinctCount`
    ///   - `AVG(score) AS scoreAvg`
    /// - Returns: [SQL 欄位字串](https://ithelp.ithome.com.tw/articles/10259378)
    func makeSQL() -> String {
        
        let baseSQL: String
        
        switch self {
        case .column(let key, _, _): baseSQL = key
        case .count(let key, _, _): baseSQL = makeCountSql(with: key)
        case .distinct(let key, _, _): baseSQL = "DISTINCT \(key)"
        case .distinctCount(let key, _, _): baseSQL = "COUNT(DISTINCT \(key))"
        case .min(let key, _, _): baseSQL = "MIN(\(key))"
        case .max(let key, _, _): baseSQL = "MAX(\(key))"
        case .avg(let key, _, _): baseSQL = "AVG(\(key))"
        case .sum(let key, _, _): baseSQL = "SUM(\(key))"
        }
        
        return "\(baseSQL) AS \(aliasName())"
    }
    
    /// [取得欄位別名](https://clay-atlas.com/blog/2019/11/20/sql-avg-count-sum-max-min/)
    ///
    /// [若未指定別名，則自動產生預設名稱](https://data36.com/sql-functions-beginners-tutorial-ep3/)
    ///
    /// - Returns: [欄位別名](http://faculty.stust.edu.tw/~jehuang/oracle/ch4/4-10.htm)
    func aliasName() -> String {
        
        switch self {
        case .column(let key, _, let aliasName): return aliasName ?? key
        case .count(let key, _, let aliasName): return makeCountAliasName(aliasName, key: key)
        case .distinct(let key, _, let aliasName): return aliasName ?? key
        case .distinctCount(let key, _, let aliasName): return aliasName ?? "\(key)DistinctCount"
        case .min(let key, _, let aliasName): return aliasName ?? "\(key)Min"
        case .max(let key, _, let aliasName): return aliasName ?? "\(key)Max"
        case .avg(let key, _, let aliasName): return aliasName ?? "\(key)Avg"
        case .sum(let key, _, let aliasName): return aliasName ?? "\(key)Sum"
        }
    }
    
    /// 回傳查詢結果的資料型別
    ///
    /// - Returns: 欄位對應的資料型別
    func dataType() -> WWSQLite3Manager.DataType {
                
        switch self {
        case .column(_, let type, _): return type
        case .count(_, let type, _): return type
        case .distinct(_, let type, _): return type
        case .distinctCount(_, let type, _): return type
        case .min(_, let type, _): return type
        case .max(_, let type, _): return type
        case .avg(_, let type, _): return type
        case .sum(_, let type, _): return type
        }
    }
    
    /// 回傳實際欄位名稱或函數所使用的目標欄位
    ///
    /// - Note:
    ///   `COUNT(*)` 會回傳 nil。
    func key() -> String? {
        
        switch self {
        case .column(let key, _, _): return key
        case .count(let key, _, _): return key
        case .distinct(let key, _, _): return key
        case .distinctCount(let key, _, _): return key
        case .min(let key, _, _): return key
        case .max(let key, _, _): return key
        case .avg(let key, _, _): return key
        case .sum(let key, _, _): return key
        }
    }
}

// MARK: - 小工具
private extension WWSQLite3Manager.SelectMethod {
    
    /// 產生 COUNT 對應的 SQL 字串
    ///
    /// - Note:
    ///   - 當 `key` 為 `nil` 或空字串時，回傳 `COUNT(*)`
    ///   - 當 `key` 有值時，回傳 `COUNT(key)`
    ///   - `COUNT(*)` 會計算所有資料列
    ///   - `COUNT(key)` 只會計算該欄位不為 `NULL` 的筆數
    ///
    /// - Parameter key: 要計算的欄位名稱
    /// - Returns: COUNT 的 SQL 片段
    func makeCountSql(with key: String?) -> String {
        
        if let key = key, !key.isEmpty { return "COUNT(\(key))" }
        return "COUNT(*)"
    }
    
    /// 產生 COUNT 欄位的預設別名
    ///
    /// - Note:
    ///   - 若有自訂 `aliasName`，則優先回傳自訂值
    ///   - 若 `key` 為 `nil` 或空字串，預設別名為 `Count`
    ///   - 若 `key` 有值，預設別名為 `\(key)Count`
    ///
    /// - Parameters:
    ///   - aliasName: 自訂欄位別名
    ///   - key: 要計算的欄位名稱
    /// - Returns: 欄位別名字串
    func makeCountAliasName(_ aliasName: String?, key: String?) -> String {
        
        guard let key = key, !key.isEmpty else { return aliasName ?? "Count" }
        return aliasName ?? "\(key)Count"
    }
}
