//
//  LocationModel.swift
//  ComponentsApp
//
//  Created by apple on 06/03/2025.
//

import Foundation
import SQLite
import UIKit

class LocationHandler {
    
private let dbHandler: DBHandler

init(dbHandler: DBHandler) {
    self.dbHandler = dbHandler
}
    // MARK: - Get Image Complete Detail
    
//    func groupImagesByLocation() -> [String: [ImageeDetail]]? {
//        do {
//            guard let db = dbHandler.db else {
//                print("Database not connected")
//                return nil
//            }
//            
//            var result = [String: [ImageeDetail]]()
//            let dateFormatter = ISO8601DateFormatter()
//            
//            // Query all images with their details
//            let imageQuery = dbHandler.imageTable
//                .filter(dbHandler.isDeleted == false || dbHandler.isDeleted == nil)
//                .join(.leftOuter, dbHandler.locationTable,
//                      on: dbHandler.imageTable[dbHandler.imageLocationId] == dbHandler.locationTable[dbHandler.locationId])
//            
//            for imageRow in try db.prepare(imageQuery) {
//                // Get location name (use "Unknown Location" if nil)
//                let locationName = imageRow[dbHandler.locationTable[dbHandler.locationName]] ?? "Unknown Location"
//                
//                // Parse dates - explicitly specify table for each column
//                guard let eventDateStr = imageRow[dbHandler.imageTable[dbHandler.eventDate]],
//                      let captureDateStr = imageRow[dbHandler.imageTable[dbHandler.captureDate]],
//                      let lastModifiedStr = imageRow[dbHandler.imageTable[dbHandler.lastModified]],
//                      let eventDate = Date.fromDatabaseString(eventDateStr),
//                      let captureDate = dateFormatter.date(from: captureDateStr),
//                      let lastModified = dateFormatter.date(from: lastModifiedStr) else {
//                    continue
//                }
//                
//                // Get location details if available - explicitly specify table
//                var location: Locationn? = nil
//                if let locationId = imageRow[dbHandler.imageTable[dbHandler.imageLocationId]] {
//                    location = Locationn(
//                        Id: locationId,
//                        Name: imageRow[dbHandler.locationTable[dbHandler.locationName]] ?? "",
//                        Lat: imageRow[dbHandler.locationTable[dbHandler.latitude]] ?? 0.0,
//                        Lon: imageRow[dbHandler.locationTable[dbHandler.longitude]] ?? 0.0
//                    )
//                }
//                
//                // Get associated persons
//                var persons = [Personn]()
//                let personQuery = dbHandler.personTable
//                    .join(dbHandler.imagePersonTable,
//                          on: dbHandler.personTable[dbHandler.personId] == dbHandler.imagePersonTable[dbHandler.imagePersonPersonId])
//                    .filter(dbHandler.imagePersonTable[dbHandler.imagePersonImageId] == imageRow[dbHandler.imageTable[dbHandler.imageId]])
//                
//                for personRow in try db.prepare(personQuery) {
//                    let person = Personn(
//                        Id: personRow[dbHandler.personTable[dbHandler.personId]],
//                        Name: personRow[dbHandler.personTable[dbHandler.personName]] ?? "Unknown",
//                        Gender: personRow[dbHandler.personTable[dbHandler.personGender]] ?? "U",
//                        Path: personRow[dbHandler.personTable[dbHandler.personPath]] ?? ""
//                    )
//                    persons.append(person)
//                }
//                
//                // Get associated events
//                var events = [Eventt]()
//                let eventQuery = dbHandler.eventTable
//                    .join(dbHandler.imageEventTable,
//                          on: dbHandler.eventTable[dbHandler.eventId] == dbHandler.imageEventTable[dbHandler.imageEventEventId])
//                    .filter(dbHandler.imageEventTable[dbHandler.imageEventImageId] == imageRow[dbHandler.imageTable[dbHandler.imageId]])
//                
//                for eventRow in try db.prepare(eventQuery) {
//                    let event = Eventt(
//                        Id: eventRow[dbHandler.eventTable[dbHandler.eventId]],
//                        Name: eventRow[dbHandler.eventTable[dbHandler.eventName]] ?? "Unnamed Event"
//                    )
//                    events.append(event)
//                }
//                
//                // Create image detail - explicitly specify table for image columns
//                let imageDetail = ImageeDetail(
//                    id: imageRow[dbHandler.imageTable[dbHandler.imageId]],
//                    path: imageRow[dbHandler.imageTable[dbHandler.imagePath]],
//                    is_Sync: imageRow[dbHandler.imageTable[dbHandler.isSync]] ?? false,
//                    capture_date: captureDate,
//                    event_date: eventDate,
//                    last_modified: lastModified,
//                    location: location ?? Locationn(Id: 0, Name: "", Lat: 0.0, Lon: 0.0),
//                    events: events,
//                    persons: persons
//                )
//                
//                // Add to dictionary
//                if result[locationName] == nil {
//                    result[locationName] = [imageDetail]
//                } else {
//                    result[locationName]?.append(imageDetail)
//                }
//            }
//            
//            return result
//            
//        } catch {
//            print("Error grouping images by location: \(error)")
//            return nil
//        }
//    }
    
    
    func groupImagesByLocation() -> [String: [GalleryImage]]? {
        do {
            guard let db = dbHandler.db else {
                print("Database not connected")
                return nil
            }
            
            var result = [String: [GalleryImage]]()
            
            // Query only image IDs, paths, and location names
            let imageQuery = dbHandler.imageTable
                .filter(dbHandler.isDeleted == false || dbHandler.isDeleted == nil)
                .join(.leftOuter, dbHandler.locationTable,
                      on: dbHandler.imageTable[dbHandler.imageLocationId] == dbHandler.locationTable[dbHandler.locationId])
                .select(dbHandler.imageTable[dbHandler.imageId],
                        dbHandler.imageTable[dbHandler.imagePath],
                        dbHandler.locationTable[dbHandler.locationName])
            
            for imageRow in try db.prepare(imageQuery) {
                // Get location name (use "Unknown Location" if nil)
                let locationName = imageRow[dbHandler.locationTable[dbHandler.locationName]] ?? "Unknown Location"
                
                // Create GalleryImage with just the essential data
                let galleryImage = GalleryImage(
                    id: imageRow[dbHandler.imageTable[dbHandler.imageId]],
                    path: imageRow[dbHandler.imageTable[dbHandler.imagePath]]
                )
                
                // Add to dictionary
                if result[locationName] == nil {
                    result[locationName] = [galleryImage]
                } else {
                    result[locationName]?.append(galleryImage)
                }
            }
            
            return result.isEmpty ? nil : result
            
        } catch {
            print("Error grouping images by location: \(error)")
            return nil
        }
    }

}
