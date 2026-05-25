//
//  SQLiteManager.swift
//  WWSQLite3Manager
//
//  Created by William.Weng on 2022/1/10.
//

import UIKit
import SQLite3

// MARK: - SQLite3管理器
open class WWSQLite3Manager: NSObject {
    
    public static let shared: WWSQLite3Manager = .init()
}

// MARK: - 公開function
public extension WWSQLite3Manager {
    
    /// [建立SQLite連線](https://itisjoe.gitbooks.io/swiftgo/content/database/sqlite.html)
    /// - Parameter fileURL: [URL?](https://gist.github.com/yossan/91079df35609892722f3102246493394)
    /// - Returns: [Result<SQLiteConnect, Error>](https://github.com/itisjoe/swiftgo_files/blob/master/database/sqlite/ExSQLite/ExSQLite/SQLiteConnect.swift)
    func connect(fileURL: URL?) -> Result<Database, CustomError> {
        
        var database: OpaquePointer? = nil
        
        guard let fileURL = fileURL,
              sqlite3_open(fileURL.absoluteString, &database) == SQLITE_OK,
              let database = database
        else {
            return .failure(.notOpenURL)
        }
        
        return .success(.init(fileURL: fileURL, database: database))
    }
    
    /// [建立SQLite連線 => ~/Documents/OOXX.db](https://www.raywenderlich.com/6620276-sqlite-with-swift-tutorial-getting-started)
    /// - Returns: [Result<SQLiteDatabase, Error>](https://www.jianshu.com/p/ce49d8f32f77)
    /// - Parameters:
    ///   - directory: [URL](https://chaocode.co/blog/getting-url)
    ///   - filename: String
    func connect(for directory: URL = .applicationSupportDirectory, filename: String) -> Result<Database, CustomError> {
        let fileURL = directory.appending(path: filename)
        return connect(fileURL: fileURL)
    }
}
