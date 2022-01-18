//
//  SQLiteManager.swift
//  WWSQLite3Manager
//
//  Created by William.Weng on 2022/1/10.
//

import UIKit
import SQLite3

// MARK: - 開啟SQLite3的Manager
open class WWSQLite3Manager: NSObject {
    
    public static let shared: WWSQLite3Manager = WWSQLite3Manager()
    
    /// [建立SQLite連線](https://itisjoe.gitbooks.io/swiftgo/content/database/sqlite.html)
    /// - Parameter fileURL: [URL?](https://gist.github.com/yossan/91079df35609892722f3102246493394)
    /// - Returns: [Result<SQLiteConnect, Error>](https://github.com/itisjoe/swiftgo_files/blob/master/database/sqlite/ExSQLite/ExSQLite/SQLiteConnect.swift)
    public func connent(fileURL: URL?) -> Result<SQLite3Database, Error> {
        
        var database: OpaquePointer? = nil
        
        guard let fileURL = fileURL,
              sqlite3_open(fileURL.absoluteString, &database) == SQLITE_OK,
              let database = database
        else {
            return .failure(Constant.MyError.notOpenURL)
        }
                
        return .success(SQLite3Database(fileURL: fileURL, database: database))
    }
    
    /// [建立SQLite連線 => ~/Documents/OOXX.db](https://www.raywenderlich.com/6620276-sqlite-with-swift-tutorial-getting-started)
    /// - Parameter filename: [String](https://blog.csdn.net/CX_NO1/article/details/86633190)
    /// - Returns: [Result<SQLiteDatabase, Error>](https://www.jianshu.com/p/ce49d8f32f77)
    public func connent(with filename: String) -> Result<SQLite3Database, Error> {
        let fileURL = FileManager.default._documentDirectory()?.appendingPathComponent(filename)
        return connent(fileURL: fileURL)
    }
}
