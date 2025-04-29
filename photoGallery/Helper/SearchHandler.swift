//
//  SearchHandler.swift
//  photoGallery
//
//  Created by apple on 27/04/2025.
//




//import Foundation
//import SQLite
//import UIKit

//class SearchHandler {
//    private let dbHandler: DBHandler
//    
//    init(dbHandler: DBHandler) {
//        self.dbHandler = dbHandler
//    }
//    
//    func searchImages(
//        personNames: [String] = [],
//        genders: [String] = [],
//        eventNames: [String] = [],
//        captureDates: [Date] = [],
//        location: Locationn? = nil,
//        locationNames: [String] = [],
//        dateSearchType: DateSearchType = .day // .day, .month, or .year
//    ) -> [ImageeDetail]? {
//        do {
//            guard let db = dbHandler.db else {
//                print("Database not connected")
//                return nil
//            }
//            
//            let dateFormatter = ISO8601DateFormatter()
//            var imageIds = Set<Int>()
//            var finalImages = [ImageeDetail]()
//            
//            // MARK: - Search by Person
//            if !personNames.isEmpty {
//                var personQuery = dbHandler.personTable.filter(personNames.contains(dbHandler.personName))
//                
//                if !genders.isEmpty {
//                    personQuery = personQuery.filter(genders.contains(dbHandler.personGender))
//                }
//                
//                let persons = try db.prepare(personQuery)
//                let personIds = persons.map { $0[dbHandler.personId] }
//                
//                if !personIds.isEmpty {
//                    let imagePersonQuery = dbHandler.imagePersonTable
//                        .filter(personIds.contains(dbHandler.imagePersonPersonId))
//                    
//                    let imagePersonRows = try db.prepare(imagePersonQuery)
//                    imageIds.formUnion(imagePersonRows.map { $0[dbHandler.imagePersonImageId] })
//                }
//            }
//            
//            // MARK: - Search by Event
//            if !eventNames.isEmpty {
//                let eventQuery = dbHandler.eventTable.filter(eventNames.contains(dbHandler.eventName))
//                let events = try db.prepare(eventQuery)
//                let eventIds = events.map { $0[dbHandler.eventId] }
//                
//                if !eventIds.isEmpty {
//                    let imageEventQuery = dbHandler.imageEventTable
//                        .filter(eventIds.contains(dbHandler.imageEventEventId))
//                    
//                    let imageEventRows = try db.prepare(imageEventQuery)
//                    imageIds.formUnion(imageEventRows.map { $0[dbHandler.imageEventImageId] })
//                }
//            }
//            
//            // MARK: - Search by Capture Date
//            if !captureDates.isEmpty {
//                let dateStrings = captureDates.map { dateFormatter.string(from: $0) }
//                let imageQuery = dbHandler.imageTable.filter(dateStrings.contains(dbHandler.captureDate))
//                
//                let images = try db.prepare(imageQuery)
//                imageIds.formUnion(images.map { $0[dbHandler.imageId] })
//            }
//            
//            // MARK: - Search by Location (coordinates)
//            if let location = location {
//                let locationQuery = dbHandler.locationTable
//                    .filter(dbHandler.latitude == location.Lat && dbHandler.longitude == location.Lon)
//                
//                if let locationRow = try db.pluck(locationQuery) {
//                    let locationId = locationRow[dbHandler.locationId]
//                    let imageQuery = dbHandler.imageTable.filter(dbHandler.imageLocationId == locationId)
//                    
//                    let images = try db.prepare(imageQuery)
//                    imageIds.formUnion(images.map { $0[dbHandler.imageId] })
//                }
//            }
//            
//            // MARK: - Search by Location Names
//            if !locationNames.isEmpty {
//                let locationQuery = dbHandler.locationTable
//                    .filter(locationNames.contains(dbHandler.locationName))
//                
//                let locations = try db.prepare(locationQuery)
//                let locationIds = locations.map { $0[dbHandler.locationId] }
//                
//                if !locationIds.isEmpty {
//                    let imageQuery = dbHandler.imageTable
//                        .filter(locationIds.contains(dbHandler.imageLocationId))
//                    
//                    let images = try db.prepare(imageQuery)
//                    imageIds.formUnion(images.map { $0[dbHandler.imageId] })
//                }
//            }
//            
//            // MARK: - Get Complete Image Details
//            if !imageIds.isEmpty {
//                let imageQuery = dbHandler.imageTable
//                    .filter(imageIds.contains(dbHandler.imageId))
//                    .filter(dbHandler.isDeleted == false)
//                    .join(.leftOuter, dbHandler.locationTable,
//                          on: dbHandler.imageTable[dbHandler.imageLocationId] == dbHandler.locationTable[dbHandler.locationId])
//                
//                for imageRow in try db.prepare(imageQuery) {
//                    // Parse dates
//                    guard let eventDateStr = imageRow[dbHandler.imageTable[dbHandler.eventDate]],
//                          let captureDateStr = imageRow[dbHandler.imageTable[dbHandler.captureDate]],
//                          let lastModifiedStr = imageRow[dbHandler.imageTable[dbHandler.lastModified]],
//                          let eventDate = dateFormatter.date(from: eventDateStr),
//                          let captureDate = dateFormatter.date(from: captureDateStr),
//                          let lastModified = dateFormatter.date(from: lastModifiedStr) else {
//                        continue
//                    }
//                    
//                    // Get location
//                    let location = Locationn(
//                        Id: imageRow[dbHandler.locationTable[dbHandler.locationId]] ?? 0,
//                        Name: imageRow[dbHandler.locationTable[dbHandler.locationName]] ?? "",
//                        Lat: imageRow[dbHandler.locationTable[dbHandler.latitude]] ?? 0.0,
//                        Lon: imageRow[dbHandler.locationTable[dbHandler.longitude]] ?? 0.0
//                    )
//                    
//                    // Get associated persons
//                    var persons = [Personn]()
//                    let personQuery = dbHandler.personTable
//                        .join(dbHandler.imagePersonTable,
//                              on: dbHandler.personTable[dbHandler.personId] == dbHandler.imagePersonTable[dbHandler.imagePersonPersonId])
//                        .filter(dbHandler.imagePersonTable[dbHandler.imagePersonImageId] == imageRow[dbHandler.imageTable[dbHandler.imageId]])
//                    
//                    for personRow in try db.prepare(personQuery) {
//                        persons.append(Personn(
//                            Id: personRow[dbHandler.personTable[dbHandler.personId]],
//                            Name: personRow[dbHandler.personTable[dbHandler.personName]] ?? "Unknown",
//                            Gender: personRow[dbHandler.personTable[dbHandler.personGender]] ?? "U",
//                            Path: personRow[dbHandler.personTable[dbHandler.personPath]] ?? ""
//                        ))
//                    }
//                    
//                    // Get associated events
//                    var events = [Eventt]()
//                    let eventQuery = dbHandler.eventTable
//                        .join(dbHandler.imageEventTable,
//                              on: dbHandler.eventTable[dbHandler.eventId] == dbHandler.imageEventTable[dbHandler.imageEventEventId])
//                        .filter(dbHandler.imageEventTable[dbHandler.imageEventImageId] == imageRow[dbHandler.imageTable[dbHandler.imageId]])
//                    
//                    for eventRow in try db.prepare(eventQuery) {
//                        events.append(Eventt(
//                            Id: eventRow[dbHandler.eventTable[dbHandler.eventId]],
//                            Name: eventRow[dbHandler.eventTable[dbHandler.eventName]] ?? "Unnamed Event"
//                        ))
//                    }
//                    
//                    // Create image detail
//                    let imageDetail = ImageeDetail(
//                        id: imageRow[dbHandler.imageTable[dbHandler.imageId]],
//                        path: imageRow[dbHandler.imageTable[dbHandler.imagePath]],
//                        is_Sync: imageRow[dbHandler.imageTable[dbHandler.isSync]] ?? false,
//                        capture_date: captureDate,
//                        event_date: eventDate,
//                        last_modified: lastModified,
//                        location: location,
//                        events: events,
//                        persons: persons
//                    )
//                    
//                    finalImages.append(imageDetail)
//                }
//            }
//            
//            return finalImages.isEmpty ? nil : finalImages
//            
//        } catch {
//            print("Error searching images: \(error)")
//            return nil
//        }
//    }
//
//    enum DateSearchType {
//        case day
//        case month
//        case year
//    }
//}








import Foundation
import SQLite
import UIKit

class SearchHandler {
    private let dbHandler: DBHandler
    
    init(dbHandler: DBHandler) {
        self.dbHandler = dbHandler
    }
    
    func searchImages(
        personNames: [String] = [],
        genders: [String] = [],
        eventNames: [String] = [],
        captureDates: [Date] = [],
        location: Locationn? = nil,
        locationNames: [String] = [],
        dateSearchType: DateSearchType = .day
    ) -> [GalleryImage]? {
        do {
            guard let db = dbHandler.db else {
                print("Database not connected")
                return nil
            }
            
            let dateFormatter = ISO8601DateFormatter()
            var imageIds = Set<Int>()
            var finalImages = [GalleryImage]()
            
            // MARK: - Search by Person
            if !personNames.isEmpty {
                var personQuery = dbHandler.personTable.filter(personNames.contains(dbHandler.personName))
                
                if !genders.isEmpty {
                    personQuery = personQuery.filter(genders.contains(dbHandler.personGender))
                }
                
                let persons = try db.prepare(personQuery)
                let personIds = persons.map { $0[dbHandler.personId] }
                
                if !personIds.isEmpty {
                    let imagePersonQuery = dbHandler.imagePersonTable
                        .filter(personIds.contains(dbHandler.imagePersonPersonId))
                    
                    let imagePersonRows = try db.prepare(imagePersonQuery)
                    imageIds.formUnion(imagePersonRows.map { $0[dbHandler.imagePersonImageId] })
                }
            }
            
            // MARK: - Search by Event
            if !eventNames.isEmpty {
                let eventQuery = dbHandler.eventTable.filter(eventNames.contains(dbHandler.eventName))
                let events = try db.prepare(eventQuery)
                let eventIds = events.map { $0[dbHandler.eventId] }
                
                if !eventIds.isEmpty {
                    let imageEventQuery = dbHandler.imageEventTable
                        .filter(eventIds.contains(dbHandler.imageEventEventId))
                    
                    let imageEventRows = try db.prepare(imageEventQuery)
                    imageIds.formUnion(imageEventRows.map { $0[dbHandler.imageEventImageId] })
                }
            }
            
            // MARK: - Search by Capture Date
            if !captureDates.isEmpty {
                let dateStrings = captureDates.map { dateFormatter.string(from: $0) }
                let imageQuery = dbHandler.imageTable.filter(dateStrings.contains(dbHandler.captureDate))
                
                let images = try db.prepare(imageQuery)
                imageIds.formUnion(images.map { $0[dbHandler.imageId] })
            }
            
            // MARK: - Search by Location (coordinates)
            if let location = location {
                let locationQuery = dbHandler.locationTable
                    .filter(dbHandler.latitude == location.Lat && dbHandler.longitude == location.Lon)
                
                if let locationRow = try db.pluck(locationQuery) {
                    let locationId = locationRow[dbHandler.locationId]
                    let imageQuery = dbHandler.imageTable.filter(dbHandler.imageLocationId == locationId)
                    
                    let images = try db.prepare(imageQuery)
                    imageIds.formUnion(images.map { $0[dbHandler.imageId] })
                }
            }
            
            // MARK: - Search by Location Names
            if !locationNames.isEmpty {
                let locationQuery = dbHandler.locationTable
                    .filter(locationNames.contains(dbHandler.locationName))
                
                let locations = try db.prepare(locationQuery)
                let locationIds = locations.map { $0[dbHandler.locationId] }
                
                if !locationIds.isEmpty {
                    let imageQuery = dbHandler.imageTable
                        .filter(locationIds.contains(dbHandler.imageLocationId))
                    
                    let images = try db.prepare(imageQuery)
                    imageIds.formUnion(images.map { $0[dbHandler.imageId] })
                }
            }
            
            // MARK: - Get Only Image IDs and Paths
                    if !imageIds.isEmpty {
                        let imageTable = dbHandler.imageTable
                        let imageQuery = imageTable
                            .filter(imageIds.contains(imageTable[dbHandler.imageId]))
                            .filter(dbHandler.isDeleted == false)
                        
                        for imageRow in try db.prepare(imageQuery) {
                            let galleryImage = GalleryImage(
                                id: imageRow[dbHandler.imageId],
                                path: imageRow[dbHandler.imagePath]
                            )
                            finalImages.append(galleryImage)
                        }
                    }
                    
                    return finalImages.isEmpty ? nil : finalImages
            
        } catch {
            print("Error searching images: \(error)")
            return nil
        }
    }

    enum DateSearchType {
        case day
        case month
        case year
    }
}
