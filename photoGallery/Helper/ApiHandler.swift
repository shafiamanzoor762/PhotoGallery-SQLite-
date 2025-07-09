//
//  ApiHandler.swift
//  photoGallery
//
//  Created by apple on 23/04/2025.
//

import Foundation
import UIKit
import SQLite


enum NetworkError: Error {
    case invalidURL
    case imageConversionFailed
    case invalidResponse
    case serverError(statusCode: Int)
    case noData
}

struct ImageeDetailData {
    var images:[ImageeDetail]
    var links: [[String: [String]]]
}

class ApiHandler{
    
//    Hp
    public static let baseUrl = "http://192.168.1.5:5000/"
    
//    Mobile HotSpot
//    public static let baseUrl = "http://192.168.153.208:5000/"
    
//    VM
//    public static let baseUrl = "http://192.168.64.4:5000/"
    

    
    // Recognize Person
    public static let recognizePersonPathUrl = "\(ApiHandler.baseUrl)recognize_person"
    public static let extractFacePathUrl = "\(ApiHandler.baseUrl)extract_face"
    
    //
    public static let addMobileImageUrl = "\(ApiHandler.baseUrl)add_mobile_image"
    public static let getPersonGroupsUrl = "\(ApiHandler.baseUrl)get_mobile_person_groups"
    public static let getUnLinkedPersonsByIdUrl = "\(ApiHandler.baseUrl)get_unlinked_persons_by_id"
    public static let moveImages  =  "\(ApiHandler.baseUrl)move_images_for_frontend"
    
    // Tagging
    public static let addTagPath = "\(ApiHandler.baseUrl)tagimage"
    public static let extractTagPath = "\(ApiHandler.baseUrl)extractImageTags"
    
    //Access Server Image
    public static let imageUrl = "images/"
    
    // Health Check
    public static let checkHealth = "\(ApiHandler.baseUrl)health"
    
    
    // MARK: - Face Extract
    
    public static func extractFacesViaApi(from image: UIImage) async -> [String] {
        print("Entering extractFacesViaApi")
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Failed to convert image to JPEG")
            return []
        }
        
        let url = URL(string: ApiHandler.extractFacePathUrl)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 120  // Increased timeout to 30 seconds
        
        // Configure multipart form data
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"face.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        do {
            // Use the new async/await API
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Server returned error status code")
                return []
            }
            
            guard let json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
                print("Failed to parse JSON response")
                return []
            }
            
            var facePaths: [String] = []
            for faceInfo in json {
                if let originalPath = faceInfo["face_path"] as? String {
                    let modifiedPath = originalPath.replacingOccurrences(of: "stored-faces", with: "face_images")
                    facePaths.append(modifiedPath)
                }
            }
            
            print("Successfully extracted \(facePaths.count) faces")
            return facePaths
            
        } catch URLError.timedOut {
            print("Request timed out")
            return []
        } catch {
            print("Error during face extraction: \(error)")
            return []
        }
    }

    // For backward compatibility (if you need to support completion handlers)
    public static func extractFacesViaApi(from image: UIImage, completion: @escaping ([String]) -> Void) {
        Task {
            let faces = await extractFacesViaApi(from: image)
            completion(faces)
        }
    }
    
    // MARK: - Face Recognize
    
    public static func recognizePersonViaAPI(faceImage: UIImage, name: String? = nil, completion: @escaping (String?) -> Void) {
        print("enter in recognize...")
        
        // First compress the image to reasonable size
        let targetSize = CGSize(width: 800, height: 800) // Adjust as needed
        let resizedImage = faceImage.resize(to: targetSize)
        guard let imageData = resizedImage?.jpegData(compressionQuality: 0.7) else {
            completion(nil)
            return
        }
        
        let url = URL(string: ApiHandler.recognizePersonPathUrl)!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30 // Increase timeout
        
        var body = Data()
        
        // Add the file data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"face.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        if let name = name {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"name\"\r\n\r\n".data(using: .utf8)!)
            body.append(name.data(using: .utf8)!)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        print("Uploading image of size: \(Double(imageData.count)/1024.0) KB")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Recognition error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response type")
                completion(nil)
                return
            }
            
            print("Status code: \(httpResponse.statusCode)")
            
            guard let data = data else {
                print("No data received")
                completion(nil)
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                print("Full response: \(json ?? [:])")
                
                if let results = json?["results"] as? [[String: Any]],
                   let firstResult = results.first,
                   let name = firstResult["name"] as? String {
                    print("Recognition completed successfully")
                    completion(name)
                } else {
                    print("Unexpected response format")
                    completion(nil)
                }
            } catch {
                print("JSON parsing error: \(error)")
                completion(nil)
            }
        }
        task.resume()
    }
    

        
    static func processImage(image: UIImage, completion: @escaping (Swift.Result<Data, Error>) -> Void) {
            let urlString = addMobileImageUrl
            guard let url = URL(string: urlString) else {
                completion(.failure(NetworkError.invalidURL))
                return
            }
            
            // Convert UIImage to JPEG data
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                completion(.failure(NetworkError.imageConversionFailed))
                return
            }
            
            // Create multipart form data request
            let boundary = UUID().uuidString
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            var body = Data()
            
            // Add image data to the request
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
            
            // Close the body
            body.append("--\(boundary)--\r\n".data(using: .utf8)!)
            
            request.httpBody = body
            
            // Create URLSession task
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(NetworkError.invalidResponse))
                    return
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    completion(.failure(NetworkError.serverError(statusCode: httpResponse.statusCode)))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(NetworkError.noData))
                    return
                }
                
                completion(.success(data))
            }
            
            task.resume()
        }
    
    
    static func fetchPersonGroups(completion: @escaping ([PersonGroup]?, Error?) -> Void) {
        guard let url = URL(string: getPersonGroupsUrl) else {
            completion(nil, NetworkError.invalidURL)
            return
        }
        
        // Prepare the request payload
        let payload = DBHandler().preparePersonGroupPayload() ?? [:]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
        } catch {
            completion(nil, error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            // Check for HTTP errors
            if let httpResponse = response as? HTTPURLResponse,
               !(200...299).contains(httpResponse.statusCode) {
                completion(nil, NetworkError.serverError(statusCode: httpResponse.statusCode))
                return
            }
            
            guard let data = data else {
                completion(nil, NetworkError.noData)
                return
            }
            print(data)
            do {
                let ph = PersonHandler()
                let personGroups = try ph.parsePersonGroups(from: data)
                print(personGroups)
                completion(personGroups, nil)
            } catch {
                completion(nil, error)
            }
        }.resume()
    }


    
    //MARK: - Load face image from server
    public static func loadFaceImage(from path: String, completion: @escaping (UIImage?) -> Void) {
        // Construct full URL by appending path to base URL
        let fullUrlString = ApiHandler.baseUrl + path
        guard let url = URL(string: fullUrlString) else {
            print("Invalid URL constructed from path: \(path)")
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 15
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Handle network errors
            if let error = error {
                print("Failed to load face image: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            // Check HTTP status code
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Server returned error status code")
                completion(nil)
                return
            }
            
            // Validate image data
            guard let imageData = data, let image = UIImage(data: imageData) else {
                print("Received invalid image data")
                completion(nil)
                return
            }
            
            DispatchQueue.main.async {
                completion(image)
            }
        }
        
        task.resume()
    }
    

    
    static func getUnlinkedPersons(personId: Int, persons: [[String: Any]], links: [[String: Any]], completion: @escaping (Swift.Result<[UnlinkedPersonResponse], Error>) -> Void) {

        guard let endpoint = URL(string: getUnLinkedPersonsByIdUrl) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
            // Prepare request body
            let requestBody: [String: Any] = [
                "personId": personId,
                "persons": persons,
                "links": links
            ]
            
            var request = URLRequest(url: endpoint)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            } catch {
                completion(.failure(error))
                return
            }
            
            // Debug print
            //print("Sending request to \(endpoint) with body: \(requestBody)")
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                // Handle network errors
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                // Check for successful HTTP status
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                    completion(.failure(NetworkError.serverError(statusCode: statusCode)))
                    return
                }
                
                // Parse successful response
                if let data = data {
                    do {
                        // First try to decode successful response
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        let response = try decoder.decode([UnlinkedPersonResponse].self, from: data)
                        completion(.success(response))
                    } catch {
                        // If that fails, try to decode an error response
                        do {
                            let errorResponse = try JSONDecoder().decode(APIError.self, from: data)
                            completion(.failure(NetworkError.invalidResponse))
                        } catch {
                            // If all else fails, return parsing error
                            completion(.failure(error))
                        }
                    }
                }
            }.resume()
        }
    
    func generateLinksDictionary(for personId: Int) throws -> [String: [String]] {

        let personList = try PersonHandler().getPersonAndLinkedAsList(personId: personId)
        
        // Ensure at least one person (the main person) exists
        guard let mainPersonPath = personList.first?.path else {
            return [:]
        }

        // Get paths of all others except the first
        let linkedPaths = personList
            .dropFirst() // Exclude the main person
            .compactMap { $0.path }

        // Create the links dictionary
        let links: [String: [String]] = [
            mainPersonPath: linkedPaths
        ]
        
        return links
    }

//    static func processLinks(from rawJson: [String: Any]) throws {
//        print(rawJson)
//        guard let links = rawJson["links"] as? [String: [String]] else {
//            throw NSError(domain: "DataError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid links format"])
//        }
//        
//        var ph = PersonHandler()
//        
//        for (path1, linkedPaths) in links {
//            // Find first person by path (skip if not found)
//            guard let person1 = try ph.findPerson(byPath: path1) else {
//                print("⚠️ Person not found with path: \(path1)")
//                continue
//            }
//            
//            // Process all linked paths
//            for path2 in linkedPaths {
//                // Find second person by path (skip if not found)
//                guard let person2 = try ph.findPerson(byPath: path2) else {
//                    print("⚠️ Person not found with path: \(path2)")
//                    continue
//                }
//                
//                // Create link if it doesn't exist
//                do {
//                    let result = try ph.insertLink(person1Id: person1.id, person2Id: person2.id)
//                    if let error = result["error"] as? String {
//                        print("ℹ️ \(error) between \(person1.id) and \(person2.id)")
//                    } else {
//                        print("✅ Created link between \(person1.id) and \(person2.id)")
//                    }
//                } catch {
//                    print("⛔ Failed to create link: \(error.localizedDescription)")
//                }
//            }
//        }
//    }
    
    static func processLinks(from linksArray: [[String: [String]]]) throws {
        var ph = PersonHandler()
        var processedLinks = 0
        
        for linkDict in linksArray {
            for (path1, linkedPaths) in linkDict {
                // Find first person by path
                guard let person1 = try ph.findPerson(byPath: path1) else {
                    print("⚠️ Person not found with path: \(path1)")
                    continue
                }
                
                // Process all linked paths
                for path2 in linkedPaths {
                    // Find second person by path
                    guard let person2 = try ph.findPerson(byPath: path2) else {
                        print("⚠️ Person not found with path: \(path2)")
                        continue
                    }
                    
                    // Create link
                    do {
                        let result = try ph.insertLink(person1Id: person1.id, person2Id: person2.id)
                        if let error = result["error"] as? String {
                            print("ℹ️ \(error) between \(person1.id) and \(person2.id)")
                        } else {
                            print("✅ Created link between \(person1.id) and \(person2.id)")
                            processedLinks += 1
                        }
                    } catch {
                        print("⛔ Failed to create link: \(error.localizedDescription)")
                    }
                }
            }
        }
        
        print("Successfully processed \(processedLinks) links")
    }
    

    static func fetchUnsyncedImages(completion: @escaping (Swift.Result<ImageeDetailData, Error>) -> Void) {

        do {
            let dbHandler = DBHandler()
            guard let db = dbHandler.db else {
                throw NSError(domain: "DatabaseError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Database not initialized"])
            }
            
            var payload: [[String: Any]] = []
            
            let unsyncedImages = try db.prepare(dbHandler.imageTable.filter(dbHandler.isSync == false))
            
            for imageRow in unsyncedImages {
                let imageIdValue = imageRow[dbHandler.imageId]
//                let imagePathValue = imageRow[dbHandler.imagePath]
                let captureDateValue = imageRow[dbHandler.captureDate]
                let eventDateValue = imageRow[dbHandler.eventDate]
                let lastModifiedValue = imageRow[dbHandler.lastModified]
                let hash = imageRow[dbHandler.hash]
                let locationIdValue = imageRow[dbHandler.imageLocationId]
                
                // Read image bytes and base64 encode
//                let fileURL = ImageHandler.getFullImagePath(filename: imagePathValue)
//                guard let imageData = try? Data(contentsOf: fileURL) else {
//                    print("❌ Could not read image at path: \(imagePathValue)")
//                    continue
//                }
//                let imageBase64 = imageData.base64EncodedString()
                
                // Persons linked to this image
                var persons: [[String: Any]] = []
                var links: [String: [String]] = [:]
                let personQuery = dbHandler.imagePersonTable
                    .join(dbHandler.personTable, on: dbHandler.imagePersonPersonId == dbHandler.personId)
                    .filter(dbHandler.imagePersonImageId == imageIdValue)
                
                for row in try db.prepare(personQuery) {
                    persons.append([
                        "id": row[dbHandler.personId],
                        "name": row[dbHandler.personName] ?? "unknown",
                        "path": row[dbHandler.personPath] ?? "",
                        "gender": row[dbHandler.personGender] ?? "U"
                    ])
                    
                    if let personId = row[dbHandler.personId] as? Int {
                            do {
                                let newLinks = try ApiHandler().generateLinksDictionary(for: personId)
                                // Merge newLinks into the main links dictionary
                                for (key, value) in newLinks {
                                    if links[key] != nil {
                                        // Append new values and remove duplicates
                                        links[key]! += value
                                        links[key]! = Array(Set(links[key]!))
                                    } else {
                                        links[key] = value
                                    }
                                }
                            } catch {
                                print("❌ Failed to generate links for person \(personId): \(error)")
                            }
                        }
                }
                print(links)
                
                // Events linked to this image
                var events: [String] = []
                let eventQuery = dbHandler.imageEventTable
                    .join(dbHandler.eventTable, on: dbHandler.imageEventEventId == dbHandler.eventId)
                    .filter(dbHandler.imageEventImageId == imageIdValue)
                
                for row in try db.prepare(eventQuery) {
                    if let name = row[dbHandler.eventName] {
                        events.append(name)
                    }
                }
                
                // Location linked to this image
                
                var location: [String]? = nil
                if let locationId = imageRow[dbHandler.imageLocationId] {
                    if let locationRow = try dbHandler.db?.pluck(dbHandler.locationTable.filter(dbHandler.locationId == locationId)) {
                        let id = locationRow[dbHandler.locationId]
                        let name = locationRow[dbHandler.locationName] ?? "Unknown"
                        let lat = locationRow[dbHandler.latitude] ?? 0.0
                        let lon = locationRow[dbHandler.longitude] ?? 0.0

                        location = [name, String(lat), String(lon)]
                    }
                }


                // Compose one image's dictionary
                let imageDict: [String: Any] = [
                    "id": imageIdValue,
                    "capture_date": captureDateValue ?? NSNull(),
                    "event_date": eventDateValue ?? NSNull(),
                    "last_modified": lastModifiedValue ?? NSNull(),
                    "location": location ?? NSNull(), // You can add location object if needed
                    "is_sync": false,
                    "hash": hash,
//                    "image_data": imageBase64,
                    "events": events,
                    "persons": persons,
                    "links": links
                ]
                
                payload.append(imageDict)
            }
            
            // Send JSON to Flask
            guard let url = URL(string: "\(ApiHandler.baseUrl)get_unsync_images") else {
                return completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)

            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    DispatchQueue.main.async { completion(.failure(error)) }
                    return
                }
                
                guard let data = data else {
                    DispatchQueue.main.async {
                        completion(.failure(NSError(domain: "No data", code: 0)))
                    }
                    return
                }
                
                
                do {

                    // Fix null event_date and location
                    
                    guard let rawJson = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                          var syncImages = rawJson["images"] as? [[String: Any]] else {
                        throw NSError(domain: "Invalid JSON", code: 1)
                    }
                    //print(rawJson)
                    //print(syncImages)
                    //print("links------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>",rawJson["links"])

                    // Fix nulls in syncImages
                    let fixedSyncImages = syncImages.map { imageDict -> [String: Any] in
                        var image = imageDict
                        
                        //print(imageDict)

                        if image["event_date"] == nil || image["event_date"] is NSNull {
                            image["event_date"] = "1111-01-01"
                        }

                        if image["location"] == nil || image["location"] is NSNull {
                            image["location"] = [
                                "id": 0,
                                "name": "",
                                "latitude": 0.0,
                                "longitude": 0.0
                            ]
                        }

                        if var persons = image["persons"] as? [[String: Any]] {
                            for i in 0..<persons.count {
                                if persons[i]["dob"] == nil || persons[i]["dob"] is NSNull {
                                    persons[i]["dob"] = "1111-01-01"
                                }
                            }
                            image["persons"] = persons
                        }

                        return image
                    }


                    // Convert back to Data
                    let fixedData = try JSONSerialization.data(withJSONObject: fixedSyncImages, options: [])
                    
                    // Now decode your model
                    let decoder = JSONDecoder()
                    
                    decoder.dateDecodingStrategy = .custom { decoder in
                        let container = try decoder.singleValueContainer()
                        let dateString = try container.decode(String.self)
                        
                        if let date = DateFormatter.sqlServerWithoutMillis.date(from: dateString) {
                            return date
                        } else if let date = DateFormatter.yyyyMMdd.date(from: dateString) {
                            return date
                        } else {
                            throw DecodingError.dataCorruptedError(
                                in: container,
                                debugDescription: "Invalid date format: \(dateString)"
                            )
                        }
                    }
                    
                    
                    let images = try decoder.decode([ImageeDetail].self, from: fixedData)
                    //print("Decoded images: \(images)")
                    guard let links = rawJson["links"] as? [[String: [String]]] else {
                        throw NSError(domain: "DataError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid links format"])
                    }

                    let imagesData = ImageeDetailData(images: images, links: links)
//                    let imagesData = ImageeDetailData(images: images, links: rawJson["links"] as! [[String: [String]]])
                    
                    DispatchQueue.main.async {
                        completion(.success(imagesData))
                    }
                    
                } catch {
                    print("Decoding failed: \(error)")
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
  
            }.resume()
        } catch {
            completion(.failure(error))
        }
    }
    
    
    
    static func syncUnsyncedImages(completion: @escaping (Swift.Result<String, Error>) -> Void) {
        fetchUnsyncedImages { result in
            switch result {
                case .success(let syncData):
                    print("Found \(syncData.images.count) unsynced images.")

                let group = DispatchGroup()
                var lastError: Error?

                for imageDetail in syncData.images {
                    let imagePath = imageDetail.path
                    let fullImageUrl = "\(ApiHandler.imageUrl)\(imagePath)"
                    group.enter()

                    ApiHandler.loadFaceImage(from: fullImageUrl) { image in
                        do {
                            guard let image = image, let imageData = image.jpegData(compressionQuality: 0.9) else {
                                throw NSError(domain: "ImageError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid or missing image"])
                            }

                            let filename = "\(UUID().uuidString).jpg"
                            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                            let photogalleryDirectory = documentsDirectory.appendingPathComponent("photogallery")

                            try FileManager.default.createDirectory(at: photogalleryDirectory, withIntermediateDirectories: true)
                            let fileURL = photogalleryDirectory.appendingPathComponent(filename)
                            try imageData.write(to: fileURL)

                            let dbHandler = DBHandler()
                            let imageHandler = ImageHandler(dbHandler: dbHandler)

                            guard let db = dbHandler.db else {
                                throw NSError(domain: "DatabaseError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Database not initialized"])
                            }

                            let hash = imageDetail.hash
                            let imageQuery = dbHandler.imageTable.filter(dbHandler.hash == hash)
                            
                            
                            var updatedPersons = imageDetail.persons
                            
                            for i in 0..<updatedPersons.count {
                                var per = imageDetail.persons[i]  // create a mutable copy
                                per.id = try PersonHandler().getOrInsertPersonId(person: per)
                                updatedPersons[i] = per
                            }
                            //print(updatedPersons)
                            
                            
                            var updatedEvents = imageDetail.events
                            
                            for i in 0..<updatedEvents.count {
                                var ev = imageDetail.events[i]  // create a mutable copy
                                ev = EventHandler(dbHandler: DBHandler()).addEventIfNotExists(eventName: ev.name, completion: {_ in })!
                                updatedEvents[i] = ev
                            }
                            print("7777777777----------\(updatedEvents)")
                            

                                        

                            if let existingImage = try db.pluck(imageQuery) {
                                // Compare last modified date
                                let existingDateStr = existingImage[dbHandler.lastModified]!
                                let newSqlDate = imageDetail.last_modified
                                
                                guard let sqliteDate = DateFormatter.sqlServerWithoutMillis.date(from: existingDateStr ) else {
                                    print("❌ One of the date conversions failed")
                                    return
                                }
                                
                                //print("\(newSqlDate)444444444----->\(sqliteDate)")

                                if newSqlDate > sqliteDate {
                                    print("📝 Updating image: \(filename)")
                                    let update = imageQuery.update(
                                        dbHandler.isDeleted <- false,
                                        dbHandler.lastModified <- HelperFunctions.currentDateString()
                                    )
                                    try db.run(update)

                                    imageHandler.editImage(
                                        imageId: Int(existingImage[dbHandler.imageId]),
                                        persons: updatedPersons,
                                        eventNames: updatedEvents,
                                        eventDate: imageDetail.event_date.toDatabaseString(),
                                        location: imageDetail.location
                                    ) { editResult in
                                        switch editResult {
                                        case .success():
                                            print("✅ Edited existing image")
                                        case .failure(let error):
                                            print("❌ Edit failed: \(error)")
                                            try? FileManager.default.removeItem(at: fileURL)
                                            lastError = error
                                        }
                                        group.leave()
                                    }
                                } else {
                                    print("⏭ No update needed for image: \(filename)")
                                    try? FileManager.default.removeItem(at: fileURL)
                                    group.leave()
                                }
                            } else {
                                // Insert new image
                                let insert = dbHandler.imageTable.insert(
                                    dbHandler.imagePath <- filename,
                                    dbHandler.hash <- hash,
                                    dbHandler.isSync <- false,
                                    dbHandler.captureDate <- imageDetail.capture_date.toDatabaseString(),
                                    dbHandler.lastModified <- HelperFunctions.currentDateString(),
                                    dbHandler.isDeleted <- false
                                )

                                let imageId = try db.run(insert)

                                imageHandler.editImage(
                                    imageId: Int(imageId),
                                    persons: updatedPersons,
                                    eventNames: updatedEvents,
                                    eventDate: imageDetail.event_date.toDatabaseString(),
                                    location: imageDetail.location
                                ) { editResult in
                                    switch editResult {
                                    case .success():
                                            
                                        print("✅ Synced image: \(filename)")
                                    case .failure(let error):
                                        print("❌ Edit failed: \(error)")
                                        try? FileManager.default.removeItem(at: fileURL)
                                        lastError = error
                                    }
                                    group.leave()
                                }
                            }
                            
                            // Access links if needed
                            do {
                                print("-------------->>>>>>>>>>> Syncing......................")
                                try processLinks(from: syncData.links)
                            } catch {
                                print("Failed to process links: \(error.localizedDescription)")
                            }

                        } catch {
                            print("❌ Error syncing image from \(fullImageUrl): \(error)")
                            lastError = error
                            group.leave()
                        }
                    }
                }

                group.notify(queue: .main) {
                    if let error = lastError {
                        completion(.failure(error))
                    } else {
                        completion(.success("All unsynced images processed successfully."))
                    }
                }

            case .failure(let error):
                print("❌ Error fetching unsynced images: \(error)")
                completion(.failure(error))
            }
        }
    }

    static func moveImagesForFrontend(sourcePath: String, destinationPath: String, persons: [[String: Any]], completion: @escaping (String) -> Void) {
        guard let url = URL(string: ApiHandler.moveImages) else {
            completion("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Prepare JSON body
        let body: [String: Any] = [
            "source_path": sourcePath,
            "destination_path": destinationPath,
            "persons": persons
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            completion("Failed to encode request body")
            return
        }

        // Send request
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion("Request failed: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                completion("No data received")
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let status = json["status"] as? String,
                   let message = json["message"] as? String {
                    
                    let result = (status == "success") ? message : "❌ \(message)"
                    completion(result)
                } else {
                    completion("Invalid response format")
                }
            } catch {
                completion("Failed to parse response")
            }
        }.resume()
    }

}
