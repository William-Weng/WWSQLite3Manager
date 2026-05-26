# WWSQLite3Manager

[![Swift-5.7](https://img.shields.io/badge/Swift-5.7-orange.svg?style=flat)](https://developer.apple.com/swift/) [![iOS-16.0](https://img.shields.io/badge/iOS-16.0-pink.svg?style=flat)](https://developer.apple.com/swift/) ![](https://img.shields.io/github/v/tag/William-Weng/WWSQLite3Manager) [![Swift Package Manager-SUCCESS](https://img.shields.io/badge/Swift_Package_Manager-SUCCESS-blue.svg?style=flat)](https://developer.apple.com/swift/) [![LICENSE](https://img.shields.io/badge/LICENSE-MIT-yellow.svg?style=flat)](https://developer.apple.com/swift/)

### [Introduction - 簡介](https://swiftpackageindex.com/William-Weng)
- A small tool for SQLite3 that makes basic [CRUD](https://zh.wikipedia.org/zh-tw/增刪查改) easier to use.
- 一個SQLite3的小工具，讓基本的[CRUD](https://zh.wikipedia.org/zh-tw/增刪查改)能更方便的使用.

### [Installation with Swift Package Manager](https://medium.com/彼得潘的-swift-ios-app-開發問題解答集/使用-spm-安裝第三方套件-xcode-11-新功能-2c4ffcf85b4b)
```
dependencies: [
    .package(url: "https://github.com/William-Weng/WWSQLite3Manager.git", .upToNextMajor(from: "2.0.1"))
]
```

### 公開函式

|函式|功能|
|---|---|
|connect(fileURL:)|建立SQLite連線|
|connect(for:filename:)|建立SQLite連線|
|execute(sql:)|直讀SQL|
|prepare(sql:)|執行SQL語句|
|select(sql:result:completion:)|執行SELECT SQL|
|close()|關閉SQLite連線|
|scheme(tableName:)|取得該Table的結構組成|
|create(tableName:type:primaryKeys:ifNotExists:)|建立資料表|
|drop(tableName:ifExists:)|刪除資料表|
|transaction(type:)|事務處理|
|insert(tableName:itemsArray:)|執行 INSERT 查詢|
|update(tableName:items:where:)|執行 UPDATE 查詢|
|delete(tableName:where:groupBy:having:orderBy:limit:)|執行 DELETE 查詢|
|select(tableName:type:where:)|執行 SELECT 查詢|

### Example
```swift
import Foundation
import WWSQLite3Manager

final class Student: Codable {
    
    let id: Int
    let name: String
    let height: Double
    let image: Data?
    let time: Date?
}

extension Student: SQLite3SchemeDelegate {
    
    static func structure() -> [(key: String, type: SQLite3Condition.DataType)] {
        
        let keyTypes: [(key: String, type: SQLite3Condition.DataType)] = [
            (key: "id", type: .INTEGER()),
            (key: "name", type: .TEXT(attribute: (isNotNull: true, isNoCase: true, isUnique: true), defaultValue: nil)),
            (key: "height", type: .REAL()),
            (key: "image", type: .BLOB()),
            (key: "time", type: .TIMESTAMP()),
        ]
        
        return keyTypes
    }
}
```

```swift
import UIKit
import WWSQLite3Manager

final class ViewController: UIViewController {
        
    private let filename = "sqlite3.db"
    private let tableName = "students"
    
    private var database: WWSQLite3Manager.Database!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            let database = try WWSQLite3Manager.shared.connect(filename: filename)
            try database.drop(tableName: tableName)
            try database.create(tableName: tableName, type: Student.self, ifNotExists: true)
            
            self.database = database
            print(database.fileURL)

            let items: [WWSQLite3Manager.InsertItem] = [
                (key: "name", value: "William.Weng"),
                (key: "height", value: 180.87),
            ]
            
            let `where` = WWSQLite3Manager.Where()
                .compare("height", .greaterThanOrEqual, .int(180))
                .and("name", .like, .text("%William%"))
            
            try database.insert(tableName: tableName, itemsArray: [items])
            let info = database.select(tableName: tableName, type: Student.self, where: `where`)
            print(info.array)
            
        } catch {
            print(error)
        }
    }
}
```
