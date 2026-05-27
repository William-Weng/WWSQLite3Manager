# WWSQLite3Manager

[![Swift-5.7](https://img.shields.io/badge/Swift-5.7-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![iOS-16.0](https://img.shields.io/badge/iOS-16.0-pink.svg?style=flat)](https://developer.apple.com/swift/)
![Version](https://img.shields.io/github/v/tag/William-Weng/WWSQLite3Manager)
[![Swift Package Manager-SUCCESS](https://img.shields.io/badge/Swift_Package_Manager-SUCCESS-blue.svg?style=flat)](https://developer.apple.com/swift/)
[![LICENSE](https://img.shields.io/badge/LICENSE-MIT-yellow.svg?style=flat)](https://developer.apple.com/swift/)

[English](./README.en.md) | [繁體中文](./README.md)

## 🎉 相關說明

一套輕量級的 Swift SQLite3 工具，讓資料表定義、CRUD、條件查詢，以及聚合查詢都更直覺、更容易維護。

---

## ✨ 功能特色

- 透過 `SchemeDelegate` 定義資料表結構，讓欄位與型別管理更明確。
- 提供 `create`、`drop`、`insert`、`update`、`delete`、`select` 等常用操作 API。
- 支援可鏈式組合的 `Where`、`GroupBy`、`Having`、`OrderBy`、`Limit`，讓 SQL 更容易閱讀。
- 同時支援以 schema 為基礎的全欄位查詢，以及使用 `SelectMethod` 的自訂欄位查詢。
- 需要較底層控制時，也可以直接執行原生 SQL。

---

## 🧠 設計說明

這個套件的設計重點之一，是把資料表 schema 與查詢欄位投影分開。

- `SchemeDelegate.structure()` 用在建表與全欄位查詢。
- `SelectMethod` 用在查詢階段的欄位投影，例如聚合函數與別名。
- 比起直接依賴 `SELECT *`，明確列出欄位通常更容易控管，也更適合長期維護。

## 📦 安裝方式

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/William-Weng/WWSQLite3Manager.git", .upToNextMajor(from: "2.2.2"))
]
```

```swift
https://github.com/William-Weng/WWSQLite3Manager.git
```

---

## 🛠️ 公開 API

| API | 說明 |
|---|---|
| `connect(fileURL:)` | 建立 SQLite 連線。 |
| `connect(for:filename:)` | 使用指定位置與檔名建立 SQLite 連線。 |
| `execute(sql:)` | 直接執行原生 SQL。 |
| `prepare(sql:)` | 預備並執行 SQL 語句。 |
| `query(sql:result:completion:)` | 執行原生 `SELECT` 查詢。 |
| `close()` | 關閉目前的 SQLite 連線。 |
| `scheme(tableName:)` | 讀取指定資料表的結構資訊。 |
| `create(tableName:type:primaryKeys:ifNotExists:)` | 依 schema 定義建立資料表。 |
| `drop(tableName:ifExists:)` | 刪除資料表。 |
| `transaction(type:)` | 在 transaction 範圍內執行 SQL。 |
| `insert(tableName:itemsArray:)` | 執行 `INSERT` 查詢。 |
| `update(tableName:items:where:)` | 執行 `UPDATE` 查詢。 |
| `delete(tableName:where:)` | 執行 `DELETE` 查詢。 |
| `select(tableName:type:where:groupBy:having:orderBy:limit:)` | 執行以 schema 為基礎的 `SELECT` 查詢。 |
| `select(tableName:methods:where:groupBy:having:orderBy:limit:)` | 執行自訂欄位投影的 `SELECT` 查詢。 |
| `begin(type:)` | 依指定模式開始 transaction。 |
| `commit()` | 提交目前 transaction 的所有變更。 |
| `rollback()` | 回滾目前 transaction 中尚未提交的變更。 |
| `transaction(type:_:)` | 在 block 內執行 transaction，成功時自動提交，失敗時自動回滾。 |

---

## 🚀 基本範例

### 1. 定義資料模型與資料表結構

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

extension Student: WWSQLite3Manager.SchemeDelegate {
    
    static func structure() -> [WWSQLite3Manager.SchemeColumn] {
        [
            (key: "id", type: .INTEGER()),
            (key: "name", type: .TEXT(attribute: (isNotNull: true, isNoCase: true, isUnique: true), defaultValue: nil)),
            (key: "height", type: .REAL()),
            (key: "image", type: .BLOB()),
            (key: "time", type: .TIMESTAMP()),
        ]
    }
}
```

### 2. 連線、建表、寫入與查詢

```swift
import UIKit
import WWSQLite3Manager

final class ViewController: UIViewController {
    
    @IBOutlet weak var sqlLabel: UILabel!
    @IBOutlet weak var resultLabel: UILabel!
    
    private let filename = "sqlite3.db"
    private let tableName = "students"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            let database = try WWSQLite3Manager.shared.connect(filename: filename)
            
            try database.drop(tableName: tableName, ifExists: true)
            try database.create(tableName: tableName, type: Student.self, ifNotExists: true)
            
            let items: [WWSQLite3Manager.InsertItem] = [
                (key: "name", value: "William.Weng"),
                (key: "height", value: 180.87),
            ]
            
            let `where`: WWSQLite3Manager.Where = .init()
                .compare("height", .greaterThanOrEqual, .int(180))
                .and("name", .like, .text("%William%"))
            
            try database.insert(tableName: tableName, itemsArray: [items])
            let result = database.select(tableName: tableName, type: Student.self, where: `where`)
            
            sqlLabel.text = result.sql
            resultLabel.text = String(describing: result.array)
            
        } catch {
            print(error)
        }
    }
}
```

---

## 🧠 查詢條件建構器

這個套件提供多種 builder，讓 Swift 端組 SQL 時更好閱讀。

### Where

```swift
let `where`: WWSQLite3Manager.Where = .init()
    .compare("height", .greaterThanOrEqual, .int(180))
    .and("name", .like, .text("%William%"))
```

### GroupBy

```swift
let groupBy = WWSQLite3Manager.GroupBy().build(keys: ["department"])
```

### Having

```swift
let having = WWSQLite3Manager.Having()
    .compare("COUNT(*)", .greaterThan, .int(3))
```

### OrderBy

```swift
let orderBy = WWSQLite3Manager.OrderBy().build(orderTypes: [
    (key: "height", direction: .desc),
    (key: "name", direction: .asc)
])
```

### Limit

```swift
let limit = WWSQLite3Manager.Limit().build(count: 20, offset: 0)
```

---

## 🍤 SelectMethod 自訂查詢欄位範例

當查詢結果不是整張表的原始欄位，而是聚合函數、別名或自訂欄位投影時，建議使用 `select(tableName:methods:...)`。

```swift
let methods: [WWSQLite3Manager.SelectMethod] = [
    .column("name", .text),
    .count(nil, .int, aliasName: "totalCount"),
    .avg("height", .double, aliasName: "averageHeight")
]

let groupBy = WWSQLite3Manager.GroupBy().build(key: "name")
let having = WWSQLite3Manager.Having().compare("COUNT(*)", .greaterThan, .int(0))

let result = database.select(
    tableName: tableName,
    methods: methods,
    groupBy: groupBy,
    having: having
)

print(result.sql)
print(result.array)
```

建議使用方式：

- `select(tableName:type:...)`：適合依照 schema 查詢完整欄位。
- `select(tableName:methods:...)`：適合聚合查詢、別名欄位與自訂查詢結果。

