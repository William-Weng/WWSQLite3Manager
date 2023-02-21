//
//  SQLite3Function+Count.swift
//  WWSQLite3Manager
//
//  Created by William.Weng on 2023/2/21.
//

import Foundation

// MARK: - Count
public extension SQLite3Function.Count {
    
    /// 跟Count有關的Function組合
    enum Function {
        
        case all                            // 所有的數量
        case fields(_ fields: [String])     // 該欄位的數量
        case distinct(_ fields: [String])   // 該欄位未重複的數量
        
        /// 產生SQL語句
        /// - Returns: String
        func sql() -> String {
            
            var sql: String = ""
            
            switch self {
            case .all: sql = "Count(*) as Count"
            case .fields(let fields): sql = fields.map { "Count(\($0)) as \($0)Count" }.joined(separator: ", ")
            case .distinct(let fields): sql = fields.map { "Count(Distinct(\($0))) as \($0)Count" }.joined(separator: ", ")
            }
            
            return sql
        }
        
        /// 產生別名 => as <field>Count
        /// - Parameter field: String
        /// - Returns: String
        func aliasName(with field: String) -> String { return "\(field)Count" }
    }
}
