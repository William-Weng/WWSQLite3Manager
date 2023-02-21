//
//  Constant.swift
//  WWSQLite3Manager
//
//  Created by William.Weng on 2022/1/14.
//

import Foundation

// MARK: - enum
final class Constant {
    
    /// 自訂錯誤
    enum MyError: Error, LocalizedError {
        
        var errorDescription: String { errorMessage() }
        
        case unknown
        case notOpenURL
        
        private func errorMessage() -> String {

            switch self {
            case .unknown: return "未知錯誤"
            case .notOpenURL: return "打開URL錯誤"
            }
        }
    }
}
