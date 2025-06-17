//
//  EventModel.swift
//  ComponentsApp
//
//  Created by apple on 06/03/2025.
//

import Foundation
import SQLite
import UIKit

class EventHandler {
    
    private let dbHandler: DBHandler
    
    init(dbHandler: DBHandler) {
        self.dbHandler = dbHandler
    }
    
    // MARK: - Group by Event Name
    func groupImagesByEventName() -> [String: [GalleryImage]]? {
        do {
            guard let db = dbHandler.db else {
                print("Database not connected")
                return nil
            }
            
            var result = [String: [GalleryImage]]()
            
            // Query to fetch images with non-empty event names
            let query = dbHandler.imageTable
                .filter(dbHandler.isDeleted == false || dbHandler.isDeleted == nil)
                .join(.leftOuter, dbHandler.imageEventTable,
                      on: dbHandler.imageTable[dbHandler.imageId] == dbHandler.imageEventTable[dbHandler.imageEventImageId])
                .join(.leftOuter, dbHandler.eventTable,
                      on: dbHandler.imageEventTable[dbHandler.imageEventEventId] == dbHandler.eventTable[dbHandler.eventId])
                .select(dbHandler.imageTable[dbHandler.imageId],
                        dbHandler.imageTable[dbHandler.imagePath],
                        dbHandler.eventTable[dbHandler.eventName])
                .filter(dbHandler.eventTable[dbHandler.eventName] != nil) // Ignore nil event names
                .filter(dbHandler.eventTable[dbHandler.eventName] != "")  // Ignore empty event names
            
            for imageRow in try db.prepare(query) {
                // Safely unwrap the event name (we already filtered nil/empty but Swift still requires it)
                if let eventName = imageRow[dbHandler.eventTable[dbHandler.eventName]], !eventName.isEmpty {
                    
                    let galleryImage = GalleryImage(
                        id: imageRow[dbHandler.imageTable[dbHandler.imageId]],
                        path: imageRow[dbHandler.imageTable[dbHandler.imagePath]]
                    )
                    
                    if result[eventName] == nil {
                        result[eventName] = [galleryImage]
                    } else {
                        result[eventName]?.append(galleryImage)
                    }
                }
            }
            
            return result.isEmpty ? nil : result
            
        } catch {
            print("Error grouping images by event name: \(error)")
            return nil
        }
    }
    
    
    
    
    
    // MARK: - Group by Event Date
    
    func groupImagesByEventDate() -> [String: [GalleryImage]]? {
        do {
            guard let db = dbHandler.db else {
                print("Database not connected")
                return nil
            }
            
            var result = [String: [GalleryImage]]()
            
            // Simplified query to fetch only essential data
            let imageQuery = dbHandler.imageTable
                .filter(dbHandler.isDeleted == false || dbHandler.isDeleted == nil)
                .filter(dbHandler.eventDate != nil) // Ignore nil event dates
                .filter(dbHandler.eventDate != "")  // Ignore empty event dates
                .select(dbHandler.imageId,
                        dbHandler.imagePath,
                        dbHandler.eventDate)
            
            for imageRow in try db.prepare(imageQuery) {
                guard let eventDateStr = imageRow[dbHandler.eventDate] else {
                    continue
                }
                
                // Create simple GalleryImage
                let galleryImage = GalleryImage(
                    id: imageRow[dbHandler.imageId],
                    path: imageRow[dbHandler.imagePath]
                )
                
                // Use event date string as the key
                if result[eventDateStr] == nil {
                    result[eventDateStr] = [galleryImage]
                } else {
                    result[eventDateStr]?.append(galleryImage)
                }
            }
            
            return result.isEmpty ? nil : result
            
        } catch {
            print("Error grouping images by event date: \(error)")
            return nil
        }
    }
    
    //    func addEventIfNotExists(eventName: String, completion: @escaping (Swift.Result<Eventt, Error>) -> Void) {
    //        do {
    //            guard let db = dbHandler.db else {
    //                completion(.failure(NSError(domain: "DatabaseError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Database not connected"])))
    //                return
    //            }
    //
    //            // 1. Check if event already exists (case-insensitive comparison)
    //            let existingEventQuery = dbHandler.eventTable
    //                .filter(dbHandler.eventName.lowercaseString == eventName.lowercased())
    //                .limit(1)
    //
    //            if try db.pluck(existingEventQuery) != nil {
    //                completion(.failure(NSError(domain: "EventError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Event already exists"])))
    //                return
    //            }
    //
    //            // 2. Get the next available ID
    //            let maxId = try db.scalar(dbHandler.eventTable.select(dbHandler.eventId.max)) ?? 0
    //            let newId = maxId + 1
    //
    //            // 3. Insert new event
    //            let insert = dbHandler.eventTable.insert(
    //                dbHandler.eventId <- newId,
    //                dbHandler.eventName <- eventName
    //            )
    //
    //            try db.run(insert)
    //
    //            // 4. Return the new event
    //            let newEvent = Eventt(id: newId, name: eventName)
    //            completion(.success(newEvent))
    //
    //        } catch {
    //            completion(.failure(error))
    //        }
    //    }
    
    
    public func addEventIfNotExists(eventName: String, completion: @escaping (Swift.Result<Eventt, Error>) -> Void) -> Eventt? {
        do {
            guard let db = dbHandler.db else {
                completion(.failure(NSError(domain: "DatabaseError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Database not connected"])))
                return nil
            }
            
            // 1. Check if event already exists (case-insensitive)
            let existingEventQuery = dbHandler.eventTable
                .filter(dbHandler.eventName.lowercaseString == eventName.lowercased())
                .limit(1)
            
            if let existingRow = try db.pluck(existingEventQuery) {
                // Event already exists, return it
                let existingEvent = Eventt(
                    id: existingRow[dbHandler.eventId],
                    name: existingRow[dbHandler.eventName] ?? ""
                )
                completion(.success(existingEvent))
                return existingEvent
            }
            
            // 2. Get the next available ID
            let maxId = try db.scalar(dbHandler.eventTable.select(dbHandler.eventId.max)) ?? 0
            let newId = maxId + 1
            
            // 3. Insert new event
            let insert = dbHandler.eventTable.insert(
                dbHandler.eventId <- newId,
                dbHandler.eventName <- eventName
            )
            try db.run(insert)
            
            // 4. Return the new event
            let newEvent = Eventt(id: newId, name: eventName)
            completion(.success(newEvent))
            return newEvent
            
        } catch {
            completion(.failure(error))
            return nil
        }
    }
    
    
    
    func fetchAllEvents() -> [Eventt] {
        do {
            guard let db = dbHandler.db else {
                print("Database not connected")
                return []
            }
            
            // Query to get distinct events
            let query = dbHandler.eventTable
                .select(distinct: dbHandler.eventId, dbHandler.eventName)
                .filter(dbHandler.eventName != nil)  // Only include events with names
                .order(dbHandler.eventName)
            
            var events: [Eventt] = []
            
            for row in try db.prepare(query) {
                if let name = row[dbHandler.eventName] {
                    events.append(Eventt(
                        id: row[dbHandler.eventId],
                        name: name
                    ))
                }
            }
            
            return events
            
        } catch {
            print("Error fetching events: \(error)")
            return []
        }
    }
}
