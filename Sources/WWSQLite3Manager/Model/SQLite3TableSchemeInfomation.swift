//
//  SQLite3TableSchemeInfomation.swift
//  WWSQLite3Manager
//
//  Created by William.Weng on 2022/1/17.
//

import UIKit

// [取得該Table表的結構](https://jjeremy-xue.medium.com/swift-說說-codable-decodable-encodable-594b28ff3d49)
open class SQLite3TableSchemeInfomation: Codable {
    
    public let cid: Int
    public let name: String
    public let type: String
    public let notNull: Int
    public let defaultVaule: String?
    public let primaryKey: Int
    
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

// MARK: - SQLite3SchemeDelegate
extension SQLite3TableSchemeInfomation: SQLite3SchemeDelegate {
    
    /// SQL欄位順序結構 => CREATE時使用
    public static func structure() -> [(key: String, type: SQLite3Condition.DataType)] {
        
        let keyTypes: [(key: String, type: SQLite3Condition.DataType)] = [
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

