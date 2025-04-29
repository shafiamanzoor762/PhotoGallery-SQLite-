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
    
//    func groupImagesByEventName() -> [String: [ImageeDetail]]? {
//          do {
//              guard let db = dbHandler.db else {
//                  print("Database not connected")
//                  return nil
//              }
//              
//              var result = [String: [ImageeDetail]]()
//              let dateFormatter = ISO8601DateFormatter()
//              
//              // Base query for non-deleted images with their events
//              let query = dbHandler.imageTable
//                  .filter(dbHandler.isDeleted == false || dbHandler.isDeleted == nil)
//                  .join(.leftOuter, dbHandler.imageEventTable,
//                        on: dbHandler.imageTable[dbHandler.imageId] == dbHandler.imageEventTable[dbHandler.imageEventImageId])
//                  .join(.leftOuter, dbHandler.eventTable,
//                        on: dbHandler.imageEventTable[dbHandler.imageEventEventId] == dbHandler.eventTable[dbHandler.eventId])
//                  .join(.leftOuter, dbHandler.locationTable,
//                        on: dbHandler.imageTable[dbHandler.imageLocationId] == dbHandler.locationTable[dbHandler.locationId])
//              
//              for imageRow in try db.prepare(query) {
//                  // Get event name (use "Uncategorized" if nil)
//                  let eventName = imageRow[dbHandler.eventTable[dbHandler.eventName]] ?? "Uncategorized"
//                  
//                  // Parse dates
//                  guard let eventDateStr = imageRow[dbHandler.imageTable[dbHandler.eventDate]],
//                        let captureDateStr = imageRow[dbHandler.imageTable[dbHandler.captureDate]],
//                        let lastModifiedStr = imageRow[dbHandler.imageTable[dbHandler.lastModified]],
//                        let eventDate = Date.fromDatabaseString(eventDateStr),
//                        let captureDate = dateFormatter.date(from: captureDateStr),
//                        let lastModified = dateFormatter.date(from: lastModifiedStr) else {
//                      continue
//                  }
//                  
//                  // Get location details
//                  let location = Locationn(
//                      Id: imageRow[dbHandler.locationTable[dbHandler.locationId]] ?? 0,
//                      Name: imageRow[dbHandler.locationTable[dbHandler.locationName]] ?? "",
//                      Lat: imageRow[dbHandler.locationTable[dbHandler.latitude]] ?? 0.0,
//                      Lon: imageRow[dbHandler.locationTable[dbHandler.longitude]] ?? 0.0
//                  )
//                  
//                  // Get associated persons
//                  var persons = [Personn]()
//                  let personQuery = dbHandler.personTable
//                      .join(dbHandler.imagePersonTable,
//                            on: dbHandler.personTable[dbHandler.personId] == dbHandler.imagePersonTable[dbHandler.imagePersonPersonId])
//                      .filter(dbHandler.imagePersonTable[dbHandler.imagePersonImageId] == imageRow[dbHandler.imageTable[dbHandler.imageId]])
//                  
//                  for personRow in try db.prepare(personQuery) {
//                      persons.append(Personn(
//                          Id: personRow[dbHandler.personTable[dbHandler.personId]],
//                          Name: personRow[dbHandler.personTable[dbHandler.personName]] ?? "Unknown",
//                          Gender: personRow[dbHandler.personTable[dbHandler.personGender]] ?? "U",
//                          Path: personRow[dbHandler.personTable[dbHandler.personPath]] ?? ""
//                      ))
//                  }
//                  
//                  // Get all events for this image
//                  var events = [Eventt]()
//                  let eventQuery = dbHandler.eventTable
//                      .join(dbHandler.imageEventTable,
//                            on: dbHandler.eventTable[dbHandler.eventId] == dbHandler.imageEventTable[dbHandler.imageEventEventId])
//                      .filter(dbHandler.imageEventTable[dbHandler.imageEventImageId] == imageRow[dbHandler.imageTable[dbHandler.imageId]])
//                  
//                  for eventRow in try db.prepare(eventQuery) {
//                      events.append(Eventt(
//                          Id: eventRow[dbHandler.eventTable[dbHandler.eventId]],
//                          Name: eventRow[dbHandler.eventTable[dbHandler.eventName]] ?? "Unnamed Event"
//                      ))
//                  }
//                  
//                  // Create image detail
//                  let imageDetail = ImageeDetail(
//                      id: imageRow[dbHandler.imageTable[dbHandler.imageId]],
//                      path: imageRow[dbHandler.imageTable[dbHandler.imagePath]],
//                      is_Sync: imageRow[dbHandler.imageTable[dbHandler.isSync]] ?? false,
//                      capture_date: captureDate,
//                      event_date: eventDate,
//                      last_modified: lastModified,
//                      location: location,
//                      events: events,
//                      persons: persons
//                  )
//                  
//                  // Add to dictionary
//                  if result[eventName] == nil {
//                      result[eventName] = [imageDetail]
//                  } else {
//                      result[eventName]?.append(imageDetail)
//                  }
//              }
//              
//              return result
//              
//          } catch {
//              print("Error grouping images by event name: \(error)")
//              return nil
//          }
//      }
    
    
    
    func groupImagesByEventName() -> [String: [GalleryImage]]? {
        do {
            guard let db = dbHandler.db else {
                print("Database not connected")
                return nil
            }
            
            var result = [String: [GalleryImage]]()
            
            // Simplified query to fetch only essential data
            let query = dbHandler.imageTable
                .filter(dbHandler.isDeleted == false || dbHandler.isDeleted == nil)
                .join(.leftOuter, dbHandler.imageEventTable,
                      on: dbHandler.imageTable[dbHandler.imageId] == dbHandler.imageEventTable[dbHandler.imageEventImageId])
                .join(.leftOuter, dbHandler.eventTable,
                      on: dbHandler.imageEventTable[dbHandler.imageEventEventId] == dbHandler.eventTable[dbHandler.eventId])
                .select(dbHandler.imageTable[dbHandler.imageId],
                        dbHandler.imageTable[dbHandler.imagePath],
                        dbHandler.eventTable[dbHandler.eventName])
            
            for imageRow in try db.prepare(query) {
                // Get event name (use "Uncategorized" if nil)
                let eventName = imageRow[dbHandler.eventTable[dbHandler.eventName]] ?? "Uncategorized"
                
                // Create simple GalleryImage
                let galleryImage = GalleryImage(
                    id: imageRow[dbHandler.imageTable[dbHandler.imageId]],
                    path: imageRow[dbHandler.imageTable[dbHandler.imagePath]]
                )
                
                // Add to dictionary
                if result[eventName] == nil {
                    result[eventName] = [galleryImage]
                } else {
                    result[eventName]?.append(galleryImage)
                }
            }
            
            return result.isEmpty ? nil : result
            
        } catch {
            print("Error grouping images by event name: \(error)")
            return nil
        }
    }
    
    
    
    // MARK: - Group by Event Date
    
    
//    func groupImagesByEventDate() -> [String: [ImageeDetail]]? {
//        do {
//            guard let db = dbHandler.db else {
//                print("Database not connected")
//                return nil
//            }
//            
//            var result = [String: [ImageeDetail]]()
//            let dateFormatter = ISO8601DateFormatter()
//            
//            // Query all non-deleted images
//            let imageQuery = dbHandler.imageTable.filter(dbHandler.isDeleted == false || dbHandler.isDeleted == nil)
//            
//            for imageRow in try db.prepare(imageQuery) {
//                guard let eventDateStr = imageRow[dbHandler.eventDate],
//                      let eventDate = Date.fromDatabaseString(eventDateStr) else {
//                    continue
//                }
//                
//                // Format date as string key
//                let dateKey = eventDateStr
//                
//                // Get location if exists
//                var location: Locationn? = nil
//                if let locationId = imageRow[dbHandler.imageLocationId] {
//                    let locationQuery = dbHandler.locationTable.filter(dbHandler.locationId == locationId)
//                    if let locationRow = try db.pluck(locationQuery) {
//                        location = Locationn(
//                            Id: locationRow[dbHandler.locationId],
//                            Name: locationRow[dbHandler.locationName] ?? "",
//                            Lat: locationRow[dbHandler.latitude] ?? 0.0,
//                            Lon: locationRow[dbHandler.longitude] ?? 0.0
//                        )
//                    }
//                }
//                
//                // Get associated persons
//                var persons = [Personn]()
//                let personQuery = dbHandler.personTable
//                    .join(dbHandler.imagePersonTable,
//                          on: dbHandler.personTable[dbHandler.personId] == dbHandler.imagePersonTable[dbHandler.imagePersonPersonId])
//                    .filter(dbHandler.imagePersonTable[dbHandler.imagePersonImageId] == imageRow[dbHandler.imageId])
//                
//                for personRow in try db.prepare(personQuery) {
//                    let person = Personn(
//                        Id: personRow[dbHandler.personId],
//                        Name: personRow[dbHandler.personName] ?? "Unknown",
//                        Gender: personRow[dbHandler.personGender] ?? "",
//                        Path: personRow[dbHandler.personPath] ?? "U"
//                    )
//                    persons.append(person)
//                }
//                
//                // Get associated events
//                var events = [Eventt]()
//                let eventQuery = dbHandler.eventTable
//                    .join(dbHandler.imageEventTable,
//                          on: dbHandler.eventTable[dbHandler.eventId] == dbHandler.imageEventTable[dbHandler.imageEventEventId])
//                    .filter(dbHandler.imageEventTable[dbHandler.imageEventImageId] == imageRow[dbHandler.imageId])
//                
//                for eventRow in try db.prepare(eventQuery) {
//                    let event = Eventt(
//                        Id: eventRow[dbHandler.eventId],
//                        Name: eventRow[dbHandler.eventName] ?? "Unnamed Event"
//                    )
//                    events.append(event)
//                }
//                
//                // Parse dates
//                guard let captureDateStr = imageRow[dbHandler.captureDate],
//                      let lastModifiedStr = imageRow[dbHandler.lastModified],
//                      let captureDate = dateFormatter.date(from: captureDateStr),
//                      let lastModified = dateFormatter.date(from: lastModifiedStr) else {
//                    continue
//                }
//                
//                // Create image detail
//                let imageDetail = ImageeDetail(
//                    id: imageRow[dbHandler.imageId],
//                    path: imageRow[dbHandler.imagePath],
//                    is_Sync: imageRow[dbHandler.isSync] ?? false,
//                    capture_date: captureDate,
//                    event_date: eventDate,
//                    last_modified: lastModified,
//                    location: location ?? Locationn(Id: 0, Name: "", Lat: 0.0, Lon: 0.0),
//                    events: events,
//                    persons: persons
//                )
//                
//                // Add to dictionary
//                if result[dateKey] == nil {
//                    result[dateKey] = [imageDetail]
//                } else {
//                    result[dateKey]?.append(imageDetail)
//                }
//            }
//            
//            return result
//            
//        } catch {
//            print("Error grouping images by event date: \(error)")
//            return nil
//        }
//    }
    
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
    
}
