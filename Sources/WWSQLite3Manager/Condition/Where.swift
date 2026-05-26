//
//  Where.swift
//  WWSQLite3Manager
//
//  Created by William.Weng on 2026/5/26.
//
//  用來以鏈式方式建立 `WHERE` 子句，
//  內部使用 `WhereExpression` 組合成對應的條件樹。
//
//  - Example:
//  ```swift
//  let `where` = WWSQLite3Manager.Where()
//      .compare("age", .greaterThanOrEqual, .int(18))
//      .and("name", .like, .text("%John%"))
//   ```

import Foundation

// MARK: - Where
public extension WWSQLite3Manager {
    
    /// [SQL WHERE 條件建構器](https://www.fooish.com/sql/where.html)
    class Where {
        
        private var expression: WhereExpression?       // 目前累積的 WHERE 條件表達式
                
        public required init() {}
    }
}

// MARK: - 公開屬性
public extension WWSQLite3Manager.Where {
    
    var sqlString: String { makeSqlString() }
}

// MARK: - 公開函式
public extension WWSQLite3Manager.Where {
    
    /// 設定第一個比較條件，或覆蓋目前條件
    @discardableResult
    func compare(_ key: String, _ `operator`: WWSQLite3Manager.CompareOperator, _ value: WWSQLite3Manager.SQLValue) -> Self {
        expression = .compare(key: key, operator: `operator`, value: value)
        return self
    }
    
    /// 以 AND 串接比較條件
    @discardableResult
    func and(_ key: String, _ operator: WWSQLite3Manager.CompareOperator, _ value: WWSQLite3Manager.SQLValue) -> Self {
        append(.compare(key: key, operator: `operator`, value: value), with: .and)
        return self
    }
    
    /// 以 OR 串接比較條件
    @discardableResult
    func or(_ key: String, _ operator: WWSQLite3Manager.CompareOperator, _ value: WWSQLite3Manager.SQLValue) -> Self {
        append(.compare(key: key, operator: `operator`, value: value), with: .or)
        return self
    }
    
    /// 以 NOT 包裝比較條件，並用 AND 串接到目前條件
    @discardableResult
    func not(_ key: String, _ operator: WWSQLite3Manager.CompareOperator, _ value: WWSQLite3Manager.SQLValue) -> Self {
        append(.not(.compare(key: key, operator: `operator`, value: value)), with: .and)
        return self
    }
    
    /// 加入 BETWEEN 條件，預設使用 AND 串接
    @discardableResult
    func between(key: String, from fromValue: WWSQLite3Manager.SQLValue, to toValue: WWSQLite3Manager.SQLValue) -> Self {
        append(.between(key: key, from: fromValue, to: toValue), with: .and)
        return self
    }
    
    /// 以 AND 串接 BETWEEN 條件
    @discardableResult
    func andBetween(key: String, from fromValue: WWSQLite3Manager.SQLValue, to toValue: WWSQLite3Manager.SQLValue) -> Self {
        append(.between(key: key, from: fromValue, to: toValue), with: .and)
        return self
    }
    
    /// 以 OR 串接 BETWEEN 條件
    @discardableResult
    func orBetween(key: String, from fromValue: WWSQLite3Manager.SQLValue, to toValue: WWSQLite3Manager.SQLValue) -> Self {
        append(.between(key: key, from: fromValue, to: toValue), with: .or)
        return self
    }
    
    /// 加入 NOT BETWEEN 條件，預設使用 AND 串接
    @discardableResult
    func notBetween(key: String, from fromValue: WWSQLite3Manager.SQLValue, to toValue: WWSQLite3Manager.SQLValue) -> Self {
        append(.notBetween(key: key, from: fromValue, to: toValue), with: .and)
        return self
    }
    
    /// 加入 LIKE 條件，預設使用 AND 串接
    @discardableResult
    func like(key: String, pattern: String, escape: Character? = nil) -> Self {
        append(.like(key: key, pattern: pattern, escape: escape), with: .and)
        return self
    }
    
    /// 以 AND 串接 LIKE 條件
    @discardableResult
    func andLike(key: String, pattern: String, escape: Character? = nil) -> Self {
        append(.like(key: key, pattern: pattern, escape: escape), with: .and)
        return self
    }
    
    /// 以 OR 串接 LIKE 條件
    @discardableResult
    func orLike(key: String, pattern: String, escape: Character? = nil) -> Self {
        append(.like(key: key, pattern: pattern, escape: escape), with: .or)
        return self
    }
    
    /// 加入 NOT LIKE 條件，預設使用 AND 串接
    @discardableResult
    func notLike(key: String, pattern: String, escape: Character? = nil) -> Self {
        append(.notLike(key: key, pattern: pattern, escape: escape), with: .and)
        return self
    }
    
    /// 以 AND 串接 NOT LIKE 條件
    @discardableResult
    func andNotLike(key: String, condition: String, escape: Character? = nil) -> Self {
        append(.notLike(key: key, pattern: condition, escape: escape), with: .and)
        return self
    }
    
    /// 以 OR 串接 NOT LIKE 條件
    @discardableResult
    func orNotLike(key: String, condition: String, escape: Character? = nil) -> Self {
        append(.notLike(key: key, pattern: condition, escape: escape), with: .or)
        return self
    }
    
    /// 加入 IN 條件，預設使用 AND 串接
    @discardableResult
    func `in`(key: String, values: [WWSQLite3Manager.SQLValue]) -> Self {
        append(.in(key: key, values: values), with: .and)
        return self
    }

    /// 以 AND 串接 IN 條件
    @discardableResult
    func andIn(key: String, values: [WWSQLite3Manager.SQLValue]) -> Self {
        append(.in(key: key, values: values), with: .and)
        return self
    }

    /// 以 OR 串接 IN 條件
    @discardableResult
    func orIn(key: String, values: [WWSQLite3Manager.SQLValue]) -> Self {
        append(.in(key: key, values: values), with: .or)
        return self
    }

    /// 加入 NOT IN 條件，預設使用 AND 串接
    @discardableResult
    func notIn(key: String, values: [WWSQLite3Manager.SQLValue]) -> Self {
        append(.notIn(key: key, values: values), with: .and)
        return self
    }

    /// 以 AND 串接 NOT IN 條件
    @discardableResult
    func andNotIn(key: String, values: [WWSQLite3Manager.SQLValue]) -> Self {
        append(.notIn(key: key, values: values), with: .and)
        return self
    }

    /// 以 OR 串接 NOT IN 條件
    @discardableResult
    func orNotIn(key: String, values: [WWSQLite3Manager.SQLValue]) -> Self {
        append(.notIn(key: key, values: values), with: .or)
        return self
    }
    
    /// 建立包含指定文字的 LIKE 條件 => Example: `name LIKE '%abc%' ESCAPE '\'`
    @discardableResult
    func contains(key: String, _ text: String, escape: Character? = "\\") -> Self {
        let pattern = "%\(escapeLikePattern(text, escape: escape))%"
        append(.like(key: key, pattern: pattern, escape: escape), with: .and)
        return self
    }
    
    /// 建立前綴比對的 LIKE 條件 => Example: `name LIKE 'abc%' ESCAPE '\'`
    @discardableResult
    func startsWith(key: String, _ text: String, escape: Character? = "\\") -> Self {
        let pattern = "\(escapeLikePattern(text, escape: escape))%"
        append(.like(key: key, pattern: pattern, escape: escape), with: .and)
        return self
    }
    
    /// 建立後綴比對的 LIKE 條件 => Example: `name LIKE '%abc' ESCAPE '\'`
    @discardableResult
    func endsWith(key: String, _ text: String, escape: Character? = "\\") -> Self {
        let pattern = "%\(escapeLikePattern(text, escape: escape))"
        append(.like(key: key, pattern: pattern, escape: escape), with: .and)
        return self
    }
    
    /// 建立 AND 群組條件，會將 builder 內建立的條件包成一組括號，並以 AND 串接 => Example: `(age > 18 AND age < 60)`
    @discardableResult
    func andGroup(_ builder: (Self) -> Self) -> Self {
        let groupWhere = builder(.init())
        guard let groupExpression = groupWhere.expression else { return self }
        append(.group(groupExpression), with: .and)
        return self
    }
    
    /// 建立 OR 群組條件，會將 builder 內建立的條件包成一組括號，並以 OR 串接 => Example: `(age > 18 OR age < 60)`
    @discardableResult
    func orGroup(_ builder: (Self) -> Self) -> Self {
        let groupWhere = builder(.init())
        guard let groupExpression = groupWhere.expression else { return self }
        append(.group(groupExpression), with: .or)
        return self
    }
}

// MARK: - 小工具
private extension WWSQLite3Manager.Where {
    
    /// 轉成完整的 SQL WHERE 子句字串 => 若目前沒有任何條件，則回傳空字串
    /// - Returns: String
    func makeSqlString() -> String {
        guard let expression else { return "" }
        return "WHERE \(expression.sqlString)"
    }
    
    /// 將新的條件節點依指定邏輯運算子附加到目前表達式 => 若目前尚無條件，則直接將 rhs 設為根節點
    func append(_ rhs: WWSQLite3Manager.WhereExpression, with joinType: WWSQLite3Manager.JoinType) {
        
        guard let lhs = expression else { expression = rhs; return }
        
        switch joinType {
        case .and: expression = .and(lhs, rhs)
        case .or: expression = .or(lhs, rhs)
        }
    }
    
    /// 跳脫 LIKE 模式字串中的特殊字元 => 以避免使用者輸入被誤判為萬用字元
    /// - Returns: String
    ///
    /// 會處理：
    /// - escape 字元本身
    /// - `%`
    /// - `_`
    func escapeLikePattern(_ string: String, escape: Character?) -> String {
        
        guard let escape else { return string }
        
        let escapeString = String(escape)
        
        return string
            .replacingOccurrences(of: escapeString, with: escapeString + escapeString)
            .replacingOccurrences(of: "%", with: escapeString + "%")
            .replacingOccurrences(of: "_", with: escapeString + "_")
    }
}


