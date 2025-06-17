//
//  ImageModel.swift
//  ComponentsApp
//
//  Created by apple on 06/03/2025.
//

import Foundation
import SQLite
import UIKit

class ImageHandler {
    private let dbHandler: DBHandler
    
    init(dbHandler: DBHandler) {
        self.dbHandler = dbHandler
    }
 
    // MARK: - Add Image
   
    func addImage(path: String, filename: String, hash: String? = "", completion: @escaping (Swift.Result<Int, Error>) -> Void) {
        do {
            var h = ""
            if(hash == ""){
                h = HelperFunctions.generateImageHashSimple(imagePath: path) ?? ""
            } else {
                h = hash!
            }
            
            guard let db = dbHandler.db else {
                throw NSError(domain: "DatabaseError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Database not initialized"])
            }
            
            // 1. Check for existing image
            let existingImageQuery = dbHandler.imageTable.filter(dbHandler.hash == h)
            
            if let existingImage = try db.pluck(existingImageQuery) {
                let update = existingImageQuery.update(
                    dbHandler.isDeleted <- false,
                    dbHandler.lastModified <- HelperFunctions.currentDateString()
                )
                try db.run(update)
                completion(.success(Int(existingImage[dbHandler.imageId])))
                print("⚠️ Image already exists with hash: \(h)")
                return
            }
            
            // 2. Insert new image
            let insert = dbHandler.imageTable.insert(
                dbHandler.imagePath <- filename,
                dbHandler.hash <- h,
                dbHandler.isSync <- false,
                dbHandler.captureDate <- HelperFunctions.currentDateString(),
                dbHandler.lastModified <- HelperFunctions.currentDateString(),
                dbHandler.isDeleted <- false
            )
            
            let imageId = try db.run(insert)
            print("✅ Image saved: \(path)")
            
            // 3. Process faces asynchronously
//            DispatchQueue.global(qos: .userInitiated).async {
//                HelperFunctions.checkServerStatus { isServerActive in
//                    guard isServerActive, let image = UIImage(contentsOfFile: path) else {
//                        completion(.success(Int(imageId)))
//                        return
//                    }
//                    
//                    DispatchQueue.global(qos: .userInitiated).async {
//                        HelperFunctions.checkServerStatus { isServerActive in
//                            guard isServerActive, let image = UIImage(contentsOfFile: path) else {
//                                completion(.success(Int(imageId)))
//                                return
//                            }
//                            
//                            // Call the API to process the image
//                            ApiHandler.processImage(image: image) { result in
//                                switch result {
//                                case .success(let data):
//                                    do {
//                                        // Parse the JSON response
//                                        if let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
//                                            for faceData in jsonArray {
//                                                guard let status = faceData["status"] as? String,
//                                                      let facePath = faceData["path"] as? String else {
//                                                    continue
//                                                }
//                                                
//                                                let name = faceData["name"] as? String ?? "unknown"
//                                                let gender = faceData["gender"] as? String ?? "U"
//                                                
//                                                // Insert or update the face data in local database
//                                                self.insertOrUpdateFace(
//                                                    imageId: Int(imageId),
//                                                    facePath: facePath,
//                                                    status: status,
//                                                    name: name,
//                                                    gender: gender,
//                                                    db: db
//                                                )
//                                                
//                                            }
//                                        }
//                                        completion(.success(Int(imageId)))
//                                    } catch {
//                                        print("JSON parsing error: \(error)")
//                                        completion(.success(Int(imageId))) // Still complete even if parsing fails
//                                    }
//                                    
//                                case .failure(let error):
//                                    print("API error: \(error)")
//                                    completion(.success(Int(imageId))) // Still complete even if API fails
//                                }
//                            }
//                        }
//                    }
//
//                    
//                }
//            }
            
        } catch {
            completion(.failure(error))
            print("❌ Error in addImage: \(error)")
        }
    }
    

        

        
    func insertOrUpdateFace(imageId: Int, facePath: String, status: String, name: String, gender: String, db: Connection) {
            do {
                
                var personId: Int?

                    let insertPerson = dbHandler.personTable.insert(
                        dbHandler.personName <- name,
                        dbHandler.personPath <- facePath,
                        dbHandler.personGender <- gender
                    )
                    personId = Int(try db.run(insertPerson))

                
                // Now handle the image-person relationship
                if let personId = personId {
                    let imagePersonQuery = dbHandler.imagePersonTable.filter(
                        dbHandler.imagePersonImageId == imageId &&
                        dbHandler.imagePersonPersonId == personId
                    )
                    
                    if try db.scalar(imagePersonQuery.exists) {
                        // Relationship exists - update if needed
                        let updateRelation = imagePersonQuery.update(
                            // Add any fields you might want to update
                        )
                        try db.run(updateRelation)
                    } else {
                        // Create new relationship
                        let insertRelation = dbHandler.imagePersonTable.insert(
                            dbHandler.imagePersonImageId <- imageId,
                            dbHandler.imagePersonPersonId <- personId
                        )
                        try db.run(insertRelation)
                    }
                }
                
                // Update the image's sync status if needed
//                let updateImage = dbHandler.imageTable.filter(dbHandler.imageId == imageId)
//                    .update(dbHandler.isSync <- false)
//                try db.run(updateImage)
                
            } catch {
                print("Database error in insertOrUpdateFace: \(error)")
            }
        }

    

    private func processFace(facePath: String, imageId: Int, db: Connection, completion: @escaping (Error?) -> Void) {
        DispatchQueue.global(qos: .utility).async {
            do {
                // 1. Check for existing person
                let personQuery = self.dbHandler.personTable.filter(self.dbHandler.personPath == facePath)
                let matchedPerson = try? db.pluck(personQuery)
                
                // 2. Load face image for recognition
                ApiHandler.loadFaceImage(from: facePath) { faceImage in
                    guard let faceImage = faceImage else {
                        completion(nil)  // Skip if image fails to load
                        return
                    }
                    
                    // 3. Recognize person (if server available)
                    ApiHandler.recognizePersonViaAPI(faceImage: faceImage) { recognizedName in
                        // 4. Finalize linking without transactions
                        self.finalizePersonLinking(
                            matchedPerson: matchedPerson,
                            dbFacePath: facePath,
                            imageId: imageId,
                            db: db,
                            recognizedName: recognizedName,
                            completion: completion
                        )
                    }
                }
            }
        }
    }

    private func finalizePersonLinking(
        matchedPerson: Row?,
        dbFacePath: String,
        imageId: Int,
        db: Connection,
        recognizedName: String? = nil,
        completion: @escaping (Error?) -> Void
    ) {
        do {
            // Use immediate writes instead of transactions
            try db.execute("PRAGMA synchronous = OFF")
            try db.execute("PRAGMA journal_mode = MEMORY")
            
            if matchedPerson == nil {
                // Insert new person
                let insertPerson = dbHandler.personTable.insert(
                    dbHandler.personName <- recognizedName ?? "unknown",
                    dbHandler.personPath <- dbFacePath,
                    dbHandler.personGender <- "U"
                )
                let personId = try db.run(insertPerson)
                
                // Link image to person
                try db.run(dbHandler.imagePersonTable.insert(
                    dbHandler.imagePersonImageId <- imageId,
                    dbHandler.imagePersonPersonId <- Int(personId)
                ))
            } else if let recognizedName = recognizedName {
                // Update existing person if recognized
                try db.run(dbHandler.personTable
                    .filter(dbHandler.personPath == dbFacePath)
                    .update(dbHandler.personName <- recognizedName)
                )
            }
            
            completion(nil)
        } catch {
            print("❌ Error in finalizePersonLinking: \(error)")
            completion(error)
        }
    }
    
    //=================================
    
    
 
    // MARK: - Edit Image
    
    func editImage(imageId: Int, persons: [Personn]?, eventNames: [Eventt]?, eventDate: String?, location: Locationn?, completion: @escaping (Swift.Result<Void, Error>) -> Void) {
        do {
            let db = try dbHandler.db!
            
            try db.transaction {
                let imageQuery = dbHandler.imageTable.filter(dbHandler.imageId == imageId)
                guard try db.pluck(imageQuery) != nil else {
                    throw NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Image not found"])
                }
//                if eventDate == "1111-01-01" ?
                // Update core image record
                try db.run(imageQuery.update(
                    dbHandler.eventDate <- eventDate == "1111-01-01" ? nil : eventDate,
                    dbHandler.lastModified <- HelperFunctions.currentDateString()
                ))
                print("done with image")
                // Handle events
                if let eventNames = eventNames, !eventNames.isEmpty {
                    try db.run(dbHandler.imageEventTable.filter(dbHandler.imageEventImageId == imageId).delete())
                    
                    for event in eventNames {
                        guard event.id <= 0 else {
                            try db.run(dbHandler.imageEventTable.insert(
                                dbHandler.imageEventImageId <- imageId,
                                dbHandler.imageEventEventId <- event.id  // Convert to Int64
                            ))
                            continue
                        }
                        
                        let existingEvent = try db.pluck(
                            dbHandler.eventTable
                                .filter(dbHandler.eventName == event.name)
                        )
                        
                        let eventId: Int64
                        
                        if let existing = existingEvent {
                            eventId = Int64(existing[dbHandler.eventId]) // This is Int64
                        } else {
                            eventId = try db.run(dbHandler.eventTable.insert(
                                dbHandler.eventName <- event.name
                            ))
                        }
                        
                        try db.run(dbHandler.imageEventTable.insert(
                            dbHandler.imageEventImageId <- imageId,
                            dbHandler.imageEventEventId <- Int(eventId)  // Using Int64
                        ))
                    }
                    
                    
                }
                print("done with events")
                // Handle location
                if let location = location, location.latitude != nil, location.longitude != nil {
                    
//                    let locationQuery = dbHandler.locationTable.filter(
//                        dbHandler.latitude == location.Lat && dbHandler.longitude == location.Lon
//                    )
                    
                    let locationQuery = dbHandler.locationTable.filter(
                        dbHandler.locationName == location.name
                    )
                    
                    let locationId: Int
                    if let existing = try db.pluck(locationQuery) {
                        locationId = existing[dbHandler.locationId]
                    } else {
                        locationId = Int(try db.run(dbHandler.locationTable.insert(
                            dbHandler.locationName <- location.name,
                            dbHandler.latitude <- location.latitude,
                            dbHandler.longitude <- location.longitude
                        )))
                    }
                    
                    try db.run(imageQuery.update(dbHandler.imageLocationId <- locationId))
                }
                print("done with location")
                // Handle persons
                if let persons = persons {
                    try db.run(dbHandler.imagePersonTable.filter(dbHandler.imagePersonImageId == imageId).delete())
                    
                    for person in persons {
                        // Fixed person ID check
                        if person.id <= 0 { continue }
                        let personId = person.id
                        
                        try db.run(dbHandler.personTable.filter(dbHandler.personId == personId).update(
                            dbHandler.personName <- person.name,
                            dbHandler.personGender <- person.gender
                        ))
                        
                        let query = dbHandler.personTable.filter(dbHandler.personId == personId).limit(1)
                            
                        if let person = try db.pluck(query) {
                                let path = person[dbHandler.personPath]
                                let name = person[dbHandler.personName]
                            
                            ApiHandler.loadFaceImage(from: path ?? "") { faceImage in
                                    guard let faceImage = faceImage else {
                                        //completion(nil)  // Skip if image fails to load
                                        return
                                    }
                                    ApiHandler.recognizePersonViaAPI(faceImage: faceImage, name: name, completion: {_ in })
                                }
                            }
                        
                    
                        
                        try db.run(dbHandler.imagePersonTable.insert(
                            dbHandler.imagePersonImageId <- imageId,
                            dbHandler.imagePersonPersonId <- personId
                        ))
                    }
                }
                print("done with persons")
            }
            
            completion(.success(()))
            // Now using the properly defined notification name
            NotificationCenter.default.post(name: .imageDataUpdated, object: nil)
        } catch {
            completion(.failure(error))
            print("DB Error: \(error)")
        }
    }
    
    
    
    // MARK: - Get Image Complete Detail
    func getImageDetails(imageId: Int) -> ImageeDetail? {
            do {
                
                guard let db = dbHandler.db else {
                    print("Database not connected")
                    return nil
                }
                
                // 1. Get basic image info
                guard let imageRow = try dbHandler.db?.pluck(dbHandler.imageTable.filter(dbHandler.imageId == imageId)) else {
                    print("Image not found with id: \(imageId)")
                    return nil
                }
                
                // Parse dates from strings
//                let dateFormatter = ISO8601DateFormatter()
                guard let captureDateStr = imageRow[dbHandler.captureDate],
//                      let eventDateStr = imageRow[dbHandler.eventDate],
                      let lastModifiedStr = imageRow[dbHandler.lastModified],
                      let captureDate = Date.fromISOString(captureDateStr) ?? Date.fromDatabaseString(captureDateStr),
                      let lastModified =  DateFormatter.sqlServerWithoutMillis.date(from: lastModifiedStr ) ?? Date.fromDatabaseString(lastModifiedStr) else {
                    print("Error parsing dates for image \(imageId)")
                    return nil
                }
                
                // Handle event date (can be null)
                let eventDate: Date
                if let eventDateStr = imageRow[dbHandler.eventDate] {
                    eventDate = Date.fromISOString(eventDateStr) ?? Date.fromDatabaseString(eventDateStr) ?? Date()
                } else {
                    eventDate = Date()
                }
                
                // 2. Get location if exists
                var location: Locationn? = nil
                if let locationId = imageRow[dbHandler.imageLocationId] {
                    if let locationRow = try dbHandler.db?.pluck(dbHandler.locationTable.filter(dbHandler.locationId == locationId)) {
                        location = Locationn(
                            id: locationRow[dbHandler.locationId],
                            name: locationRow[dbHandler.locationName]!,
                            latitude: locationRow[dbHandler.latitude] ?? 0.0,
                            longitude: locationRow[dbHandler.longitude] ?? 0.0
                        )
                    }
                }
                
                // 3. Get associated persons
                var persons = [Personn]()
                let personQuery = dbHandler.personTable
                    .join(dbHandler.imagePersonTable, on: dbHandler.personTable[dbHandler.personId] == dbHandler.imagePersonTable[dbHandler.imagePersonPersonId])
                    .filter(dbHandler.imagePersonTable[dbHandler.imagePersonImageId] == imageId)
                
                for personRow in try dbHandler.db!.prepare(personQuery) {
                    let person = Personn(
                        id: personRow[dbHandler.personId],
                        name: personRow[dbHandler.personName] ?? "",
                        gender: personRow[dbHandler.personGender] ?? "",
                        path: personRow[dbHandler.personPath] ?? ""
                    )
                    persons.append(person)
                }
                
                // 4. Get associated events
                var events = [Eventt]()
                let eventQuery = dbHandler.eventTable
                    .join(dbHandler.imageEventTable, on: dbHandler.eventTable[dbHandler.eventId] == dbHandler.imageEventTable[dbHandler.imageEventEventId])
                    .filter(dbHandler.imageEventTable[dbHandler.imageEventImageId] == imageId)
                
                for eventRow in try dbHandler.db!.prepare(eventQuery) {
                    let event = Eventt(
                        id: eventRow[dbHandler.eventId],
                        name: eventRow[dbHandler.eventName] ?? ""
                    )
                    events.append(event)
                }
                
                // Create and return the complete image detail
                return ImageeDetail(
                    id: imageRow[dbHandler.imageId],
                    path: imageRow[dbHandler.imagePath],
                    is_sync: imageRow[dbHandler.isSync] ?? false,
                    capture_date: captureDate,
                    event_date: eventDate,
                    last_modified: lastModified,
                    hash: imageRow[dbHandler.hash],
                    location: location ?? Locationn(id: 0, name: "", latitude: 0.0, longitude: 0.0),
                    events: events,
                    persons: persons
                )
                
            } catch {
                print("Error fetching image details: \(error)")
                return nil
            }
        }
    
    
    
    //MARK: - get unedited images
    


    //MARK: - Mark Image as Deleted (Soft Delete)
    
    func markImageAsDeleted(imageId: Int, completion: @escaping (Swift.Result<Void, Error>) -> Void) {
        do {
            guard let db = dbHandler.db else {
                throw NSError(domain: "DatabaseError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Database not initialized"])
            }
            
            // Find the image by ID
            let imageQuery = dbHandler.imageTable.filter(dbHandler.imageId == imageId)
            
            // Update is_deleted to true (1) and update last_modified
            let update = imageQuery.update(
                dbHandler.isDeleted <- true,
                dbHandler.lastModified <- HelperFunctions.currentDateString()
            )
            
            try db.run(update)
            completion(.success(()))
            print("✅ Image \(imageId) marked as deleted")
            
        } catch {
            completion(.failure(error))
            print("❌ Error marking image as deleted: \(error)")
        }
    }
    
    static func getFullImagePath(filename:String) -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let photogalleryDirectory = documentsDirectory.appendingPathComponent("photogallery")
                return photogalleryDirectory.appendingPathComponent(filename)
    }
}
