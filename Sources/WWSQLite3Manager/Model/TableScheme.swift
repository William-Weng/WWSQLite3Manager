//
//  SQLite3TableSchemeInfomation.swift
//  WWSQLite3Manager
//
//  Created by William.Weng on 2022/1/17.
//

import UIKit

// MARK: - TableScheme
extension WWSQLite3Manager {
    
    class TableScheme: Codable, WWSQLite3Manager.SchemeDelegate {
        
        let cid: Int
        let name: String
        let type: String
        let notNull: Int
        let defaultVaule: String?
        let primaryKey: Int
        
        /// 變數名稱 = SQL欄位名稱
        enum CodingKeys: String, CodingKey {
            
            case cid = "cid"
            case name = "name"
            case type = "type"
            case notNull = "notnull"
            case defaultVaule = "dflt_value"
            case primaryKey = "pk"
        }
    }
}

// MARK: - SQLite3TableScheme
extension WWSQLite3Manager.TableScheme {
    
    /// [SQL欄位順序結構 => CREATE時使用](https://jjeremy-xue.medium.com/swift-說說-codable-decodable-encodable-594b28ff3d49)
    /// - Returns: [SelectColumn]
    static func structure() -> [WWSQLite3Manager.SchemeColumn] {
        
        let keyTypes: [WWSQLite3Manager.SchemeColumn] = [
            (key: "cid", type: .INTEGER()),
            (key: "name", type: .TEXT()),
            (key: "type", type: .TEXT()),
            (key: "notnull", type: .INTEGER()),
            (key: "dflt_value", type: .TEXT()),
            (key: "pk", type: .INTEGER()),
        ]
        
        return keyTypes
    }
}
