//
//  Constant.swift
//  WWSQLite3Manager
//
//  Created by William.Weng on 2022/1/14.
//

import Foundation

// MARK: - 常數
final class Constant {}

// MARK: - typealias
extension Constant {
    
    typealias CompareType = (key: String, symbol: String, value: Any)   // 比較用符號 (height >= 10)
    typealias OrderType = (key: String, symbol: String)                 // 排序用符號 (height ASC)
}

// MARK: - enum
extension Constant {
    
    /// 自訂錯誤
    enum MyError: Error, LocalizedError {
        
        var errorDescription: String { errorMessage() }
        
        case unknown
        case notOpenURL
        
        /// 錯誤訊息
        /// - Returns: String
        private func errorMessage() -> String {

            switch self {
            case .unknown: return "未知錯誤"
            case .notOpenURL: return "打開URL錯誤"
            }
        }
    }
}
