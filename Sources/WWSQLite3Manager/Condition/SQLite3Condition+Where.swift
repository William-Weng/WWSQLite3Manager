//
//  SQLite3Condition.Where.swift
//  WWSQLite3Manager
//
//  Created by William.Weng on 2022/1/17.
//

import Foundation

// MARK: - Where
public extension SQLite3Condition.Where {
    
    /// id >= 3
    func isCompare(key: String, type: SQLite3Condition.CompareType, value: Any) -> Self {
        self.items += " \(combineCompareString(key: key, type: type, value: value))"
        return self
    }
    
    /// AND id >= 3
    func andCompare(key: String, type: SQLite3Condition.CompareType, value: Any) -> Self {
        self.items += " AND \(combineCompareString(key: key, type: type, value: value))"
        return self
    }
    
    /// OR id >= 3
    func orCompare(key: String, type: SQLite3Condition.CompareType, value: Any) -> Self {
        self.items += " OR \(combineCompareString(key: key, type: type, value: value))"
        return self
    }
    
    /// NOT id >= 3
    func notCompare(key: String, type: SQLite3Condition.CompareType, value: Any) -> Self {
        self.items += " NOT \(combineCompareString(key: key, type: type, value: value))"
        return self
    }
}

// MARK: - BETWEEN AND
public extension SQLite3Condition.Where {
    
    /// height BETWEEN 170 AND 180
    func between(key: String, from fromValue: Any, to toValue: Any) -> Self {
        self.items += " \(combineBetweenString(key: key, from: fromValue, to: toValue))"
        return self
    }
    
    /// and height BETWEEN 170 AND 180
    func andBetween(key: String, from fromValue: Any, to toValue: Any) -> Self {
        self.items += " AND \(combineBetweenString(key: key, from: fromValue, to: toValue))"
        return self
    }
    
    /// or height BETWEEN 170 AND 180
    func orBetween(key: String, from fromValue: Any, to toValue: Any) -> Self {
        self.items += " OR \(combineBetweenString(key: key, from: fromValue, to: toValue))"
        return self
    }
    
    /// not height BETWEEN 170 AND 180
    func notBetween(key: String, from fromValue: Any, to toValue: Any) -> Self {
        self.items += " NOT \(combineBetweenString(key: key, from: fromValue, to: toValue))"
        return self
    }
}

// MARK: - NULL
public extension SQLite3Condition.Where {
    
    /// image IS NULL
    func isNull(key: String) -> Self {
        self.items += " \(combineIsNullString(key: key))"
        return self
    }
    
    /// image IS NOT NULL
    func isNotNull(key: String) -> Self {
        self.items += " \(combineIsNotNullString(key: key))"
        return self
    }
    
    /// AND image IS NULL
    func andIsNull(key: String) -> Self {
        self.items += " AND \(combineIsNullString(key: key))"
        return self
    }
    
    /// AND image IS NOT NULL
    func andIsNotNull(key: String) -> Self {
        self.items += " AND \(combineIsNotNullString(key: key))"
        return self
    }
}

// MARK: - LIKE
public extension SQLite3Condition.Where {
    
    func like(key: String, condition: String) -> Self {
        self.items += " \(combineLikeString(key: key, condition: condition))"
        return self
    }
    
    func notLike(key: String, condition: String) -> Self {
        self.items += " \(combineNotLikeString(key: key, condition: condition))"
        return self
    }

    func andLike(key: String, condition: String) -> Self {
        self.items += " AND \(combineLikeString(key: key, condition: condition))"
        return self
    }
    
    func andNotLike(key: String, condition: String) -> Self {
        self.items += " AND \(combineNotLikeString(key: key, condition: condition))"
        return self
    }
}

// MARK: - IN
public extension SQLite3Condition.Where {
    
    /// name IN ('Ana','Ben', 'Curry')
    func `in`(key: String, values: [Any]) -> Self {
        self.items += " \(combineInString(key: key, values: values))"
        return self
    }
    
    /// name NOT IN ('Ana','Ben', 'Curry')
    func notIn(key: String, values: [Any]) -> Self {
        self.items += " \(combineNotInString(key: key, values: values))"
        return self
    }
    
    /// name IN ('Ana','Ben', 'Curry')
    func andIn(key: String, values: [Any]) -> Self {
        self.items += " AND \(combineInString(key: key, values: values))"
        return self
    }
    
    /// AND name NOT IN ('Ana','Ben', 'Curry')
    func andNotIn(key: String, values: [Any]) -> Self {
        self.items += " AND \(combineNotInString(key: key, values: values))"
        return self
    }
}

// MARK: - 小工具
private extension SQLite3Condition.Where {
    
    /// 組合比較用字串 => id >= 3
    /// - Parameters:
    ///   - type: SQLite3Condition.CompareType
    ///   - key: 欄位
    ///   - value: 數值
    ///   - isNumber: 數字 / 非數字
    /// - Returns: String
    func combineCompareString(key: String, type: SQLite3Condition.CompareType, value: Any, isNumber: Bool = false) -> String {
        let sql = "\(key) \(type.rawValue) \(fixSqlValue(value, isNumber: isNumber))"
        return sql
    }
    
    /// 組合數值範圍用字串 => height BETWEEN 170 AND 180
    /// - Parameters:
    ///   - key: 欄位
    ///   - fromValue: 數值最小值
    ///   - toValue: 數值最大值
    ///   - isNumber: 數字 / 非數字
    /// - Returns: String
    func combineBetweenString(key: String, from fromValue: Any, to toValue: Any, isNumber: Bool = false) -> String {
        let sql = "\(key) BETWEEN \(fixSqlValue(fromValue, isNumber: isNumber)) AND \(fixSqlValue(toValue, isNumber: isNumber))"
        return sql
    }
    
    /// 組合IS NULL用字串 => image IS NULL
    /// - Parameter key: 欄位
    /// - Returns: String
    func combineIsNullString(key: String) -> String {
        let sql = "\(key) IS NULL"
        return sql
    }
    
    /// 組合IS NOT NULL用字串 => image IS NOT NULL
    /// - Parameter key: 欄位
    /// - Returns: String
    func combineIsNotNullString(key: String) -> String {
        let sql = "\(key) IS NOT NULL"
        return sql
    }
    
    /// 組合LIKE用字串 => name LIKE 'Will%'
    /// - Parameters:
    ///   - key: String
    ///   - condition: String
    ///   - isNumber: 數字 / 非數字
    /// - Returns: String
    func combineLikeString(key: String, condition: String, isNumber: Bool = false) -> String {
        let sql = "\(key) LIKE \(fixSqlValue(condition, isNumber: isNumber))"
        return sql
    }
    
    /// 組合NOT LIKE用字串 => name NOT LIKE 'Will%'
    /// - Parameters:
    ///   - key: String
    ///   - condition: String
    ///   - isNumber: 數字 / 非數字
    /// - Returns: String
    func combineNotLikeString(key: String, condition: String, isNumber: Bool = false) -> String {
        let sql = "\(key) NOT LIKE \(fixSqlValue(condition, isNumber: isNumber))"
        return sql
    }
    
    /// 組合IN用字串 => name IN ('William', 'Curry', 'Ann')
    /// - Parameters:
    ///   - key: String
    ///   - condition: String
    ///   - values: [Any]
    ///   - isNumber: 數字 / 非數字
    /// - Returns: String
    func combineInString(key: String, values: [Any], isNumber: Bool = false) -> String {
        
        let items = values.map { "\(fixSqlValue($0, isNumber: isNumber))" }.joined(separator: ", ")
        let sql = "\(key) IN (\(items))"
        
        return sql
    }
    
    /// 組合NOT IN用字串 => name IN ('William', 'Curry', 'Ann')
    /// - Parameters:
    ///   - key: String
    ///   - condition: String
    ///   - values: [Any]
    ///   - isNumber: 數字 / 非數字
    /// - Returns: String
    func combineNotInString(key: String, values: [Any], isNumber: Bool = false) -> String {
        
        let items = values.map { "\(fixSqlValue($0, isNumber: isNumber))" }.joined(separator: ", ")
        let sql = "\(key) NOT IN (\(items))"
        
        return sql
    }
    
    /// 修正SQL數值 (數字: 0.8787 / 非數字: '0.8787' )
    /// - Parameters:
    ///   - value: Any
    ///   - isNumber: Bool
    /// - Returns: String
    func fixSqlValue(_ value: Any, isNumber: Bool) -> String {
        if (!isNumber) { return "'\(value)'" }
        return "\(value)"
    }
}
