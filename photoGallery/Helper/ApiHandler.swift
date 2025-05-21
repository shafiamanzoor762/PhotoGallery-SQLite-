//
//  ApiHandler.swift
//  photoGallery
//
//  Created by apple on 23/04/2025.
//

import Foundation
import UIKit

enum NetworkError: Error {
    case invalidURL
    case imageConversionFailed
    case invalidResponse
    case serverError(statusCode: Int)
    case noData
}

class ApiHandler{
//    public static let baseUrl = "http://192.168.1.13:5000/"
//        public static let baseUrl = "http://192.168.1.14:5000/"
//    public static let baseUrl = "http://192.168.217.208:5000/"
    
    public static let baseUrl = "http://192.168.64.4:5000/"
    

    
    // Recognize Person
    public static let recognizePersonPathUrl = "\(ApiHandler.baseUrl)recognize_person"
    public static let extractFacePathUrl = "\(ApiHandler.baseUrl)extract_face"
    
    //
    public static let addMobileImageUrl = "\(ApiHandler.baseUrl)add_mobile_image"
    public static let getPersonGroupsUrl = "\(ApiHandler.baseUrl)get_mobile_person_groups"
    public static let getUnLinkedPersonsByIdUrl = "\(ApiHandler.baseUrl)get_unlinked_persons_by_id"
    
    // Tagging
    public static let addTagPath = "\(ApiHandler.baseUrl)tagimage"
    public static let extractTagPath = "\(ApiHandler.baseUrl)extractImageTags"
    
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
            
            do {
                let ph = PersonHandler()
                let personGroups = try ph.parsePersonGroups(from: data)
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

}
