//
//  Constant.swift
//  WWSQLite3Manager
//
//  Created by William.Weng on 2022/1/14.
//

import Foundation

// MARK: - enum
public extension WWSQLite3Manager {
    
    /// 自訂錯誤
    enum CustomError: Error, LocalizedError {
        
        case unknown
        case notOpenURL
        case missingItems
        case sqlite(operation: Operation, code: Int32, message: String)
    }
    
    enum Operation: String {
        case execute
        case prepare
        case step
        case close
    }
    
    enum TransactionType: String {
        case begin = "BEGIN"
        case commit = "COMMIT"
        case rollback = "ROLLBACK"
    }
}

// MARK: - CustomError (LocalizedError)
public extension WWSQLite3Manager.CustomError {
        
    var errorDescription: String { makeErrorDescription() }
    var failureReason: String { makeFailureReason() }
    var recoverySuggestion: String? { makeRecoverySuggestion() }
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

