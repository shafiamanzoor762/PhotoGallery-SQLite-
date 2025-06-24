//
//  PersonModel.swift
//  ComponentsApp
//
//  Created by apple on 06/03/2025.
//

import Foundation
import SQLite
import UIKit

class PersonHandler {
    private let dbHandler = DBHandler()
    
    init() {
    }
    
    public func getPersonDetails(personId: Int) throws -> Personn? {
        guard let db = dbHandler.db else {
            throw NSError(domain: "DatabaseError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Database not initialized"])
        }
        
        let query = dbHandler.personTable.filter(dbHandler.personId == personId)
        guard let personRow = try db.pluck(query) else {
            return nil
        }
        
        let dob: Date
        if let dobStr = personRow[dbHandler.personDob] {
            dob = Date.fromISOString(dobStr) ?? Date.fromDatabaseString(dobStr) ?? Date()
        } else {
            dob = Date()
        }
        
        return Personn(
            id: personRow[dbHandler.personId],
            name: personRow[dbHandler.personName] ?? "",
            gender: personRow[dbHandler.personGender] ?? "",
            path: personRow[dbHandler.personPath] ?? "",
            dob: dob,
            age: personRow[dbHandler.personAge] ?? 0
        )
    }
    
    
    func getPersonAndLinkedAsList(personId: Int) throws -> [Personn] {
            guard let db = dbHandler.db else {
                throw NSError(domain: "DatabaseError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Database not initialized"])
            }
            
            // 1. Get the main person
            guard let mainPerson = try getPersonDetails(personId: personId) else {
                return []
            }
            
            var personList = [mainPerson]
            
            // 2. Get linked person IDs (bidirectional)
            let person1Links = try db.prepare(
                dbHandler.linkTable.filter(dbHandler.linkPerson1Id == personId))
            let person2Links = try db.prepare(
                dbHandler.linkTable.filter(dbHandler.linkPerson2Id == personId))
            
            var linkedIds = Set<Int>()
            
            for link in person1Links {
                linkedIds.insert(link[dbHandler.linkPerson2Id])
            }
            
            for link in person2Links {
                linkedIds.insert(link[dbHandler.linkPerson1Id])
            }
            
            // Remove self if present
            linkedIds.remove(personId)
            
            // 3. Get details for each linked person
            for linkedId in linkedIds {
                if let linkedPerson = try getPersonDetails(personId: linkedId) {
                    personList.append(linkedPerson)
                }
            }
            
            return personList
        }
    
    func parsePersonGroups(from data: Data) throws -> [PersonGroup] {
        guard let db = dbHandler.db else {
             throw NSError(domain: "DatabaseError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Database not initialized"])
//            print("Database not initialized")
        }
        
        guard let jsonArray = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            return []
        }
        
        var result = [PersonGroup]()
        
        for groupDict in jsonArray {
            guard let personDict = groupDict["Person"] as? [String: Any],
                  let personId = personDict["id"] as? Int,
                  let personName = personDict["name"] as? String,
                  let personPath = personDict["path"] as? String,
                  let personDob = Date.fromDatabaseString(personDict["dob"] as! String == "" ? Date().toDatabaseString() : personDict["dob"] as! String),
                  let personAge = personDict["age"] as? Int,
                  let personGender = personDict["gender"] as? String,
                  let imagesArray = groupDict["Images"] as? [[String: Any]] else {
                continue
            }
            print(personDict["dob"],personDict["age"])
            
            let person = Personn(
                id: personId,
                name: personName,
                gender: personGender,
                path: personPath,
                dob: personDob,
                age: personAge
            )
            
            let images = imagesArray.compactMap { imageDict -> GalleryImage? in
                guard let imageIdValue = imageDict["id"] as? Int else { return nil }
                
                // ✅ Correct filter syntax:
                let query = dbHandler.imageTable.filter(dbHandler.imageId == SQLite.Expression<Int>(value: imageIdValue))
                guard let imageRecord = try? db.pluck(query) else {
                    return nil
                }
                return GalleryImage(
                    id: imageIdValue,
                    path: imageRecord[dbHandler.imagePath]
                )
            }
            result.append(PersonGroup(person: person, images: images))
        }
        
        return result
    }


    

    
    
    
    func insertLink(person1Id: Int, person2Id: Int) throws -> [String: Any] {
            guard let db = dbHandler.db else {
                throw NSError(domain: "DatabaseError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Database not initialized"])
            }
            
            // Check if persons exist
            let person1 = try getPersonDetails(personId: person1Id)
            let person2 = try getPersonDetails(personId: person2Id)
            
            guard let person1 = person1, let person2 = person2 else {
                return ["error": "One or both persons not found", "code": 404]
            }
            
            // Normalize names for comparison
            let name1 = person1.name.trimmingCharacters(in: .whitespaces).lowercased()
            let name2 = person2.name.trimmingCharacters(in: .whitespaces).lowercased()
            
            // Handle name updates
            if name1 != name2 {
                if name2 != "unknown" && name1 == "unknown" {
                    try updatePerson(id: person1Id, name: person2.name, gender: person2.gender)
                } else if name1 != "unknown" && name2 == "unknown" {
                    try updatePerson(id: person2Id, name: person1.name, gender: person1.gender)
                }
            }
            
            // Check for existing link
            if try linkExists(person1Id: person1Id, person2Id: person2Id) {
                return ["error": "Link already exists", "code": 409]
            }
            
            // Create new link
            try createLink(person1Id: person1Id, person2Id: person2Id)
            
            return ["message": "Link created successfully"]
        }
        
        private func updatePerson(id: Int, name: String, gender: String) throws {
            guard let db = dbHandler.db else {
                throw NSError(domain: "DatabaseError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Database not initialized"])
            }
            
            let personTable = dbHandler.personTable
            let personId = dbHandler.personId
            let personName = dbHandler.personName
            let personGender = dbHandler.personGender
            
            let person = personTable.filter(personId == id)
            try db.run(person.update(
                personName <- name,
                personGender <- gender
            ))
        }
        
        private func createLink(person1Id: Int, person2Id: Int) throws {
            guard let db = dbHandler.db else {
                throw NSError(domain: "DatabaseError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Database not initialized"])
            }
            
            let linkTable = dbHandler.linkTable
            let linkPerson1Id = dbHandler.linkPerson1Id
            let linkPerson2Id = dbHandler.linkPerson2Id
            
            try db.run(linkTable.insert(
                linkPerson1Id <- person1Id,
                linkPerson2Id <- person2Id
            ))
        }
        
        func linkExists(person1Id: Int, person2Id: Int) throws -> Bool {
            guard let db = dbHandler.db else {
                throw NSError(domain: "DatabaseError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Database not initialized"])
            }
            
            let linkTable = dbHandler.linkTable
            let linkPerson1Id = dbHandler.linkPerson1Id
            let linkPerson2Id = dbHandler.linkPerson2Id
            
            let query = linkTable.filter(
                (linkPerson1Id == person1Id && linkPerson2Id == person2Id) ||
                (linkPerson1Id == person2Id && linkPerson2Id == person1Id)
            )
            
            return try db.pluck(query) != nil
        }
    
    public func getOrInsertPersonId(person: Personn) throws -> Int {
        guard let db = dbHandler.db else {
            throw NSError(domain: "DatabaseError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Database not initialized"])
        }

        // Create the filter query - match by name (you can add more filters like gender or path if needed)
        let query = dbHandler.personTable.filter(dbHandler.personName == person.path)

        if let existing = try db.pluck(query) {
            // Person exists — return their ID
            return existing[dbHandler.personId]
        } else {
            // Person doesn't exist — insert new
            let newId = try db.run(dbHandler.personTable.insert(
                dbHandler.personName <- person.name,
                dbHandler.personGender <- person.gender,
                dbHandler.personPath <- person.path,
                dbHandler.personDob <- person.dob?.toDatabaseString(),
                dbHandler.personAge <- person.age
            ))
            return Int(newId)
        }
    }
    

    public func calculateAge(from birthDate: Date, to currentDate: Date) -> Int? {

        // Calculate the difference in years
        let ageComponents = Calendar.current.dateComponents([.year], from: birthDate, to: currentDate)
        return ageComponents.year
    }

    public func findPerson(byPath path: String) throws -> Personn? {
        guard let db = dbHandler.db else {
            throw NSError(domain: "DatabaseError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Database not initialized"])
        }
        
        let query = dbHandler.personTable.filter(dbHandler.personPath == path)
        guard let person = try db.pluck(query) else {
            return nil
        }
        
        return Personn(
            id: person[dbHandler.personId],
            name: person[dbHandler.personName] ?? "Unknown",
            gender: person[dbHandler.personGender] ?? "U",
            path: person[dbHandler.personPath] ?? "",
            dob: Date.fromDatabaseString(person[dbHandler.personDob] ?? Date().toDatabaseString()),
            age: person[dbHandler.personAge]
        )
    }

}
