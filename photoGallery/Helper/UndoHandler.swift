//
//  UndoHandler.swift
//  photoGallery
//
//  Created by apple on 21/06/2025.
//

import Foundation
import SQLite

class UndoHandler {
    
    private let dbHandler = DBHandler()
    
    func getLatestInactiveNonDeletedImages() -> [UndoData] {
        var results = [UndoData]()
        
        do {
            guard let db = dbHandler.db else {
                print("Database not connected")
                return []
            }
            
//            let query = try db.prepare("""
//                SELECT ih.id, ih.path, ih.version_no
//                FROM image_history ih
//                INNER JOIN (
//                    SELECT id, MAX(version_no) as max_version
//                    FROM image_history
//                    WHERE is_active = 0 AND (is_deleted = 0 OR is_deleted IS NULL)
//                    GROUP BY id
//                ) subq ON ih.id = subq.id AND ih.version_no = subq.max_version
//                WHERE ih.is_active = 0 AND (ih.is_deleted = 0 OR ih.is_deleted IS NULL)
//                """)
            
            let query = try db.prepare("""
                WITH ranked_versions AS (
                    SELECT
                        ih.id,
                        ih.path,
                        ih.version_no,
                        ih.is_active,
                        ROW_NUMBER() OVER (
                            PARTITION BY ih.id
                            ORDER BY 
                                ih.is_active DESC,  -- active version gets priority
                                ih.version_no DESC  -- if inactive, pick highest version
                        ) AS rn
                    FROM image_history ih
                    WHERE ih.is_deleted = 0 OR ih.is_deleted IS NULL
                )
                SELECT id, path, version_no
                FROM ranked_versions
                WHERE rn = 1 AND version_no != 1
            """)

            
            for row in query {
                // Get row values with proper type casting
                let id = Int(row[0] as? Int64 ?? 0)  // SQLite integers come as Int64
                guard let path = row[1] as? String else {
                    print("Invalid path format in row")
                    continue
                }
                let version = Int(row[2] as? Int64 ?? 0)
                
                results.append(UndoData(
                    id: id,
                    path: path,
                    version_no: version
                ))
            }
            
            print("Found \(results.count) undoable images")
            return results
            
        } catch {
            print("Error fetching latest inactive non-deleted images: \(error)")
            return []
        }
    }
    
    func getImageCompleteDetailsUndo(imageId: Int, version: Int) -> ImageeDetail? {
        do {
            guard let db = dbHandler.db else {
                print("Database not connected")
                return nil
            }
            
            print("Image  id------->\(imageId), Version \(version)")
            // MARK: - Fetch Image History
            let imageQuery = dbHandler.imageHistoryTable
                .filter(dbHandler.imageHisOriginalId == imageId &&
                       dbHandler.imageHisVersion == version)
            
            guard let imageRow = try db.pluck(imageQuery) else {
                print("Image not found")
                return nil
            }
            
            
            
            // MARK: - Convert Dates
            let captureDate: Date = {
                        guard let dateString = imageRow[dbHandler.imageHisCaptureDate],
                              let date = Date.fromDatabaseString(dateString) else {
                            return Date() // Default date if conversion fails
                        }
                        return date
                    }()
            let eventDate: Date = {
                        guard let dateString = imageRow[dbHandler.imageHisEventDate],
                              let date = Date.fromDatabaseString(dateString) else {
                            return Date()
                        }
                        return date
                    }()
                    
                    let lastModified: Date = {
                        guard let dateString = imageRow[dbHandler.imageHisLastModified],
                              let date = Date.fromSqlServerFormat(dateString) else {
                            return Date()
                        }
                        return date
                    }()
                    
                    let changedAt: Date = {
                        guard let dateString = imageRow[dbHandler.imageHisChangedAt],
                              let date = Date.fromSqlServerFormat(dateString) else {
                            return Date()
                        }
                        return date
                    }()
            
            let delta: TimeInterval = 5
            let lowerBound = changedAt.addingTimeInterval(-delta)
            let upperBound = changedAt.addingTimeInterval(delta)
            
            let lowerBoundStr = lowerBound.toSqlServerFormat()
            let upperBoundStr = upperBound.toSqlServerFormat()
            
            // MARK: - Fetch Location
            var location: Locationn?
            if let locationId = imageRow[dbHandler.imageHisLocationId] {
                let locationQuery = dbHandler.locationTable
                    .filter(dbHandler.locationId == locationId)
//                    .order(dbHandler.locationHisVersion.desc)
//                    .limit(1)
                
                if let locationRow = try db.pluck(locationQuery) {
                    location = Locationn(
                        id: locationRow[dbHandler.locationId],
                        name: locationRow[dbHandler.locationName] ?? "",
                        latitude: locationRow[dbHandler.latitude] ?? 0,
                        longitude: locationRow[dbHandler.longitude] ?? 0
                    )
                }
            }
            
            // MARK: - Fetch Persons
            var persons: [Personn] = []
            let personQuery = dbHandler.personHistoryTable
                .join(dbHandler.imagePersonTable,
                      on: dbHandler.personHistoryTable[dbHandler.personHisOriginalId] ==
                        dbHandler.imagePersonTable[dbHandler.imagePersonPersonId])
                .filter(dbHandler.imagePersonTable[dbHandler.imagePersonImageId] == imageId
//                        &&
//                       dbHandler.personHistoryTable[dbHandler.personHisChangedAt] == imageRow[dbHandler.imageHisChangedAt]
                )
                .filter(dbHandler.personHisChangedAt >= lowerBoundStr && dbHandler.personHisChangedAt <= upperBoundStr)

            
            for personRow in try db.prepare(personQuery) {
                let person = Personn(
                    id: personRow[dbHandler.personHisOriginalId],
                    name: personRow[dbHandler.personHisName] ?? "",
                    gender: personRow[dbHandler.personHisGender] ?? "U",
                    path: personRow[dbHandler.personHisPath] ?? "",
                    dob: Date.fromDatabaseString(personRow[dbHandler.personHisDob] ?? Date().toDatabaseString()) ,
                    age: personRow[dbHandler.personHisAge]
                )
                persons.append(person)
            }
            
            // MARK: - Fetch Events
            var events: [Eventt] = []
            let eventQuery = dbHandler.eventTable
                .join(dbHandler.imageEventHistoryTable,
                     on: dbHandler.eventTable[dbHandler.eventId] ==
                        dbHandler.imageEventHistoryTable[dbHandler.imageEventHisEventId])
                .filter(dbHandler.imageEventHistoryTable[dbHandler.imageEventHisImageId] == imageId)
                .filter(dbHandler.imageEventHisChangedAt >= lowerBoundStr && dbHandler.imageEventHisChangedAt <= upperBoundStr)
            
            for eventRow in try db.prepare(eventQuery) {
                let event = Eventt(
                    id: eventRow[dbHandler.eventId],
                    name: eventRow[dbHandler.eventName] ?? "",
                )
                events.append(event)
            }
            
            // MARK: - Create Complete Image History
            let imageDetail = ImageeDetail(
                id: imageRow[dbHandler.imageHisOriginalId],
                path: imageRow[dbHandler.imageHisPath],
                is_sync: imageRow[dbHandler.imageHisIsSync] ?? false,
                capture_date: captureDate,
                event_date: eventDate,
                last_modified: lastModified,
                hash: imageRow[dbHandler.imageHisHash],
                location: location ?? Locationn(id: 0, name: "", latitude: 0, longitude: 0),
                events: events,
                persons: persons
            )
            
            return imageDetail
            
        } catch {
            print("Error fetching image details: \(error)")
            return nil
        }
    }

    
    
    func undoData(imageId: Int, version: Int) async -> Bool {
            do {
                // Get the connection from DBHandler
                guard let db = dbHandler.db else {
                    print("Database connection not available")
                    return false
                }
                
                // 1. Get image data for undo
                guard let imageData = getImageCompleteDetailsUndo(imageId: imageId, version: version-1) else {
                    try db.run("ROLLBACK")
                    return false
                }
                
                // 2. Edit the image data with the historical version
                var imgHandler = ImageHandler(dbHandler: DBHandler())
                try await imgHandler.editImage(imageId: imageData.id, persons: imageData.persons, eventNames: imageData.events, eventDate: Date.toDatabaseString(imageData.event_date)(), location: imageData.location, completion: {_ in })
                
                
                // 3. Get the image history record
                let imageHistoryQuery = dbHandler.imageHistoryTable
                    .filter(dbHandler.imageHisOriginalId == imageId && dbHandler.imageHisVersion == version-1)
                
                guard let imageHistory = try db.pluck(imageHistoryQuery) else {
                    print("Image history record not found")
                    return false
                }
                
                // Calculate time bounds (5 seconds before and after)
                guard let changedAtStr = imageHistory[dbHandler.imageHisChangedAt],
                      let changedAt = DateFormatter.sqlServerWithoutMillis.date(from: changedAtStr) else {
                    print("Invalid changed_at date")
                    return false
                }
                
                let delta: TimeInterval = 5
                let lowerBound = changedAt.addingTimeInterval(-delta)
                let upperBound = changedAt.addingTimeInterval(delta)
                
                let lowerBoundStr = lowerBound.toSqlServerFormat()
                let upperBoundStr = upperBound.toSqlServerFormat()
                
                if version-1 != 1 {
                    
                    // 4. Update ImageHistory to set is_active = true
                    let updateImageHistory = dbHandler.imageHistoryTable
                        .filter(dbHandler.imageHisOriginalId == imageId && dbHandler.imageHisVersion == version-1)
                        .update(dbHandler.imageHisIsActive <- true)
                    
                    try db.run(updateImageHistory)
                    
                    // 5. Update ImageEventHistory records in the time range
                    let imageEventHistoryUpdate = dbHandler.imageEventHistoryTable
                        .filter(dbHandler.imageEventHisImageId == imageId)
                        .filter(dbHandler.imageEventHisChangedAt >= lowerBoundStr && dbHandler.imageEventHisChangedAt <= upperBoundStr)
                    
                    try db.run(imageEventHistoryUpdate.update(dbHandler.imageEventHisIsActive <- true))
                    
                    // 6. Update PersonHistory records linked to this image in the time range
                    let matchingPersonsQuery = dbHandler.personHistoryTable
                        .join(dbHandler.imagePersonTable, on: dbHandler.personHisOriginalId == dbHandler.imagePersonPersonId)
                        .filter(dbHandler.imagePersonImageId == imageId)
                        .filter(dbHandler.personHisChangedAt >= lowerBoundStr && dbHandler.personHisChangedAt <= upperBoundStr)
                        .filter(dbHandler.personHisVersion == version-1)
                    
                    let matchingPersons = try db.prepare(matchingPersonsQuery)
                    
                    for person in matchingPersons {
                        let updateQuery = dbHandler.personHistoryTable
                            .filter(dbHandler.personHisId == person[dbHandler.personHisId])
                            .update(dbHandler.personHisIsActive <- true)
                        
                        try db.run(updateQuery)
                    }
                    
                }
                
                
                //======MARK-  PREVIOUS VERSION  AS INACTIVE
                // 4. Update ImageHistory to set is_active = true
                let updateImageHistoryPrev = dbHandler.imageHistoryTable
                    .filter(dbHandler.imageHisOriginalId == imageId && dbHandler.imageHisVersion == version)
                    .update(dbHandler.imageHisIsActive <- false)
                
                try db.run(updateImageHistoryPrev)
                
                // 5. Update ImageEventHistory records in the time range
                let imageEventHistoryUpdatePrev = dbHandler.imageEventHistoryTable
                    .filter(dbHandler.imageEventHisImageId == imageId)
                    .filter(dbHandler.imageEventHisChangedAt >= lowerBoundStr && dbHandler.imageEventHisChangedAt <= upperBoundStr)
                
                try db.run(imageEventHistoryUpdatePrev.update(dbHandler.imageEventHisIsActive <- false))
                
                // 6. Update PersonHistory records linked to this image in the time range
                let matchingPersonsQueryPrev = dbHandler.personHistoryTable
                    .join(dbHandler.imagePersonTable, on: dbHandler.personHisOriginalId == dbHandler.imagePersonPersonId)
                    .filter(dbHandler.imagePersonImageId == imageId)
                    .filter(dbHandler.personHisChangedAt >= lowerBoundStr && dbHandler.personHisChangedAt <= upperBoundStr)
                    .filter(dbHandler.personHisVersion == version)
                
                let matchingPersonsPrev = try db.prepare(matchingPersonsQueryPrev)
                
                for person in matchingPersonsPrev {
                    let updateQueryPrev = dbHandler.personHistoryTable
                        .filter(dbHandler.personHisId == person[dbHandler.personHisId])
                        .update(dbHandler.personHisIsActive <- false)
                    
                    try db.run(updateQueryPrev)
                }
                
                return true
                
            } catch {
                print("Error in undoData: \(error)")
                return false
            }
        }
        
        // Helper method to get complete image details for undo
//        static func getImageCompleteDetailsUndo(imageId: Int, version: Int, dbHandler: DBHandler) -> Row? {
//            do {
//                guard let db = dbHandler.db else { return nil }
//                
//                let query = dbHandler.imageHistoryTable
//                    .filter(dbHandler.imageHisOriginalId == imageId && dbHandler.imageHisVersion == version)
//                
//                return try db.pluck(query)
//            } catch {
//                print("Error getting image details for undo: \(error)")
//                return nil
//            }
//        }
}
