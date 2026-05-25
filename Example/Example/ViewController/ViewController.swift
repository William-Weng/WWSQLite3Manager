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
    
    private var database: WWSQLite3Manager.Database?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /// 連接資料庫
    @IBAction func connentDatabase(_ sender: UIBarButtonItem) {
        
        do {
            let database = try WWSQLite3Manager.shared.connect(for: .documentsDirectory, filename: databaseName)
            self.database = database
            displayText(sql: nil, result: "connected")
        } catch {
            displayText(sql: nil, result: error)
        }
    }
    
    /// 關閉資料庫
    @IBAction func closeDatabase(_ sender: UIBarButtonItem) {
        
        guard let database = database else { return }
        
        do {
            try database.close()
            displayText(sql: nil, result: "closed")
        } catch {
            displayText(sql: nil, result: error)
        }
    }
    
    /// 刪除資料表
    @IBAction func dropTable(_ sender: UIBarButtonItem) {
        
        guard let database = database else { return }
        
        do {
            let sql = try database.drop(tableName: tableName)
            displayText(sql: sql, result: "")
        } catch {
            displayText(sql: nil, result: error)
        }
    }
    
    /// 建立資料表
    @IBAction func createTable(_ sender: UIBarButtonItem) {
        
        guard let database = database else { return }
        
        do {
            let sql = try database.create(tableName: tableName, type: Student.self)
            displayText(sql: sql, result: "")
        } catch {
            displayText(sql: nil, result: error)
        }
    }
    
    /// 資料表插入數據
    @IBAction func insertData(_ sender: UIButton) {
        
        guard let database = database else { return }
        
        let itemsArray = (1...5).map { _ in randomItems() }
        
        do {
            let sql = try database.insert(tableName: tableName, itemsArray: itemsArray)
            displayText(sql: sql, result: "")
        } catch {
            displayText(sql: nil, result: error)
        }
    }
    
    /// 資料表的屬性
    @IBAction func tableScheme(_ sender: UIButton) {
        
        guard let database = database else { displayText(sql: nil, result: "Database Scheme Fail."); return }
        
        let result = database.tableScheme(tableName: tableName)
        displayText(sql: result.sql, result: result.array)
    }
    
    /// 更新資料
    @IBAction func updateData(_ sender: UIButton) {}
    
    /// 刪除資料
    @IBAction func deleteData(_ sender: UIButton) {}
    
    /// 搜尋資料
    @IBAction func selectData(_ sender: UIButton) {}
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
    func randomItems() -> [WWSQLite3Manager.InsertItem] {
        
        let items: [WWSQLite3Manager.InsertItem] = [
            (key: "name", value: "William_\(Int.random(in: 0...100))"),
            (key: "height", value: 160.0 + Float.random(in: 0...20)),
        ]
        
        return items
    }
}
