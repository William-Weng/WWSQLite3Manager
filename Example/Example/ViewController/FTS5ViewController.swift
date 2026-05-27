//
//  FTS5ViewController.swift
//  Example
//
//  Created by William.Weng on 2026/05/27.
//

import UIKit
import WWSQLite3Manager

final class FTS5ViewController: UIViewController {
        
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
            try demo.run()
            try demo.testUpdateAndDelete()
            
            try database.close()
            
        } catch {
            print(error)
        }
    }
}
