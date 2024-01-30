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
    
    public static let shared: WWSQLite3Manager = WWSQLite3Manager()
}

// MARK: - enum
public extension WWSQLite3Manager {
    
    /// 產生檔案管理資料夾相關的URL
    enum FileDirectoryType {
        
        case documents
        case caches
        case downloads
        case library
        case temporary
        case searchPathDirectory(_ directory: FileManager.SearchPathDirectory)
        case custom(_ path: String)
        
        /// 取得URL
        /// - Returns: URL?
        public func url() -> URL? {
            
            var url: URL?
            
            switch self {
            case .documents: url = FileManager.default._userDirectory(for: .documentDirectory).first
            case .caches: url = FileManager.default._userDirectory(for: .cachesDirectory).first
            case .downloads: url = FileManager.default._userDirectory(for: .downloadsDirectory).first
            case .library: url = FileManager.default._userDirectory(for: .libraryDirectory).first
            case .temporary: url = FileManager.default._temporaryDirectory()
            case .searchPathDirectory(let directory): url = FileManager.default._userDirectory(for: directory).first
            case .custom(let path): url = URL(string: path)
            }
            
            return url
        }
    }
            
    /// [建立SQLite連線](https://itisjoe.gitbooks.io/swiftgo/content/database/sqlite.html)
    /// - Parameter fileURL: [URL?](https://gist.github.com/yossan/91079df35609892722f3102246493394)
    /// - Returns: [Result<SQLiteConnect, Error>](https://github.com/itisjoe/swiftgo_files/blob/master/database/sqlite/ExSQLite/ExSQLite/SQLiteConnect.swift)
    func connent(fileURL: URL?) -> Result<SQLite3Database, Error> {
        
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
    /// - Returns: [Result<SQLiteDatabase, Error>](https://www.jianshu.com/p/ce49d8f32f77)
    /// - Parameters:
    ///   - directoryType: [Constant.FileManagerDirectoryType](https://blog.csdn.net/CX_NO1/article/details/86633190)
    ///   - filename: String
    func connent(for directoryType: FileDirectoryType = .documents, filename: String) -> Result<SQLite3Database, Error> {
        let fileURL = directoryType.url()?.appendingPathComponent(filename)
        return connent(fileURL: fileURL)
    }
}
