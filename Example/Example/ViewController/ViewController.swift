//
//  ViewController.swift
//  Example
//
//  Created by William.Weng on 2022/01/01.
//

import UIKit
import WWSQLite3Manager

final class ViewController: UIViewController {
    
    @IBOutlet weak var sqlTextView: UITextView!
    @IBOutlet weak var resultTextView: UITextView!
    
    private let databaseName = "sqlite3.db"
    private let tableName = "students"
    
    private var database: SQLite3Database?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /// 連接資料庫
    @IBAction func connentDatabase(_ sender: UIBarButtonItem) {
        
        let result = WWSQLite3Manager.shared.connect(for: .documents, filename: databaseName)
        
        switch result {
        case .failure(let error):
            displayText(sql: nil, result: error)
        case .success(let database):
            self.database = database
            displayText(sql: nil, result: database.fileURL)
        }
    }
    
    /// 關閉資料庫
    @IBAction func closeDatabase(_ sender: UIBarButtonItem) {
        
        guard let database = database,
              database.close()
        else {
            displayText(sql: nil, result: "Database Close Fail."); return
        }
        
        displayText(sql: nil, result: "Database Close Success.")
    }
    
    /// 刪除資料表
    @IBAction func dropTable(_ sender: UIBarButtonItem) {
        
        guard let database = database else { displayText(sql: nil, result: "Database Drop Fail."); return }
        
        let result = database.drop(tableName: tableName)
        displayText(sql: result.sql, result: result.isSussess)
    }
    
    /// 建立資料表
    @IBAction func createTable(_ sender: UIBarButtonItem) {
        
        guard let database = database else { displayText(sql: nil, result: "Database Create Fail."); return }
        
        let result = database.create(tableName: tableName, type: Student.self, isOverwrite: false)
        displayText(sql: result.sql, result: result.isSussess)
    }
    
    /// 資料表插入數據
    @IBAction func insertData(_ sender: UIButton) {
        
        guard let database = database,
              let itemsArray = Optional.some((1...5).map { _ in randomItems() }),
              let result = database.insert(tableName: tableName, itemsArray: itemsArray)
        else {
            displayText(sql: nil, result: "Database Insert Fail."); return
        }
        
        displayText(sql: result.sql, result: result.isSussess)
    }
    
    /// 資料表的屬性
    @IBAction func tableScheme(_ sender: UIButton) {
        
        guard let database = database else { displayText(sql: nil, result: "Database Scheme Fail."); return }
        
        let result = database.tableScheme(tableName: tableName)
        displayText(sql: result.sql, result: result.array)
    }
    
    /// 更新資料
    @IBAction func updateData(_ sender: UIButton) {
        
        guard let database = database else { displayText(sql: nil, result: "Database Update Fail."); return }
        
        let condition = SQLite3Condition.Where().isCompare(type: .equal(key: "id", value: "1"))
        let result = database.update(tableName: tableName, items: randomItems(), where: condition)
        
        displayText(sql: result.sql, result: result.isSussess)
    }
    
    /// 刪除資料
    @IBAction func deleteData(_ sender: UIButton) {
        
        guard let database = database else { displayText(sql: nil, result: "Database Insert Fail."); return }
        
        let condition = SQLite3Condition.Where().isCompare(type: .equal(key: "id", value: "1"))
        let result = database.delete(tableName: tableName, where: condition)
        
        displayText(sql: result.sql, result: result.isSussess)
    }
    
    /// 搜尋資料
    @IBAction func selectData(_ sender: UIButton) {
        
        guard let database = database else { displayText(sql: nil, result: "Database Select Fail."); return }
        
        let condition = SQLite3Condition.Where().like(key: "name", condition: "William%").andCompare(type: .greaterOrEqual(key: "height", value: 165))
        let orderBy = SQLite3Condition.OrderBy().item(type: .ascending(key: "height")).addItem(type: .descending(key: "time"))
        let limit = SQLite3Condition.Limit().build(count: 3, offset: 5)
        let result = database.select(tableName: tableName, type: Student.self, where: condition, orderBy: orderBy, limit: limit)
        
        displayText(sql: result.sql, result: result.array)
    }
}

// MARK: - 小工具
private extension ViewController {
    
    /// 顯示文字
    /// - Parameter text: String?
    func displayText(sql: String?, result: Any) {
        sqlTextView.text = sql
        resultTextView.text = "\(result)"
    }
    
    /// 測試用數據
    /// - Returns: [SQLite3Database.InsertItem]
    func randomItems() -> [SQLite3Database.InsertItem] {
        
        let items: [SQLite3Database.InsertItem] = [
            (key: "name", value: "William_\(Int.random(in: 0...100))"),
            (key: "height", value: 160.0 + Float.random(in: 0...20)),
        ]
        
        return items
    }
}
