//
//  FTS5Demo.swift
//  Example
//
//  Created by William.Weng on 2026/5/27.
//

import WWSQLite3Manager
import SQLite3

final class FTS5Demo {
    
    private let database: WWSQLite3Manager.Database
    
    private let tableName = "notes"
    private let ftsTableName = "notes_fts"
    private let config: WWSQLite3Manager.FTS5Configuration
    
    init(database: WWSQLite3Manager.Database) {
        self.database = database
        self.config = .init(table: tableName, ftsTable: ftsTableName, rowID: "id", indexedColumns: ["title", "body"])
    }
    
    func run() throws -> [String] {
        
        try prepareDatabase()
        try seedData()
        try rebuildIndex()
        
        let texts1 = try printSearch(keyword: "検索")
        let texts2 = try printSearch(keyword: "Swift")
        let texts3 = try printSearch(keyword: "藍牙")
                
        return [texts1, texts2, texts3].flatMap { $0 }
    }
    
    func testUpdateAndDelete() throws -> [String] {
        
        try database.execute(sql: "UPDATE notes SET body = 'Updated text about full text search' WHERE id = 1")
        try rebuildIndex()
        let texts1 =  try printSearch(keyword: "Updated")
        
        try database.execute(sql: "DELETE FROM notes WHERE id = 2")
        try rebuildIndex()
        let texts2 = try printSearch(keyword: "藍牙")
        
        return [texts1, texts2].flatMap { $0 }
    }
}

private extension FTS5Demo {
    
    func prepareDatabase() throws {
        
        try database.create(tableName: tableName, type: Note.self)
        try database.drop(tableName: ftsTableName, ifExists: true)
        
        try database.createFTS5Table(config)
        try database.dropFTS5Triggers(config)
        try database.createFTS5Triggers(config)
        
        try database.delete(tableName: tableName)
        try database.delete(tableName: ftsTableName)
    }
    
    func seedData() throws {
        
        let item0: [WWSQLite3Manager.InsertItem] = [
            (key: "title", value: .string("Swift SQLite FTS5")),
            (key: "body", value: .string("This demo shows full text search (検索) with highlight and snippet.")),
        ]
        
        let item1: [WWSQLite3Manager.InsertItem] = [
            (key: "title", value: .string("CoreBluetooth Notes")),
            (key: "body", value: .string("Bluetooth (藍牙) data parsing and fast local search.")),
        ]
        
        let item2: [WWSQLite3Manager.InsertItem] = [
            (key: "title", value: .string("Retro Game Tools")),
            (key: "body", value: .string("Search game metadata with SQLite FTS5.")),
        ]
        
        try database.insert(tableName: tableName, itemsArray: [item0, item1, item2])
    }
    
    func rebuildIndex() throws {
        try database.rebuildFTS5Index(ftsTable: config.ftsTable)
    }
    
    func printSearch(keyword: String) throws -> [String] {
        
        let results = try database.searchFTS5(ftsTable: config.ftsTable, keyword: keyword, highlightColumn: 0, snippetColumn: 1, snippetLength: 24, limit: 20, offset: 0)
        
        var texts: [String] = []
        
        texts.append("==== keyword: \(keyword) ====")
        
        if results.isEmpty {
            texts.append("No results")
        } else {
            for item in results {
                texts.append("rowID: \(item.rowID)")
                texts.append("rank: \(item.rank ?? 0)")
                texts.append("highlighted: \(item.highlightedText ?? "-")")
                texts.append("snippet: \(item.snippet ?? "-")")
                texts.append("")
            }
        }
        
        return texts
    }
}
