//
//  PersonModel.swift
//  ComponentsApp
//
//  Created by apple on 06/03/2025.
//

import Foundation
import Foundation
import SQLite
import UIKit

class PersonHandler {
    private let dbHandler: DBHandler
    
    init(dbHandler: DBHandler) {
        self.dbHandler = dbHandler
    }
    
    public func getPersonDetails(personId: Int) throws -> Personn? {
        guard let db = dbHandler.db else {
            throw NSError(domain: "DatabaseError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Database not initialized"])
        }
        
        let query = dbHandler.personTable.filter(dbHandler.personId == personId)
        guard let personRow = try db.pluck(query) else {
            return nil
        }
        
        return Personn(
            Id: personRow[dbHandler.personId],
            Name: personRow[dbHandler.personName] ?? "",
            Gender: personRow[dbHandler.personPath] ?? "",
            Path: personRow[dbHandler.personGender] ?? ""
        )
    }
}
