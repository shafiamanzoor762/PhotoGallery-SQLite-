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
   
    func addImage(path: String, filename: String, completion: @escaping (Swift.Result<Int, Error>) -> Void) {
        do {
            let hash = HelperFunctions.generateImageHashSimple(imagePath: path) ?? ""
            guard let db = dbHandler.db else {
                throw NSError(domain: "DatabaseError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Database not initialized"])
            }
            
            // 1. Check for existing image
            let existingImageQuery = dbHandler.imageTable.filter(dbHandler.hash == hash)
            
            if let existingImage = try db.pluck(existingImageQuery) {
                let update = existingImageQuery.update(
                    dbHandler.isDeleted <- false,
                    dbHandler.lastModified <- HelperFunctions.currentDateString()
                )
                try db.run(update)
                completion(.success(Int(existingImage[dbHandler.imageId])))
                print("⚠️ Image already exists with hash: \(hash)")
                return
            }
            
            // 2. Insert new image
            let insert = dbHandler.imageTable.insert(
                dbHandler.imagePath <- filename,
                dbHandler.hash <- hash,
                dbHandler.isSync <- false,
                dbHandler.captureDate <- HelperFunctions.currentDateString(),
                dbHandler.lastModified <- HelperFunctions.currentDateString(),
                dbHandler.isDeleted <- false
            )
            
            let imageId = try db.run(insert)
            print("✅ Image saved: \(path)")
            
            // 3. Process faces asynchronously
            DispatchQueue.global(qos: .userInitiated).async {
                HelperFunctions.checkServerStatus { isServerActive in
                    guard isServerActive, let image = UIImage(contentsOfFile: path) else {
                        completion(.success(Int(imageId)))
                        return
                    }
                    
                    // Use the completion handler version of extractFacesViaApi
                    ApiHandler.extractFacesViaApi(from: image) { extractedFaces in
                        guard !extractedFaces.isEmpty else {
                            completion(.success(Int(imageId)))
                            return
                        }
                        
                        // Process faces in parallel
                        let group = DispatchGroup()
                        var lastError: Error?
                        
                        for facePath in extractedFaces {
                            group.enter()
                            
                            self.processFace(
                                facePath: facePath,
                                imageId: Int(imageId),
                                db: db,
                                completion: { error in
                                    if let error = error {
                                        lastError = error
                                    }
                                    group.leave()
                                }
                            )
                        }
                        
                        group.notify(queue: .main) {
                            if let error = lastError {
                                completion(.failure(error))
                            } else {
                                completion(.success(Int(imageId)))
                            }
                        }
                    }
                }
            }
            
        } catch {
            completion(.failure(error))
            print("❌ Error in addImage: \(error)")
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
    
//    func editImage(imageId: Int, persons: [Personn]?, eventNames: [String]?, eventDate: String?, location: Locationn?, completion: @escaping (Swift.Result<Void, Error>) -> Void) {
//        do {
//            let db = try dbHandler.db!
//            
//            // Fetch the image record by image_id
//            let imageQuery = dbHandler.imageTable.filter(dbHandler.imageId == imageId)
//            guard try db.pluck(imageQuery) != nil else {
//                completion(.failure(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Image not found"])))
//                return
//            }
//            
//            // Update event_date if provided
//            if let eventDate = eventDate {
//                let update = imageQuery.update(
//                    dbHandler.eventDate <- eventDate,
//                    dbHandler.lastModified <- HelperFunctions.currentDateString()
//                )
//                try db.run(update)
//            }
//            
//            // Update events if provided
//            if let eventNames = eventNames, !eventNames.isEmpty {
//                // First clear existing event associations
//                let deleteImageEvents = dbHandler.imageEventTable.filter(dbHandler.imageEventImageId == imageId)
//                try db.run(deleteImageEvents.delete())
//                
//                // Find matching events
//                let matchingEvents = dbHandler.eventTable.filter(eventNames.contains(dbHandler.eventName))
//                let events = try db.prepare(matchingEvents).map { $0 }
//                
//                if !events.isEmpty {
//                    // Associate image with events
//                    for event in events {
//                        let insertImageEvent = dbHandler.imageEventTable.insert(
//                            dbHandler.imageEventImageId <- imageId,
//                            dbHandler.imageEventEventId <- event[dbHandler.eventId]
//                        )
//                        try db.run(insertImageEvent)
//                    }
//                }
//            }
//            
//            // Update location if provided
//            if let location = location {
//                // Check if the location exists
//                let locationQuery = dbHandler.locationTable.filter(
//                    dbHandler.latitude == location.Lat && dbHandler.longitude == location.Lon
//                )
//                
//                var locationId: Int
//                
//                if let existingLocation = try db.pluck(locationQuery) {
//                    locationId = existingLocation[dbHandler.locationId]
//                } else {
//                    // Create new location
//                    let insertLocation = dbHandler.locationTable.insert(
//                        dbHandler.locationName <- location.Name,
//                        dbHandler.latitude <- location.Lat,
//                        dbHandler.longitude <- location.Lon
//                    )
//                    locationId = Int(try db.run(insertLocation))
//                }
//                
//                // Update image's location
//                let updateImage = imageQuery.update(
//                    dbHandler.imageLocationId <- locationId,
//                    dbHandler.lastModified <- HelperFunctions.currentDateString()
//                )
//                try db.run(updateImage)
//            }
//            
//            // Update persons if provided
//            if let persons = persons {
//                // First clear existing person associations
//                let deleteImagePersons = dbHandler.imagePersonTable.filter(dbHandler.imagePersonImageId == imageId)
//                try db.run(deleteImagePersons.delete())
//                
//                for person in persons {
//                    // Update person details if name/gender changed
//                    let personQuery = dbHandler.personTable.filter(dbHandler.personId == person.Id)
//                    if let existingPerson = try db.pluck(personQuery) {
//                        let update = personQuery.update(
//                            dbHandler.personName <- person.Name,
//                            dbHandler.personGender <- person.Gender
//                        )
//                        try db.run(update)
//                        
//                        // Re-link person to image
//                        let insertImagePerson = dbHandler.imagePersonTable.insert(
//                            dbHandler.imagePersonImageId <- imageId,
//                            dbHandler.imagePersonPersonId <- person.Id
//                        )
//                        try db.run(insertImagePerson)
//                    }
//                }
//            }
//            
//            completion(.success(()))
//        } catch {
//            completion(.failure(error))
//            print("Error editing image: \(error)")
//        }
//    }
    
    

    func editImage(imageId: Int, persons: [Personn]?, eventNames: [String]?, eventDate: String?, location: Locationn?, completion: @escaping (Swift.Result<Void, Error>) -> Void) {
        do {
            let db = try dbHandler.db!
            
            try db.transaction {
                let imageQuery = dbHandler.imageTable.filter(dbHandler.imageId == imageId)
                guard try db.pluck(imageQuery) != nil else {
                    throw NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Image not found"])
                }
                
                // Update core image record
                try db.run(imageQuery.update(
                    dbHandler.eventDate <- eventDate,
                    dbHandler.lastModified <- HelperFunctions.currentDateString()
                ))
                
                // Handle events
                if let eventNames = eventNames, !eventNames.isEmpty {
                    try db.run(dbHandler.imageEventTable.filter(dbHandler.imageEventImageId == imageId).delete())
                    
                    let matchingEvents = dbHandler.eventTable.filter(eventNames.contains(dbHandler.eventName))
                    for event in try db.prepare(matchingEvents) {
                        try db.run(dbHandler.imageEventTable.insert(
                            dbHandler.imageEventImageId <- imageId,
                            dbHandler.imageEventEventId <- event[dbHandler.eventId]
                        ))
                    }
                }
                
                // Handle location
                if let location = location, location.Lat != nil, location.Lon != nil {
                    
//                    let locationQuery = dbHandler.locationTable.filter(
//                        dbHandler.latitude == location.Lat && dbHandler.longitude == location.Lon
//                    )
                    
                    let locationQuery = dbHandler.locationTable.filter(
                        dbHandler.locationName == location.Name
                    )
                    
                    let locationId: Int
                    if let existing = try db.pluck(locationQuery) {
                        locationId = existing[dbHandler.locationId]
                    } else {
                        locationId = Int(try db.run(dbHandler.locationTable.insert(
                            dbHandler.locationName <- location.Name,
                            dbHandler.latitude <- location.Lat,
                            dbHandler.longitude <- location.Lon
                        )))
                    }
                    
                    try db.run(imageQuery.update(dbHandler.imageLocationId <- locationId))
                }
                
                // Handle persons
                if let persons = persons {
                    try db.run(dbHandler.imagePersonTable.filter(dbHandler.imagePersonImageId == imageId).delete())
                    
                    for person in persons {
                        // Fixed person ID check
                        if person.Id <= 0 { continue }
                        let personId = person.Id
                        
                        try db.run(dbHandler.personTable.filter(dbHandler.personId == personId).update(
                            dbHandler.personName <- person.Name,
                            dbHandler.personGender <- person.Gender
                        ))
                        
                        try db.run(dbHandler.imagePersonTable.insert(
                            dbHandler.imagePersonImageId <- imageId,
                            dbHandler.imagePersonPersonId <- personId
                        ))
                    }
                }
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
                      let captureDate = Date.fromISOString(captureDateStr),
                      let lastModified = Date.fromISOString(lastModifiedStr) else {
                    print("Error parsing dates for image \(imageId)")
                    return nil
                }
                
                // Handle event date (can be null)
                let eventDate: Date
                if let eventDateStr = imageRow[dbHandler.eventDate] {
                    eventDate = Date.fromDatabaseString(eventDateStr) ?? captureDate
                } else {
                    eventDate = captureDate
                }
                
                // 2. Get location if exists
                var location: Locationn? = nil
                if let locationId = imageRow[dbHandler.imageLocationId] {
                    if let locationRow = try dbHandler.db?.pluck(dbHandler.locationTable.filter(dbHandler.locationId == locationId)) {
                        location = Locationn(
                            Id: locationRow[dbHandler.locationId],
                            Name: locationRow[dbHandler.locationName]!,
                            Lat: locationRow[dbHandler.latitude] ?? 0.0,
                            Lon: locationRow[dbHandler.longitude] ?? 0.0
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
                        Id: personRow[dbHandler.personId],
                        Name: personRow[dbHandler.personName] ?? "",
                        Gender: personRow[dbHandler.personGender] ?? "",
                        Path: personRow[dbHandler.personPath] ?? ""
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
                        Id: eventRow[dbHandler.eventId],
                        Name: eventRow[dbHandler.eventName] ?? ""
                    )
                    events.append(event)
                }
                
                // Create and return the complete image detail
                return ImageeDetail(
                    id: imageRow[dbHandler.imageId],
                    path: imageRow[dbHandler.imagePath],
                    is_Sync: imageRow[dbHandler.isSync] ?? false,
                    capture_date: captureDate,
                    event_date: eventDate,
                    last_modified: lastModified,
                    location: location ?? Locationn(Id: 0, Name: "", Lat: 0.0, Lon: 0.0),
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
    

}
