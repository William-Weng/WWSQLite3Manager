//
//  Model.swift
//  Example
//
//  Created by William.Weng on 2022/1/14.
//

import Foundation
import WWSQLite3Manager

final class Student: Codable {
    
    let id: Int
    let name: String
    let height: Double
    let image: Data?
    let time: Date?
}

// MARK: - SQLite3SchemeDelegate
extension Student: WWSQLite3Manager.SchemeDelegate {
    
    static func structure() -> [WWSQLite3Manager.SchemeColumn] {
        
        let keyTypes: [WWSQLite3Manager.SchemeColumn] = [
            (key: "id", type: .INTEGER()),
            (key: "name", type: .TEXT(attribute: (isNotNull: true, isNoCase: true, isUnique: true), defaultValue: nil)),
            (key: "height", type: .REAL()),
            (key: "image", type: .BLOB()),
            (key: "time", type: .TIMESTAMP()),
        ]
        
        return keyTypes
    }
}
