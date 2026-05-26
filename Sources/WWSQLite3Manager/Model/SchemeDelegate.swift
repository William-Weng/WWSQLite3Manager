//
//  SQLite3SchemeDelegate.swift
//  WWSQLite3Manager
//
//  Created by William.Weng on 2022/1/11.
//

import UIKit

// MARK: - SchemeDelegate
public extension WWSQLite3Manager {
    
    /// 建立資料庫的欄位 / 主鍵設定
    protocol SchemeDelegate {
        
        static func structure() -> [SchemeColumn]               // 欄位結構順序
    }
}


