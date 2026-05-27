//
//  ViewController.swift
//  Example
//
//  Created by William.Weng on 2026/05/27.
//

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
