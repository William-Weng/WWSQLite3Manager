//
//  ViewController.swift
//  Example
//
//  Created by William.Weng on 2022/01/01.
//

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
