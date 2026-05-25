//
//  SQLite3Condition.Where.swift
//  WWSQLite3Manager
//
//  Created by William.Weng on 2022/1/17.
//

import Foundation

public extension WWSQLite3Manager {
    
    enum SQLValue {
        
        case int(Int)
        case double(Double)
        case text(String)
        case null
    }
    
    enum CompareOperator: String {
        
        case equal = "="
        case notEqual = "!="
        case greaterThan = ">"
        case greaterThanOrEqual = ">="
        case lessThan = "<"
        case lessThanOrEqual = "<="
        case like = "LIKE"
    }
}

public extension WWSQLite3Manager {
    
    indirect enum WhereExpression {
        
        case compare(key: String, op: CompareOperator, value: SQLValue)
        case between(key: String, from: SQLValue, to: SQLValue)
        case notBetween(key: String, from: SQLValue, to: SQLValue)
        case like(key: String, pattern: String, escape: Character?)
        case notLike(key: String, pattern: String, escape: Character?)
        case `in`(key: String, values: [SQLValue])
        case notIn(key: String, values: [SQLValue])
        case and(WhereExpression, WhereExpression)
        case or(WhereExpression, WhereExpression)
        case not(WhereExpression)
        case group(WhereExpression)
    }
}

extension WWSQLite3Manager.SQLValue {
    
    var sqlString: String {
        switch self {
        case .int(let value): return "\(value)"
        case .double(let value): return "\(value)"
        case .text(let value): return "'\(value.replacingOccurrences(of: "'", with: "''"))'"
        case .null: return "NULL"
        }
    }
}

extension WWSQLite3Manager.WhereExpression {
    
    var sqlString: String { makeSqlString() }
}

private extension WWSQLite3Manager.WhereExpression {
    
    func makeSqlString() -> String {
        
        switch self {
        case .between(let key, let from, let to): return "\(key) BETWEEN \(from.sqlString) AND \(to.sqlString)"
        case .notBetween(let key, let from, let to): return "\(key) NOT BETWEEN \(from.sqlString) AND \(to.sqlString)"
        case .like(let key, let pattern, let escape): return "\(key) LIKE \(quoted(pattern))\(escapeClause(escape))"
        case .notLike(let key, let pattern, let escape): return "\(key) NOT LIKE \(quoted(pattern))\(escapeClause(escape))"
        case .in(let key, let values): return "\(key) IN (\(joined(values)))"
        case .notIn(let key, let values): return "\(key) NOT IN (\(joined(values)))"
        case .and(let lhs, let rhs): return "\(lhs.sqlString) AND \(rhs.sqlString)"
        case .or(let lhs, let rhs): return "\(lhs.sqlString) OR \(rhs.sqlString)"
        case .not(let expression): return "NOT \(wrap(expression))"
        case .group(let expression): return "(\(expression.sqlString))"
        case .compare(let key, let op, let value): return compareAction(key: key, op: op, value: value)
        }
    }
    
    func compareAction(key: String, op: WWSQLite3Manager.CompareOperator, value: WWSQLite3Manager.SQLValue) -> String {
        
        if case .null = value {
            switch op {
            case .equal: return "\(key) IS NULL"
            case .notEqual: return "\(key) IS NOT NULL"
            default: return "\(key) \(op.rawValue) NULL"
            }
        }
        
        return "\(key) \(op.rawValue) \(value.sqlString)"
    }
    
    func wrap(_ expression: WWSQLite3Manager.WhereExpression) -> String {
        
        switch expression {
        case .compare, .between, .notBetween, .like, .notLike, .in, .notIn: return expression.sqlString
        case .group: return expression.sqlString
        case .and, .or, .not: return "(\(expression.sqlString))"
        }
    }
    
    func quoted(_ string: String) -> String {
        "'\(string.replacingOccurrences(of: "'", with: "''"))'"
    }
    
    func escapeClause(_ escape: Character?) -> String {
        guard let escape else { return "" }
        return " ESCAPE '\(escape)'"
    }
    
    func joined(_ values: [WWSQLite3Manager.SQLValue]) -> String {
        values.map(\.sqlString).joined(separator: ", ")
    }
}

public extension WWSQLite3Manager.Condition {
    
    /// [篩選條件](https://www.fooish.com/sql/where.html)
    class Where {
        
        private var expression: WWSQLite3Manager.WhereExpression?
                
        public required init() {}
    }
}

public extension WWSQLite3Manager.Condition.Where {
    
    var sqlString: String {
        guard let expression else { return "" }
        return "WHERE \(expression.sqlString)"
    }
}

public extension WWSQLite3Manager.Condition.Where {
    
    @discardableResult
    func compare(_ key: String, _ op: WWSQLite3Manager.CompareOperator, _ value: WWSQLite3Manager.SQLValue) -> Self {
        expression = .compare(key: key, op: op, value: value)
        return self
    }
    
    @discardableResult
    func and(_ key: String, _ op: WWSQLite3Manager.CompareOperator, _ value: WWSQLite3Manager.SQLValue) -> Self {
        append(.compare(key: key, op: op, value: value), with: .and)
        return self
    }
    
    @discardableResult
    func or(_ key: String, _ op: WWSQLite3Manager.CompareOperator, _ value: WWSQLite3Manager.SQLValue) -> Self {
        append(.compare(key: key, op: op, value: value), with: .or)
        return self
    }
    
    @discardableResult
    func not(_ key: String, _ op: WWSQLite3Manager.CompareOperator, _ value: WWSQLite3Manager.SQLValue) -> Self {
        append(.not(.compare(key: key, op: op, value: value)), with: .and)
        return self
    }
    
    @discardableResult
    func between(key: String, from fromValue: WWSQLite3Manager.SQLValue, to toValue: WWSQLite3Manager.SQLValue) -> Self {
        append(.between(key: key, from: fromValue, to: toValue), with: .and)
        return self
    }
    
    @discardableResult
    func andBetween(key: String, from fromValue: WWSQLite3Manager.SQLValue, to toValue: WWSQLite3Manager.SQLValue) -> Self {
        append(.between(key: key, from: fromValue, to: toValue), with: .and)
        return self
    }
    
    @discardableResult
    func orBetween(key: String, from fromValue: WWSQLite3Manager.SQLValue, to toValue: WWSQLite3Manager.SQLValue) -> Self {
        append(.between(key: key, from: fromValue, to: toValue), with: .or)
        return self
    }
    
    @discardableResult
    func notBetween(key: String, from fromValue: WWSQLite3Manager.SQLValue, to toValue: WWSQLite3Manager.SQLValue) -> Self {
        append(.notBetween(key: key, from: fromValue, to: toValue), with: .and)
        return self
    }
    
    @discardableResult
    func like(key: String, pattern: String, escape: Character? = nil) -> Self {
        append(.like(key: key, pattern: pattern, escape: escape), with: .and)
        return self
    }
    
    @discardableResult
    func andLike(key: String, pattern: String, escape: Character? = nil) -> Self {
        append(.like(key: key, pattern: pattern, escape: escape), with: .and)
        return self
    }
    
    @discardableResult
    func orLike(key: String, pattern: String, escape: Character? = nil) -> Self {
        append(.like(key: key, pattern: pattern, escape: escape), with: .or)
        return self
    }
    
    @discardableResult
    func notLike(key: String, pattern: String, escape: Character? = nil) -> Self {
        append(.notLike(key: key, pattern: pattern, escape: escape), with: .and)
        return self
    }
    
    @discardableResult
    func andNotLike(key: String, condition: String, escape: Character? = nil) -> Self {
        append(.notLike(key: key, pattern: condition, escape: escape), with: .and)
        return self
    }
    
    @discardableResult
    func orNotLike(key: String, condition: String, escape: Character? = nil) -> Self {
        append(.notLike(key: key, pattern: condition, escape: escape), with: .or)
        return self
    }
    
    @discardableResult
    func `in`(key: String, values: [WWSQLite3Manager.SQLValue]) -> Self {
        append(.in(key: key, values: values), with: .and)
        return self
    }

    @discardableResult
    func andIn(key: String, values: [WWSQLite3Manager.SQLValue]) -> Self {
        append(.in(key: key, values: values), with: .and)
        return self
    }

    @discardableResult
    func orIn(key: String, values: [WWSQLite3Manager.SQLValue]) -> Self {
        append(.in(key: key, values: values), with: .or)
        return self
    }

    @discardableResult
    func notIn(key: String, values: [WWSQLite3Manager.SQLValue]) -> Self {
        append(.notIn(key: key, values: values), with: .and)
        return self
    }

    @discardableResult
    func andNotIn(key: String, values: [WWSQLite3Manager.SQLValue]) -> Self {
        append(.notIn(key: key, values: values), with: .and)
        return self
    }

    @discardableResult
    func orNotIn(key: String, values: [WWSQLite3Manager.SQLValue]) -> Self {
        append(.notIn(key: key, values: values), with: .or)
        return self
    }
    
    @discardableResult
    func contains(key: String, _ text: String, escape: Character? = "\\") -> Self {
        let pattern = "%\(escapeLikePattern(text, escape: escape))%"
        append(.like(key: key, pattern: pattern, escape: escape), with: .and)
        return self
    }
    
    @discardableResult
    func startsWith(key: String, _ text: String, escape: Character? = "\\") -> Self {
        let pattern = "\(escapeLikePattern(text, escape: escape))%"
        append(.like(key: key, pattern: pattern, escape: escape), with: .and)
        return self
    }
    
    @discardableResult
    func endsWith(key: String, _ text: String, escape: Character? = "\\") -> Self {
        let pattern = "%\(escapeLikePattern(text, escape: escape))"
        append(.like(key: key, pattern: pattern, escape: escape), with: .and)
        return self
    }
    
    @discardableResult
    func andGroup(_ builder: (WWSQLite3Manager.Condition.Where) -> WWSQLite3Manager.Condition.Where) -> Self {
        let groupWhere = builder(.init())
        guard let groupExpression = groupWhere.expression else { return self }
        append(.group(groupExpression), with: .and)
        return self
    }
    
    @discardableResult
    func orGroup(_ builder: (WWSQLite3Manager.Condition.Where) -> WWSQLite3Manager.Condition.Where) -> Self {
        let groupWhere = builder(.init())
        guard let groupExpression = groupWhere.expression else { return self }
        append(.group(groupExpression), with: .or)
        return self
    }
}

private extension WWSQLite3Manager.Condition.Where {
    
    enum JoinType {
        case and
        case or
    }
    
    func append(_ rhs: WWSQLite3Manager.WhereExpression, with joinType: JoinType) {
        
        guard let lhs = expression else { expression = rhs; return }
        
        switch joinType {
        case .and: expression = .and(lhs, rhs)
        case .or: expression = .or(lhs, rhs)
        }
    }
    
    func escapeLikePattern(_ string: String, escape: Character?) -> String {
        
        guard let escape else { return string }
        
        let escapeString = String(escape)
        
        return string
            .replacingOccurrences(of: escapeString, with: escapeString + escapeString)
            .replacingOccurrences(of: "%", with: escapeString + "%")
            .replacingOccurrences(of: "_", with: escapeString + "_")
    }
}


