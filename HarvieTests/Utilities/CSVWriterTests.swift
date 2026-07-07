//
//  CSVWriterTests.swift
//  HarvieTests
//

import Foundation
import Testing
@testable import Harvie

@Suite("CSV Writer")
struct CSVWriterTests {

    private func makeRows(_ json: String) throws -> [[String: Any]] {
        let object = try JSONSerialization.jsonObject(with: Data(json.utf8))
        return try #require(object as? [[String: Any]])
    }

    @Test("JSON integers 0 and 1 stay numeric; booleans stay booleans")
    func integersNotCoercedToBooleans() throws {
        let rows = try makeRows(
            #"[{"id": 7, "quantity": 1, "weekly_capacity": 0, "active": true, "archived": false}]"#
        )
        let csv = try #require(String(data: CSVWriter.makeCSV(rows: rows), encoding: .utf8))

        // Columns: id pinned first, rest alphabetical
        #expect(csv.contains("id,active,archived,quantity,weekly_capacity"))
        #expect(csv.contains("7,true,false,1,0"))
    }

    @Test("Fields containing separators and quotes are escaped")
    func escapesSpecialCharacters() throws {
        let rows = try makeRows(#"[{"id": 1, "name": "Acme, \"Inc\""}]"#)
        let csv = try #require(String(data: CSVWriter.makeCSV(rows: rows), encoding: .utf8))

        #expect(csv.contains(#""Acme, ""Inc""""#))
    }
}
