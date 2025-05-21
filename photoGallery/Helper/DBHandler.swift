//
//  DBManager.swift
//  ComponentsApp
//
//  Created by apple on 13/04/2025.
//

import Foundation
import SQLite

class DBHandler: ObservableObject{
    var db: Connection?

    // MARK: - Location Table
    let locationTable = Table("location")
    let locationId = Expression<Int>("id")
    let locationName = Expression<String?>("name")
    let latitude = Expression<Double?>("latitude")
    let longitude = Expression<Double?>("longitude")

    // MARK: - Person Table
    let personTable = Table("person")
    let personId = Expression<Int>("id")
    let personName = Expression<String?>("name")
    let personPath = Expression<String?>("path")
    let personGender = Expression<String?>("gender")

    // MARK: - Event Table
    let eventTable = Table("event")
    let eventId = Expression<Int>("id")
    let eventName = Expression<String?>("name")

    // MARK: - Image Table
    let imageTable = Table("image")
    let imageId = Expression<Int>("id")
    let imagePath = Expression<String>("path")
    let isSync = Expression<Bool?>("is_sync")
    let captureDate = Expression<String?>("capture_date")
    let eventDate = Expression<String?>("event_date")
    let lastModified = Expression<String?>("last_modified")
    let imageLocationId = Expression<Int?>("location_id")
    let isDeleted = Expression<Bool?>("is_deleted")
    let hash = Expression<String>("hash")

    // MARK: - ImagePerson Table
    let imagePersonTable = Table("image_person")
    let imagePersonImageId = Expression<Int>("image_id")
    let imagePersonPersonId = Expression<Int>("person_id")

    // MARK: - ImageEvent Table
    let imageEventTable = Table("image_event")
    let imageEventImageId = Expression<Int>("image_id")
    let imageEventEventId = Expression<Int>("event_id")

    // MARK: - Link Table
    let linkTable = Table("link")
    let linkPerson1Id = Expression<Int>("person1_id")
    let linkPerson2Id = Expression<Int>("person2_id")

    init() {
        connectToDatabase()
        createTables()
//        try? populateTestDataForGrouping()
        
//        generateRandomLinks(count: 10, db: db!)

    }

    func connectToDatabase() {
        do {
            let path = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            print(path)
            let completePath = path.appendingPathComponent("photogallery.sqlite3")
            db = try Connection(completePath.path)
            try db?.run("PRAGMA foreign_keys = ON") // Enable foreign key constraints
            print("Database connected successfully!")
        } catch {
            print("Error connecting to database: \(error)")
        }
    }

    func createTables() {
        do {
            // 1. Location
            try db?.run(locationTable.create(ifNotExists: true) { table in
                table.column(locationId, primaryKey: .autoincrement)
                table.column(locationName)
                table.column(latitude)
                table.column(longitude)
            })

            // 2. Person
            try db?.run(personTable.create(ifNotExists: true) { table in
                table.column(personId, primaryKey: .autoincrement)
                table.column(personName)
                table.column(personPath)
                table.column(personGender)
                table.check(personGender == "M" || personGender == "F" || personGender == "U")
            })

            // 3. Event
            try db?.run(eventTable.create(ifNotExists: true) { table in
                table.column(eventId, primaryKey: .autoincrement)
                table.column(eventName)
            })

            // 4. Image
            try db?.run(imageTable.create(ifNotExists: true) { table in
                table.column(imageId, primaryKey: .autoincrement)
                table.column(imagePath)
                table.column(isSync)
                table.column(captureDate)
                table.column(eventDate)
                table.column(lastModified)
                table.column(imageLocationId)
                table.column(isDeleted)
                table.column(hash)
                table.foreignKey(imageLocationId, references: locationTable, locationId)
            })

            // 5. ImagePerson (Many-to-Many)
            try db?.run(imagePersonTable.create(ifNotExists: true) { table in
                table.column(imagePersonImageId)
                table.column(imagePersonPersonId)
                table.primaryKey(imagePersonImageId, imagePersonPersonId)
                table.foreignKey(imagePersonImageId, references: imageTable, imageId)
                table.foreignKey(imagePersonPersonId, references: personTable, personId)
            })

            // 6. ImageEvent (Many-to-Many)
            try db?.run(imageEventTable.create(ifNotExists: true) { table in
                table.column(imageEventImageId)
                table.column(imageEventEventId)
                table.primaryKey(imageEventImageId, imageEventEventId)
                table.foreignKey(imageEventImageId, references: imageTable, imageId)
                table.foreignKey(imageEventEventId, references: eventTable, eventId)
            })

            // 7. Link (Self-Referencing Table)
            try db?.run(linkTable.create(ifNotExists: true) { table in
                table.column(linkPerson1Id)
                table.column(linkPerson2Id)
                table.primaryKey(linkPerson1Id, linkPerson2Id)
                table.foreignKey(linkPerson1Id, references: personTable, personId)
                table.foreignKey(linkPerson2Id, references: personTable, personId)
            })

            print("All tables created successfully!")

        } catch {
            print("Error creating tables: \(error)")
        }
    }   
    
    
    
    func getIncompleteImages() -> [GalleryImage] {
        var incompleteImages: [GalleryImage] = []
        
        do {
            guard let db = db else {
                print("Database not connected")
                return []
            }
            
            // Base query for non-deleted images
            let baseQuery = imageTable.filter(isDeleted == false || isDeleted == nil)
            
            for imageRow in try db.prepare(baseQuery) {
                // Check for incomplete fields
                let eventDateColumn = imageRow[eventDate]
                let hasNoEventDate = eventDateColumn == nil
                
                let hasNoEvents = try db.scalar(
                    imageEventTable
                        .filter(imageEventImageId == imageRow[imageId])
                        .count
                ) == 0
                
                let hasNoLocation = imageRow[imageLocationId] == nil
                
                var hasUnknownPersons = false
                let personQuery = personTable
                    .join(imagePersonTable, on: personTable[personId] == imagePersonTable[imagePersonPersonId])
                    .filter(imagePersonTable[imagePersonImageId] == imageRow[imageId])
                    .filter(personName == nil || personGender == "U")
                
                if try db.scalar(personQuery.count) > 0 {
                    hasUnknownPersons = true
                }
                
                if hasNoEventDate || hasNoEvents || hasNoLocation || hasUnknownPersons {
                    let galleryImage = GalleryImage(
                        id: imageRow[imageId],
                        path: imageRow[imagePath]
                    )
                    incompleteImages.append(galleryImage)
                }
            }
        } catch {
            print("Error fetching incomplete images: \(error)")
        }
        return incompleteImages
    }
    

        func populateTestDataForGrouping() throws {
            guard let db = db else {
                throw NSError(domain: "DatabaseError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Database not connected"])
            }
            
            // Create test locations if they don't exist
            let testLocations = [
                ("New York", 40.7128, -74.0060),
                ("London", 51.5074, -0.1278),
                ("Paris", 48.8566, 2.3522),
                ("Tokyo", 35.6762, 139.6503),
                ("Sydney", -33.8688, 151.2093)
            ]
            
            var locationIds = [Int]()
            for location in testLocations {
                let insert = locationTable.insert(
                    locationName <- location.0,
                    latitude <- location.1,
                    longitude <- location.2
                )
                let id = try db.run(insert)
                locationIds.append(Int(id))
            }
            
            // Create test events if they don't exist
            let testEvents = [
                "Birthday Party",
                "Wedding",
                "Conference",
                "Vacation",
                "Family Gathering"
            ]
            
            var eventIds = [Int]()
            for event in testEvents {
                let insert = eventTable.insert(
                    eventName <- event
                )
                let id = try db.run(insert)
                eventIds.append(Int(id))
            }
            
            // Get all images
            let images = try db.prepare(imageTable)
            
            // Update each image with random test data
            for image in images {
                let randomLocation = locationIds.randomElement()!
                let randomEvent = eventIds.randomElement()!
                let randomDays = Int.random(in: -365...365)
                let randomEventDate = Calendar.current.date(byAdding: .day, value: randomDays, to: Date())!
//                let dateFormatter = ISO8601DateFormatter()
                let eventDateString = randomEventDate.toDatabaseString()
                
                // Update image with location and event date
                try db.run(imageTable.filter(imageId == image[imageId])
                    .update(
                        imageLocationId <- randomLocation,
                        eventDate <- eventDateString,
                        lastModified <- dateFormatter.string(from: Date())
                    ))
                
                // Create or update image-event association
                let existingAssociation = try db.pluck(imageEventTable.filter(
                    imageEventImageId == image[imageId]
                ))
                
                if existingAssociation != nil {
                    try db.run(imageEventTable.filter(
                        imageEventImageId == image[imageId]
                    ).update(
                        imageEventEventId <- randomEvent
                    ))
                } else {
                    try db.run(imageEventTable.insert(
                        imageEventImageId <- image[imageId],
                        imageEventEventId <- randomEvent
                    ))
                }
            }
            
            print("Successfully populated test data for \(try db.scalar(imageTable.count)) images")
        }

    //MARK: - Get Image Details

    
    func generateRandomLinks(count: Int, db: Connection) {
        do {
            // Fetch all person IDs
            let persons = try db.prepare(personTable.select(personId)).map { $0[personId] }

            guard persons.count >= 2 else {
                print("Not enough persons to create links.")
                return
            }

            for _ in 0..<count {
                // Pick 2 different random persons
                let shuffled = persons.shuffled()
                let p1 = shuffled[0]
                let p2 = shuffled[1]

                // Avoid self-links
                if p1 == p2 { continue }

                // Insert into link table
                let insert = linkTable.insert(linkPerson1Id <- p1, linkPerson2Id <- p2)
                try db.run(insert)
            }

            print("✅ Random links inserted.")
        } catch {
            print("❌ Error inserting random links: \(error)")
        }
    }
    
    
    func preparePersonGroupPayload() -> [String: Any]? {
        do {
            // Get persons
            let personsQuery = try db?.prepare(personTable)
            let persons = personsQuery?.compactMap { row in
                return [
                    "id": row[personId],
                    "name": row[personName] ?? "",
                    "path": row[personPath] ?? "",
                    "gender": row[personGender] ?? ""
                ]
            } ?? []
            
            // Get links
            let linksQuery = try db?.prepare(linkTable)
            let links = linksQuery?.compactMap { row in
                return [
                    "person1_id": row[linkPerson1Id],
                    "person2_id": row[linkPerson2Id]
                ]
            } ?? []
            
            // Get image_persons
            let imagePersonQuery = try db?.prepare(imagePersonTable)
            let imagePersons = imagePersonQuery?.compactMap { row in
                return [
                    "image_id": row[imagePersonImageId],
                    "person_id": row[imagePersonPersonId]
                ]
            } ?? []
            
            // Get image_ids where not deleted
            let imageQuery = try db?.prepare(imageTable.filter(isDeleted == false || isDeleted == nil))
            let imageIDs = imageQuery?.map { $0[imageId] } ?? []
            
            return [
                "persons": persons,
                "links": links,
                "image_persons": imagePersons,
                "image_ids": imageIDs
            ]
            
        } catch {
            print("Error preparing data: \(error)")
            return nil
        }
    }



}
