# WWSQLite3Manager

[![Swift-5.7](https://img.shields.io/badge/Swift-5.7-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![iOS-16.0](https://img.shields.io/badge/iOS-16.0-pink.svg?style=flat)](https://developer.apple.com/swift/)
![Version](https://img.shields.io/github/v/tag/William-Weng/WWSQLite3Manager)
[![Swift Package Manager-SUCCESS](https://img.shields.io/badge/Swift_Package_Manager-SUCCESS-blue.svg?style=flat)](https://developer.apple.com/swift/)
[![LICENSE](https://img.shields.io/badge/LICENSE-MIT-yellow.svg?style=flat)](https://developer.apple.com/swift/)

[English](./README.en.md) | [繁體中文](./README.md)

https://github.com/user-attachments/assets/4b604592-2895-4552-9c5a-1e2cb57d5b77

---

## 🎉 Overview

A lightweight SQLite3 helper for Swift that makes schema definition, CRUD, conditional queries, and aggregate selection easier to read and maintain.

---

## ✨ Features

- Define table schema with `SchemeDelegate` for explicit and type-safe table structure management.
- Use simple APIs for `create`, `drop`, `insert`, `update`, `delete`, and `select` operations.
- Support chainable `Where`, `GroupBy`, `Having`, `OrderBy`, and `Limit` builders for readable SQL construction.
- Support both schema-based full-column queries and `SelectMethod`-based custom projection queries.
- Execute raw SQL directly when lower-level control is needed.

---

## 🧠 Design Notes

One of the package's key design ideas is to separate table schema definition from query projection.

- `SchemeDelegate.structure()` is used for table creation and full-column selection.
- `SelectMethod` is used for query-time projection such as aggregate functions and aliases.
- Explicit column lists are easier to control than relying on `SELECT *`, especially when schema evolves.

---

## 📦 Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/William-Weng/WWSQLite3Manager.git", .upToNextMajor(from: "2.3.0"))
]
```

```swift
https://github.com/William-Weng/WWSQLite3Manager.git
```

---

## 🛠️ Public APIs

| API (WWSQLite3Manager) | Description |
|---|---|
| `connect(fileURL:)` | Create a SQLite connection. |
| `connect(for:filename:)` | Create a SQLite connection with a target location and filename. |

| API (Database) | Description |
|---|---|
| `execute(sql:)` | Execute raw SQL directly. |
| `prepare(sql:)` | Prepare and execute SQL statements. |
| `select(sql:result:completion:)` | Execute a raw `SELECT` query. |
| `close()` | Close the current SQLite connection. |
| `scheme(tableName:)` | Read the schema information of a table. |
| `create(tableName:type:primaryKeys:ifNotExists:)` | Create a table from a schema definition. |
| `drop(tableName:ifExists:)` | Drop a table. |
| `transaction(type:)` | Execute SQL in a transaction scope. |
| `insert(tableName:itemsArray:)` | Execute an `INSERT` query. |
| `update(tableName:items:where:)` | Execute an `UPDATE` query. |
| `delete(tableName:where:)` | Execute a `DELETE` query. |
| `select(tableName:type:where:groupBy:having:orderBy:limit:)` | Execute a schema-based `SELECT` query. |
| `select(tableName:methods:where:groupBy:having:orderBy:limit:)` | Execute a custom projection `SELECT` query. |
| `begin(type:)` | Begin a transaction with the specified mode. |
| `commit()` | Commit all changes in the current transaction. |
| `rollback()` | Roll back all uncommitted changes in the current transaction. |
| `transaction(type:_:)` | Execute work inside a transaction block with automatic commit or rollback. |
| `begin(type:)` | Begin a transaction using the specified mode. |
| `commit()` | Commit all changes in the current transaction. |
| `rollback()` | Roll back all uncommitted changes in the current transaction. |
| `transaction(type:_:)` | Execute work inside a transaction block, automatically committing on success and rolling back on failure. |

---

## 🚀 Basic Example

### 1. Define a model and schema

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

### 2. Connect, create, insert, and query

```swift
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
                (key: "name", value: .string("William.Weng")),
                (key: "height", value: .double(180.87)),
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

### 3. FTS5 query functionality

```swift
import UIKit
import WWSQLite3Manager

final class FTS5ViewController: UIViewController {
    
    @IBOutlet weak var resultLabel: UILabel!
    
    private let filename = "fts5.db"
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        do {
            let fileURL = URL.documentsDirectory.appendingPathComponent(filename)
                        
            if FileManager.default.fileExists(atPath: fileURL.path()) {
                try FileManager.default.removeItem(at: fileURL)
            }
            
            let database = try WWSQLite3Manager.shared.connect(fileURL: fileURL)
            
            let demo = FTS5Demo(database: database)
            let text1 = try demo.run()
            let text2 = try demo.testUpdateAndDelete()
            
            resultLabel.text = "\([text1, text2].flatMap { $0 }))"
            
            try database.close()
            
        } catch {
            print(error)
        }
    }
}
```

---

## 🧠 Query Builders

The library provides builder objects to make SQL composition easier to read in Swift code.

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

## 🍤 SelectMethod Example

Use `select(tableName:methods:...)` when the query result is not the full table schema, such as aggregate queries, aliases, and custom projections.

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

Recommended usage pattern:

- Use `select(tableName:type:...)` for full-column queries based on schema.
- Use `select(tableName:methods:...)` for aggregates, aliases, and custom result columns.

