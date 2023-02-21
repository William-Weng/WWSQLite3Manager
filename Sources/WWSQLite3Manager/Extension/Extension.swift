//
//  Extension.swift
//  SQLite3SchemeDelegate
//
//  Created by William.Weng on 2022/1/14.
//

import Foundation
import SQLite3

public extension OpaquePointer {
    
    /// 取得資料庫的數據
    /// - Parameters:
    ///   - column: 第幾列？
    ///   - dataType: 類型
    /// - Returns: Any?
    func _value(at column: Int32, dataType: SQLite3Condition.DataType) -> Any? {
        
        switch dataType {
        case .INTEGER: return self._Int32(at: column)
        case .REAL: return self._Double(at: column)
        case .BLOB: return self._Blob(at: column)
        case .TEXT: return self._String(at: column)
        case .NUMERIC: return self._String(at: column)
        case .TIMESTAMP: return self._String(at: column)
        }
    }
}

// MARK: - OpaquePointer (class function)
extension OpaquePointer {
    
    /// SQLite指標 => Int32
    /// - Parameter column: Int32
    /// - Returns: Int32
    func _Int32(at column: Int32) -> Int32 { return sqlite3_column_int(self, column) }
    
    /// SQLite指標 => Int64
    /// - Parameter column: Int32
    /// - Returns: Int64
    func _Int64(at column: Int32) -> Int64 { return sqlite3_column_int64(self, column) }
    
    /// SQLite指標 => Double
    /// - Parameter column: Int32
    /// - Returns: Double
    func _Double(at column: Int32) -> Double { return sqlite3_column_double(self, column) }
    
    /// SQLite指標 => String
    /// - Parameter column: Int32
    /// - Returns: String?
    func _String(at column: Int32) -> String? {
        guard let cString = sqlite3_column_text(self, column) else { return nil }
        return String(cString: cString)
    }
    
    /// [SQLite指標 => Blob => Data](https://stackoverflow.com/questions/28297970/read-blob-data-extra-argument-bytes-in-call-swift)
    /// - Parameter column: Int32
    /// - Returns: Data?
    func _Blob(at column: Int32) -> Data? {
        
        guard let bytes = sqlite3_column_blob(self, column),
              let count = Optional.some(Int(sqlite3_column_bytes(self, column)))
        else {
            return nil
        }
        
        return Data(bytes: bytes, count: count)
    }
}

// MARK: - Collection (override class function)
extension Collection {

    /// [為Array加上安全取值特性 => nil](https://stackoverflow.com/questions/25329186/safe-bounds-checked-array-lookup-in-swift-through-optional-bindings)
    subscript(safe index: Index) -> Element? { return indices.contains(index) ? self[index] : nil }
}

// MARK: - Array (class function)
extension Array {
    
    /// [仿javaScript的forEach()](https://developer.mozilla.org/zh-TW/docs/Web/JavaScript/Reference/Global_Objects/Array/forEach)
    /// - Parameter forEach: (Int, Element, Self)
    func _forEach(_ forEach: (Int, Element, Self) -> Void) {
                
        for (index, object) in self.enumerated() {
            forEach(index, object, self)
        }
    }
}

// MARK: - FileManager (class function)
extension FileManager {
    
    /// [取得User的資料夾](https://cdfq152313.github.io/post/2016-10-11/)
    /// - UIFileSharingEnabled = YES => iOS設置iTunes文件共享
    /// - Parameter directory: User的資料夾名稱
    /// - Returns: [URL]
    func _userDirectory(for directory: FileManager.SearchPathDirectory) -> [URL] { return Self.default.urls(for: directory, in: .userDomainMask) }

    /// User的「文件」資料夾URL
    /// - => ~/Documents (UIFileSharingEnabled)
    /// - Returns: URL?
    func _documentDirectory() -> URL? { return self._userDirectory(for: .documentDirectory).first }
}
