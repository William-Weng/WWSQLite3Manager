//
//  Having.swift
//  WWSQLite3Manager
//
//  Created by William.Weng on 2026/5/26.
//

import Foundation

public extension WWSQLite3Manager {
    
    /// SQL HAVING 條件建構器
    ///
    /// 用來過濾 `GROUP BY` 之後產生的群組結果
    class Having: Where {
        
        override var clause: String { "HAVING" }
    }
}
