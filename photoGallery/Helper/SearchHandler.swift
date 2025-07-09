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
        age: Int,
        genders: [String] = [],
        eventNames: [String] = [],
        eventDates: [Date] = [],
        captureDates: [Date] = [],
        formatedDates: [String],
        location: Locationn? = nil,
        locationNames: [String] = [],
        dateSearchType: DateFilterType
    ) -> [GalleryImage]? {
        do {
            guard let db = dbHandler.db else {
                print("Database not connected")
                return nil
            }
//            print(
//                "personNames",personNames,
//                "age",age,
//                "genders",genders,
//                "event names",eventNames,
//                "event dates",eventDates,
//                "capture dates",captureDates,
//                "formated dates",formatedDates,
//                "location",location,
//                "location names",locationNames,
//                "search type",dateSearchType
//            )
            
//            let dateFormatter = ISO8601DateFormatter()
            var imageIds = Set<Int>()
            var finalImages = [GalleryImage]()
            
            // MARK: - Search by Person
//            var personQuery =  dbHandler.personTable
//            
//            if !personNames.isEmpty {
//                personQuery = dbHandler.personTable.filter(personNames.contains(dbHandler.personName))
//                print("person names")
//            }
//            
//            if (!genders.isEmpty) && (genders.first != "") {
//                    personQuery = dbHandler.personTable.filter(genders.contains(dbHandler.personGender))
//                print("person genders")
//                }
//            
//            if (age != 0) {
//                personQuery = dbHandler.personTable.filter(dbHandler.personAge == age)
//                print("person age")
//            }
//                
//                let persons = try db.prepare(personQuery)
//                let personIds = persons.map { $0[dbHandler.personId] }
//
//                print("Person IDs:", personIds)
//            
//                if !personIds.isEmpty {
//                    let imagePersonQuery = dbHandler.imagePersonTable
//                        .filter(personIds.contains(dbHandler.imagePersonPersonId))
//                    
//                    let imagePersonRows = try db.prepare(imagePersonQuery)
//                    imageIds.formUnion(imagePersonRows.map { $0[dbHandler.imagePersonImageId] })
//                }
//            print("Images After Person",imageIds)
            
            var personQuery: Table? = nil

            // Apply filters conditionally
            if !personNames.isEmpty {
                personQuery = dbHandler.personTable.filter(personNames.contains(dbHandler.personName))
                print("person names")
            }

            if !genders.isEmpty && genders.first != "" {
                if let existingQuery = personQuery {
                    personQuery = existingQuery.filter(genders.contains(dbHandler.personGender))
                } else {
                    personQuery = dbHandler.personTable.filter(genders.contains(dbHandler.personGender))
                }
                print("person genders")
            }

            if age != 0 {
                if let existingQuery = personQuery {
                    personQuery = existingQuery.filter(dbHandler.personAge == age)
                } else {
                    personQuery = dbHandler.personTable.filter(dbHandler.personAge == age)
                }
                print("person age")
            }

            // Only fetch if a query was built
            if let query = personQuery {
                let persons = try db.prepare(query)
                let personIds = persons.map { $0[dbHandler.personId] }
                print("Person IDs:", personIds)
                
                if !personIds.isEmpty {
                    let imagePersonQuery = dbHandler.imagePersonTable
                        .filter(personIds.contains(dbHandler.imagePersonPersonId))
                    
                    let imagePersonRows = try db.prepare(imagePersonQuery)
                    imageIds.formUnion(imagePersonRows.map { $0[dbHandler.imagePersonImageId] })
                }
                
                print("Images After Person", imageIds)
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
            
            print("Images After Event Names",imageIds)
            
            // MARK: - Search by Event Date
            
            if !eventDates.isEmpty {
                let dateStrings = eventDates.map { $0.toDatabaseString() }
                //print(dateStrings)
                let imageQuery = dbHandler.imageTable.filter(dateStrings.contains(dbHandler.eventDate))
                
                let images = try db.prepare(imageQuery)
                imageIds.formUnion(images.map { $0[dbHandler.imageId] })
            }
            
            print("Images After Event Dates",imageIds)
            
            if !captureDates.isEmpty {
                let dateStrings = captureDates.map { $0.toDatabaseString() }
                //print(dateStrings)
                let imageQuery = dbHandler.imageTable.filter(dateStrings.contains(dbHandler.captureDate))
                
                let images = try db.prepare(imageQuery)
                imageIds.formUnion(images.map { $0[dbHandler.imageId] })
            }
            
            print("Images After Capture Dates",imageIds)
            
            if !formatedDates.isEmpty {
                switch dateSearchType {
                    
                case .day:
                    let allImages = try db.prepare(dbHandler.imageTable)
                    for row in allImages {
                        if let dbDateStr = row[dbHandler.captureDate], // ✅ Unwrap optional string
                           let dbDate = Date.fromDatabaseString(dbDateStr),
                           formatedDates.contains(dbDate.toDayName()) {
                            imageIds.insert(row[dbHandler.imageId])
                        }
                    }

                case .month:
                    let allImages = try db.prepare(dbHandler.imageTable)
                    for row in allImages {
                        if let dbDateStr = row[dbHandler.captureDate],
                           let dbDate = Date.fromDatabaseString(dbDateStr),
                           formatedDates.contains(dbDate.toMonthName()) {
                            imageIds.insert(row[dbHandler.imageId])
                        }
                    }

                case .year:
                    let allImages = try db.prepare(dbHandler.imageTable)
                    for row in allImages {
                        if let dbDateStr = row[dbHandler.captureDate],
                           let dbDate = Date.fromDatabaseString(dbDateStr),
                           formatedDates.contains(dbDate.toYearString()) {
                            imageIds.insert(row[dbHandler.imageId])
                        }
                    }

                case .complete:
                    let query = dbHandler.imageTable.filter(formatedDates.contains(dbHandler.captureDate))
                    let rows = try db.prepare(query)
                    imageIds.formUnion(rows.map { $0[dbHandler.imageId] })
                }
            }
            
            print("Images After Formated Capture Dates",imageIds)

            
            // MARK: - Search by Location (coordinates)
//            if let location = location {
//                let locationQuery = dbHandler.locationTable
//                    .filter(dbHandler.latitude == location.latitude && dbHandler.longitude == location.longitude)
//                
//                if let locationRow = try db.pluck(locationQuery) {
//                    let locationId = locationRow[dbHandler.locationId]
//                    let imageQuery = dbHandler.imageTable.filter(dbHandler.imageLocationId == locationId)
//                    
//                    let images = try db.prepare(imageQuery)
//                    imageIds.formUnion(images.map { $0[dbHandler.imageId] })
//                }
//            }
            
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
            
            print("Images After Location",imageIds)
            
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
    
    //MARK: - Search Images With All Constraints
    func searchImagesWithAllConstraints(
        personNames: [String] = [],
        age: Int = 0,
        genders: [String] = [],
        eventNames: [String] = [],
        eventDates: [Date] = [],
        location: Locationn? = nil,
        locationNames: [String] = [],
//        dateSearchType: DateSearchType = .day
    ) -> [GalleryImage]? {
        do {
            guard let db = dbHandler.db else {
                print("Database not connected")
                return nil
            }

            var finalImageIds: Set<Int>?

            // MARK: - Person Filter
            var personQuery = dbHandler.personTable

            if !personNames.isEmpty {
                personQuery = personQuery.filter(personNames.contains(dbHandler.personName))
            }

            if !genders.isEmpty {
                personQuery = personQuery.filter(genders.contains(dbHandler.personGender))
            }

            if age != 0 {
                personQuery = personQuery.filter(dbHandler.personAge == age)
            }

            if !personNames.isEmpty || !genders.isEmpty || age != 0 {
                let personIds = try db.prepare(personQuery).map { $0[dbHandler.personId] }

                if personIds.isEmpty { return nil }

                let imagePersonRows = try db.prepare(
                    dbHandler.imagePersonTable.filter(personIds.contains(dbHandler.imagePersonPersonId))
                )
                finalImageIds = Set(imagePersonRows.map { $0[dbHandler.imagePersonImageId] })
            }

            // MARK: - Event Name Filter
            if !eventNames.isEmpty {
                let eventIds = try db.prepare(
                    dbHandler.eventTable.filter(eventNames.contains(dbHandler.eventName))
                ).map { $0[dbHandler.eventId] }

                if eventIds.isEmpty { return nil }

                let eventImageIds = try db.prepare(
                    dbHandler.imageEventTable.filter(eventIds.contains(dbHandler.imageEventEventId))
                ).map { $0[dbHandler.imageEventImageId] }

                finalImageIds = finalImageIds?.intersection(eventImageIds) ?? Set(eventImageIds)
            }

            // MARK: - Event Date Filter
            if !eventDates.isEmpty {
                let dateStrings = eventDates.map { $0.toDatabaseString() }

                let dateImageIds = try db.prepare(
                    dbHandler.imageTable.filter(dateStrings.contains(dbHandler.eventDate))
                ).map { $0[dbHandler.imageId] }

                finalImageIds = finalImageIds?.intersection(dateImageIds) ?? Set(dateImageIds)
            }

            // MARK: - Location Filter
            if let location = location {
                if let locationRow = try db.pluck(
                    dbHandler.locationTable
                        .filter(dbHandler.latitude == location.latitude && dbHandler.longitude == location.longitude)
                ) {
                    let locationId = locationRow[dbHandler.locationId]

                    let locationImageIds = try db.prepare(
                        dbHandler.imageTable.filter(dbHandler.imageLocationId == locationId)
                    ).map { $0[dbHandler.imageId] }

                    finalImageIds = finalImageIds?.intersection(locationImageIds) ?? Set(locationImageIds)
                } else {
                    return nil
                }
            }

            // MARK: - Location Name Filter
            if !locationNames.isEmpty {
                let locationIds = try db.prepare(
                    dbHandler.locationTable.filter(locationNames.contains(dbHandler.locationName))
                ).map { $0[dbHandler.locationId] }

                if locationIds.isEmpty { return nil }

                let locationNameImageIds = try db.prepare(
                    dbHandler.imageTable.filter(locationIds.contains(dbHandler.imageLocationId))
                ).map { $0[dbHandler.imageId] }

                finalImageIds = finalImageIds?.intersection(locationNameImageIds) ?? Set(locationNameImageIds)
            }

            // MARK: - Final Fetch
            guard let imageIds = finalImageIds, !imageIds.isEmpty else {
                return nil
            }

            let filteredImages = try db.prepare(
                dbHandler.imageTable
                    .filter(imageIds.contains(dbHandler.imageId))
                    .filter(dbHandler.isDeleted == false)
            )

            let result = filteredImages.map {
                GalleryImage(id: $0[dbHandler.imageId], path: $0[dbHandler.imagePath])
            }

            return result.isEmpty ? nil : result

        } catch {
            print("❌ Error filtering images with all constraints: \(error)")
            return nil
        }
    }

        
    func getNameSuggestions(for searchTerm: String) -> [String] {
        do {
            guard let db = dbHandler.db else {
                print("Database not connected")
                return []
            }
            
            let query = dbHandler.personTable
                .select(distinct: dbHandler.personName)  // Add DISTINCT keyword
                .filter(dbHandler.personName.like("\(searchTerm)%"))
                .limit(10)
            
            return try db.prepare(query).compactMap { row in
                try row.get(dbHandler.personName)
            }
        } catch {
            print("Error fetching name suggestions: \(error)")
            return []
        }
    }
}
