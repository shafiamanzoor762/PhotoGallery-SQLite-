//
//  SearchHandler.swift
//  photoGallery
//
//  Created by apple on 27/04/2025.
//


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
        eventDates: [Date] = [],
        location: Locationn? = nil,
        locationNames: [String] = [],
        dateSearchType: DateSearchType = .day
    ) -> [GalleryImage]? {
        do {
            guard let db = dbHandler.db else {
                print("Database not connected")
                return nil
            }
            
//            let dateFormatter = ISO8601DateFormatter()
            var imageIds = Set<Int>()
            var finalImages = [GalleryImage]()
            
            // MARK: - Search by Person
            var personQuery =  dbHandler.personTable
            
            if !personNames.isEmpty {
                personQuery = dbHandler.personTable.filter(personNames.contains(dbHandler.personName))
            }
                print(genders)
                
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
            
            // MARK: - Search by Event Date
            
            if !eventDates.isEmpty {
                let dateStrings = eventDates.map { $0.toDatabaseString() }
                print(dateStrings)
                let imageQuery = dbHandler.imageTable.filter(dateStrings.contains(dbHandler.eventDate))
                
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
