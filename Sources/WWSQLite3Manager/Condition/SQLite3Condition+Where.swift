//
//  SQLite3Condition.Where.swift
//  WWSQLite3Manager
//
//  Created by iOS on 2022/1/17.
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
}

// MARK: - BETWEEN AND
public extension SQLite3Condition.Where {
    
    /// height BETWEEN 170 AND 180
    func between(key: String, from fromValue: Any, to toValue: Any) -> Self {
        self.items += " \(combineBetweenString(key: key, from: fromValue, to: toValue))"
        return self
    }
    
    /// height BETWEEN 170 AND 180
    func andBetween(key: String, from fromValue: Any, to toValue: Any) -> Self {
        self.items += "AND \(combineBetweenString(key: key, from: fromValue, to: toValue))"
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

// MARK: - ?????????
private extension SQLite3Condition.Where {
    
    /// ????????????????????? => id >= 3
    /// - Parameters:
    ///   - type: SQLite3Condition.CompareType
    ///   - key: ??????
    ///   - value: ??????
    /// - Returns: String
    func combineCompareString(key: String, type: SQLite3Condition.CompareType, value: Any) -> String {
        let sql = "\(key) \(type.rawValue) '\(value)'"
        return sql
    }
    
    /// ??????????????????????????? => height BETWEEN 170 AND 180
    /// - Parameters:
    ///   - key: ??????
    ///   - fromValue: ???????????????
    ///   - toValue: ???????????????
    /// - Returns: String
    func combineBetweenString(key: String, from fromValue: Any, to toValue: Any) -> String {
        let sql = "\(key) BETWEEN \(fromValue) AND \(toValue)"
        return sql
    }
    
    /// ??????IS NULL????????? => image IS NULL
    /// - Parameter key: ??????
    /// - Returns: String
    func combineIsNullString(key: String) -> String {
        let sql = "\(key) IS NULL"
        return sql
    }
    
    /// ??????IS NOT NULL????????? => image IS NOT NULL
    /// - Parameter key: ??????
    /// - Returns: String
    func combineIsNotNullString(key: String) -> String {
        let sql = "\(key) IS NOT NULL"
        return sql
    }
    
    /// ??????LIKE????????? => name LIKE 'Will%'
    /// - Parameters:
    ///   - key: String
    ///   - condition: String
    /// - Returns: String
    func combineLikeString(key: String, condition: String) -> String {
        let sql = "\(key) LIKE '\(condition)'"
        return sql
    }
    
    /// ??????NOT LIKE????????? => name NOT LIKE 'Will%'
    /// - Parameters:
    ///   - key: String
    ///   - condition: String
    /// - Returns: String
    func combineNotLikeString(key: String, condition: String) -> String {
        let sql = "\(key) NOT LIKE '\(condition)'"
        return sql
    }
    
    /// ??????IN????????? => name IN ('William', 'Curry', 'Ann')
    /// - Parameters:
    ///   - key: String
    ///   - condition: String
    /// - Returns: String
    func combineInString(key: String, values: [Any]) -> String {
        
        let items = values.map { "'\($0)'" }.joined(separator: ", ")
        let sql = "\(key) IN (\(items))"
        
        return sql
    }
    
    /// ??????NOT IN????????? => name IN ('William', 'Curry', 'Ann')
    /// - Parameters:
    ///   - key: String
    ///   - condition: String
    /// - Returns: String
    func combineNotInString(key: String, values: [Any]) -> String {
        
        let items = values.map { "'\($0)'" }.joined(separator: ", ")
        let sql = "\(key) NOT IN (\(items))"
        
        return sql
    }
}
