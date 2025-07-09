//
//  RedoHandler.swift
//  photoGallery
//
//  Created by apple on 04/07/2025.
//

import Foundation
import SQLite

class RedoHandler {
    
    private let dbHandler = DBHandler()
    
    func getLatestActiveNonDeletedRedoImages() -> [UndoData] {
        var results = [UndoData]()
        
        do {
            guard let db = dbHandler.db else {
                print("Database not connected")
                return []
            }
            
//            let query = try db.prepare("""
//                WITH ranked_versions AS (
//                    SELECT
//                        ih.id,
//                        ih.path,
//                        ih.version_no,
//                        ih.is_active,
//                        ROW_NUMBER() OVER (
//                            PARTITION BY ih.id
//                            ORDER BY 
//                                ih.is_active DESC,
//                                ih.version_no DESC
//                        ) AS rn
//                    FROM image_history ih
//                    WHERE ih.is_deleted = 0 OR ih.is_deleted IS NULL
//                )
//                SELECT id, path, version_no
//                FROM ranked_versions
//                WHERE rn > 1
//            """)
            
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
                                ih.is_active DESC,
                                ih.version_no DESC
                        ) AS rn,
                        MAX(ih.version_no) OVER (PARTITION BY ih.id) AS max_version
                    FROM image_history ih
                    WHERE ih.is_deleted = 0 OR ih.is_deleted IS NULL
                )
                SELECT id, path, version_no
                FROM ranked_versions
                WHERE rn = 1 
                  AND version_no != max_version
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

    
    
    func redoData(imageId: Int, version: Int) async -> Bool {
            do {
                // Get the connection from DBHandler
                guard let db = dbHandler.db else {
                    print("Database connection not available")
                    return false
                }
                var undoHandler = UndoHandler()
                // 1. Get image data for undo
                guard let imageData = undoHandler.getImageCompleteDetailsUndo(imageId: imageId, version: version+1) else {
                    try db.run("ROLLBACK")
                    return false
                }
                
                // 2. Edit the image data with the historical version
                let imgHandler = ImageHandler(dbHandler: DBHandler())
                 imgHandler.editImage(imageId: imageData.id, persons: imageData.persons, eventNames: imageData.events, eventDate: Date.toDatabaseString(imageData.event_date)(), location: imageData.location, isUndo: true, completion: {_ in })
                
                
                // 3. Get the image history record
                let imageHistoryQuery = dbHandler.imageHistoryTable
                    .filter(dbHandler.imageHisOriginalId == imageId && dbHandler.imageHisVersion == version+1)
                
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
                
                //Image Highest Version
                let maxVersionQuery = dbHandler.imageHistoryTable
                    .filter(imageId == imageId && (dbHandler.isDeleted == false || dbHandler.isDeleted == nil))
                    .order(dbHandler.imageHisVersion.desc)
                    .limit(1)
                
                var maxVersion = 0
                if let row = try db.pluck(maxVersionQuery) {
                    let fetchedPath = row[dbHandler.imageHisPath]
                    maxVersion = row[dbHandler.imageHisVersion]
                    print("Max version: \(maxVersion), Path: \(fetchedPath)")
                }
                
                if maxVersion != 0 && version+1 != maxVersion {
                    
                    // 4. Update ImageHistory to set is_active = true
                    let updateImageHistory = dbHandler.imageHistoryTable
                        .filter(dbHandler.imageHisOriginalId == imageId && dbHandler.imageHisVersion == version+1)
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
                        .filter(dbHandler.personHisVersion == version+1)
                    
                    let matchingPersons = try db.prepare(matchingPersonsQuery)
                    
                    for person in matchingPersons {
                        let updateQuery = dbHandler.personHistoryTable
                            .filter(dbHandler.personHisId == person[dbHandler.personHisId])
                            .update(dbHandler.personHisIsActive <- true)
                        
                        try db.run(updateQuery)
                    }
                    
                }
//                else {
//                    try db.run(dbHandler.imageHistoryTable.filter(dbHandler.imageHisIsActive == true).update(dbHandler.imageHisIsActive <- false))
//                }
                
                
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
        

}
