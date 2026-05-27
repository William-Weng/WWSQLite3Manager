//
//  FTS5ViewController.swift
//  Example
//
//  Created by William.Weng on 2026/05/27.
//

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
