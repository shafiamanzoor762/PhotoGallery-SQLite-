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
    let personDob = Expression<String?>("dob")
    let personAge = Expression<Int?>("age")

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

    
    //MARK: - HISTORY TABLES
    let locationHistoryTable = Table("location_history")
    let locationHisId = Expression<Int>("sr_no")
    let locationHisOriginalId = Expression<Int>("id")
    let locationHisName = Expression<String?>("name")
    let locationHisLatitude = Expression<Double?>("latitude")
    let locationHisLongitude = Expression<Double?>("longitude")
    let locationHisVersion = Expression<Int>("version_no")
    let locationHisIsActive = Expression<Bool>("is_active")
    let locationHisChangedAt = Expression<String?>("changed_at")
    
    let personHistoryTable = Table("person_history")
    let personHisId = Expression<Int>("sr_no")
    let personHisOriginalId = Expression<Int>("id")
    let personHisName = Expression<String?>("name")
    let personHisPath = Expression<String?>("path")
    let personHisGender = Expression<String?>("gender")
    let personHisDob = Expression<String?>("dob")
    let personHisAge = Expression<Int?>("age")
    let personHisVersion = Expression<Int>("version_no")
    let personHisIsActive = Expression<Bool>("is_active")
    let personHisChangedAt = Expression<String?>("changed_at")
    
    let eventHistoryTable = Table("event_history")
    let eventHisId = Expression<Int>("sr_no")
    let eventHisOriginalId = Expression<Int>("id")
    let eventHisName = Expression<String?>("name")
    let eventHisVersion = Expression<Int>("version_no")
    let eventHisIsActive = Expression<Bool>("is_active")
    let eventHisChangedAt = Expression<String?>("changed_at")
    
    let imageHistoryTable = Table("image_history")
    let imageHisId = Expression<Int>("sr_no")
    let imageHisOriginalId = Expression<Int>("id")
    let imageHisPath = Expression<String>("path")
    let imageHisIsSync = Expression<Bool?>("is_sync")
    let imageHisCaptureDate = Expression<String?>("capture_date")
    let imageHisEventDate = Expression<String?>("event_date")
    let imageHisLastModified = Expression<String?>("last_modified")
    let imageHisLocationId = Expression<Int?>("location_id")
    let imageHisIsDeleted = Expression<Bool?>("is_deleted")
    let imageHisHash = Expression<String>("hash")
    let imageHisVersion = Expression<Int>("version_no")
    let imageHisIsActive = Expression<Bool>("is_active")
    let imageHisChangedAt = Expression<String?>("changed_at")
    
    let imagePersonHistoryTable = Table("image_person_history")
    let imagePersonHisId = Expression<Int>("sr_no")
    let imagePersonHisImageId = Expression<Int>("image_id")
    let imagePersonHisPersonId = Expression<Int>("person_id")
    let imagePersonHisVersion = Expression<Int>("version_no")
    let imagePersonHisIsActive = Expression<Bool>("is_active")
    let imagePersonHisChangedAt = Expression<String?>("changed_at")
    
    let imageEventHistoryTable = Table("image_event_history")
    let imageEventHisId = Expression<Int>("sr_no")
    let imageEventHisImageId = Expression<Int>("image_id")
    let imageEventHisEventId = Expression<Int>("event_id")
    let imageEventHisVersion = Expression<Int>("version_no")
    let imageEventHisIsActive = Expression<Bool>("is_active")
    let imageEventHisChangedAt = Expression<String?>("changed_at")
    
    let linkHistoryTable = Table("link_history")
    let linkHisId = Expression<Int>("sr_no")
    let linkHisPerson1Id = Expression<Int>("person1_id")
    let linkHisPerson2Id = Expression<Int>("person2_id")
    let linkHisVersion = Expression<Int>("version_no")
    let linkHisIsActive = Expression<Bool>("is_active")
    let linkHisChangedAt = Expression<String?>("changed_at")
    
    
//    Create a New Table for Custom Folders:
    let customFolderTable = Table("custom_folder")
    let folderId = Expression<Int>("id")
    let folderName = Expression<String>("name")       // e.g. "Favorites", "Birthday 2023"
    let folderCreatedAt = Expression<String>("created_at") // Optional

//    Create a Link Table between Folders and Images (Many-to-Many):
    let imageFolderTable = Table("image_folder")
    let imageFolderImageId = Expression<Int>("image_id")
    let imageFolderFolderId = Expression<Int>("folder_id")
        
    
    init() {
        connectToDatabase()
        createTables()
        createHistoryTables()
        createTriggers()
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
                table.column(personDob)
                table.column(personAge)
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
    
    func createHistoryTables() {
            do {
                // Location History
                try db?.run(locationHistoryTable.create(ifNotExists: true) { table in
                    table.column(locationHisId, primaryKey: .autoincrement)
                    table.column(locationHisOriginalId)
                    table.column(locationHisName)
                    table.column(locationHisLatitude)
                    table.column(locationHisLongitude)
                    table.column(locationHisVersion)
                    table.column(locationHisIsActive)
                    table.column(locationHisChangedAt)
                })
                
                // Person History
                try db?.run(personHistoryTable.create(ifNotExists: true) { table in
                    table.column(personHisId, primaryKey: .autoincrement)
                    table.column(personHisOriginalId)
                    table.column(personHisName)
                    table.column(personHisPath)
                    table.column(personHisGender)
                    table.column(personHisDob)
                    table.column(personHisAge)
                    table.column(personHisVersion)
                    table.column(personHisIsActive)
                    table.column(personHisChangedAt)
                })
                
                // Event History
                try db?.run(eventHistoryTable.create(ifNotExists: true) { table in
                    table.column(eventHisId, primaryKey: .autoincrement)
                    table.column(eventHisOriginalId)
                    table.column(eventHisName)
                    table.column(eventHisVersion)
                    table.column(eventHisIsActive)
                    table.column(eventHisChangedAt)
                })
                
                // Image History
                try db?.run(imageHistoryTable.create(ifNotExists: true) { table in
                    table.column(imageHisId, primaryKey: .autoincrement)
                    table.column(imageHisOriginalId)
                    table.column(imageHisPath)
                    table.column(imageHisIsSync)
                    table.column(imageHisCaptureDate)
                    table.column(imageHisEventDate)
                    table.column(imageHisLastModified)
                    table.column(imageHisLocationId)
                    table.column(imageHisIsDeleted)
                    table.column(imageHisHash)
                    table.column(imageHisVersion)
                    table.column(imageHisIsActive)
                    table.column(imageHisChangedAt)
                })
                
                // Image-Person History
                try db?.run(imagePersonHistoryTable.create(ifNotExists: true) { table in
                    table.column(imagePersonHisId, primaryKey: .autoincrement)
                    table.column(imagePersonHisImageId)
                    table.column(imagePersonHisPersonId)
                    table.column(imagePersonHisVersion)
                    table.column(imagePersonHisIsActive)
                    table.column(imagePersonHisChangedAt)
                })
                
                // Image-Event History
                try db?.run(imageEventHistoryTable.create(ifNotExists: true) { table in
                    table.column(imageEventHisId, primaryKey: .autoincrement)
                    table.column(imageEventHisImageId)
                    table.column(imageEventHisEventId)
                    table.column(imageEventHisVersion)
                    table.column(imageEventHisIsActive)
                    table.column(imageEventHisChangedAt)
                })
                
                // Link History
                try db?.run(linkHistoryTable.create(ifNotExists: true) { table in
                    table.column(linkHisId, primaryKey: .autoincrement)
                    table.column(linkHisPerson1Id)
                    table.column(linkHisPerson2Id)
                    table.column(linkHisVersion)
                    table.column(linkHisIsActive)
                    table.column(linkHisChangedAt)
                })
                
                print("All history tables created successfully!")
            } catch {
                print("Error creating history tables: \(error)")
            }
        }
    
    // MARK: -  Triggers
    func createTriggers() {
            do {
                // 1. Image History Trigger
                try db?.run("""
                    CREATE TRIGGER IF NOT EXISTS trg_UpdateImageHistory
                    AFTER UPDATE ON image
                    BEGIN
                        INSERT INTO image_history (
                            id, path, is_sync, capture_date, event_date, 
                            last_modified, location_id, version_no, 
                            is_deleted, hash, is_active, changed_at
                        )
                        SELECT 
                            old.id,
                            old.path,
                            old.is_sync,
                            old.capture_date,
                            old.event_date,
                            old.last_modified,
                            old.location_id,
                            IFNULL((SELECT MAX(version_no) FROM image_history WHERE id = old.id), 0) + 1,
                            old.is_deleted,
                            old.hash,
                            0,
                            datetime('now')
                        FROM image old
                        WHERE old.id = NEW.id;
                    END;
                """)
                
                // 2. Person History Trigger
                try db?.run("""
                    CREATE TRIGGER IF NOT EXISTS trg_UpdatePersonHistory
                    AFTER UPDATE ON person
                    BEGIN
                        INSERT INTO person_history (
                            id, name, path, gender, version_no, 
                            is_active, changed_at, dob, age
                        )
                        SELECT 
                            old.id,
                            old.name,
                            old.path,
                            old.gender,
                            IFNULL((SELECT MAX(version_no) FROM person_history WHERE id = old.id), 0) + 1,
                            0,
                            datetime('now'),
                            old.dob,
                            old.age
                        FROM person old
                        WHERE old.id = NEW.id;
                    END;
                """)
                
                // 3. Image Event History Trigger (on DELETE)
                try db?.run("""
                    CREATE TRIGGER IF NOT EXISTS trg_UpdateImageEventHistory
                    AFTER DELETE ON image_event
                    BEGIN
                        INSERT INTO image_event_history (
                            image_id, event_id, version_no, is_active, changed_at
                        )
                        SELECT 
                            OLD.image_id,
                            OLD.event_id,
                            IFNULL((SELECT MAX(version_no) FROM image_event_history 
                                    WHERE image_id = OLD.image_id AND event_id = OLD.event_id), 0) + 1,
                            0,
                            datetime('now');
                    END;
                """)

                
                // 4. Image Person History Trigger
                try db?.run("""
                    CREATE TRIGGER IF NOT EXISTS trg_UpdateImagePersonHistory
                    AFTER UPDATE ON image_person
                    BEGIN
                        INSERT INTO image_person_history (
                            image_id, person_id, version_no, is_active, changed_at
                        )
                        SELECT 
                            old.image_id,
                            old.person_id,
                            IFNULL((SELECT MAX(version_no) FROM image_person_history 
                                   WHERE image_id = old.image_id AND person_id = old.person_id), 0) + 1,
                            0,
                            datetime('now')
                        FROM image_person old
                        WHERE old.image_id = NEW.image_id AND old.person_id = NEW.person_id;
                    END;
                """)
                
                // 5. Link History Trigger
                try db?.run("""
                    CREATE TRIGGER IF NOT EXISTS trg_UpdateLinkHistory
                    AFTER UPDATE ON link
                    BEGIN
                        INSERT INTO link_history (
                            person1_id, person2_id, version_no, is_active, changed_at
                        )
                        SELECT 
                            old.person1_id,
                            old.person2_id,
                            IFNULL((SELECT MAX(version_no) FROM link_history 
                                   WHERE person1_id = old.person1_id AND person2_id = old.person2_id), 0) + 1,
                            0,
                            datetime('now')
                        FROM link old
                        WHERE old.person1_id = NEW.person1_id AND old.person2_id = NEW.person2_id;
                    END;
                """)
                
                print("All triggers created successfully!")
            } catch {
                print("Error creating triggers: \(error)")
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
                    "gender": row[personGender] ?? "",
                    "dob": row[personDob] ?? Date().toDatabaseString(),
                    "age": row[personAge] ?? 0
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
