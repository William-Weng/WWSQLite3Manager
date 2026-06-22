//
//  SqliteMaster.swift
//  WWSQLite3Manager
//
//  Created by iOS on 2026/6/22.
//

import Foundation

// MARK: - TableScheme
extension WWSQLite3Manager {
    
    /// SQL資料表訊息模型
    struct SqliteMaster: Codable {
        
        let type: String
        let name: String
        let tablename: String
        let rootpage: Int
        let sql: String
        
        /// 變數名稱 = SQL欄位名稱
        enum CodingKeys: String, CodingKey {
            
            case type = "type"
            case name = "name"
            case tablename = "tbl_name"
            case rootpage = "rootpage"
            case sql = "sql"
        }
    }
}

// MARK: - SchemeDelegate
extension WWSQLite3Manager.SqliteMaster: WWSQLite3Manager.SchemeDelegate {
    
    /// 用來初始化SQL的表結構
    /// - Returns: WWSQLite3Manager.SchemeColumn
    static func structure() -> [WWSQLite3Manager.SchemeColumn] {
        [
            (key: "type", type: .TEXT(attribute: (isNotNull: true, isNoCase: true, isUnique: true), defaultValue: nil)),
            (key: "name", type: .TEXT(attribute: (isNotNull: true, isNoCase: true, isUnique: true), defaultValue: nil)),
            (key: "tbl_name", type: .TEXT(attribute: (isNotNull: true, isNoCase: true, isUnique: true), defaultValue: nil)),
            (key: "rootpage", type: .INTEGER(attribute: (isNotNull: true, isNoCase: true, isUnique: false), defaultValue: 0)),
            (key: "sql", type: .TEXT(attribute: (isNotNull: true, isNoCase: true, isUnique: true), defaultValue: nil)),
        ]
    }
}
