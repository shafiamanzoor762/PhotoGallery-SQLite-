//
//  ApiHandler.swift
//  photoGallery
//
//  Created by apple on 23/04/2025.
//

import Foundation
import UIKit

class ApiHandler{
//    public static let baseUrl = "http://192.168.1.14:5000/"
    
    public static let baseUrl = "http://192.168.217.208:5000/"
    
    // Images
    public static let imagesUrl = "\(ApiHandler.baseUrl)images/"
    public static let faceUrl = "\(ApiHandler.baseUrl)face_images/"
    
    // Recognize Person
    public static let recognizePersonPath = "\(ApiHandler.baseUrl)recognize_person"
    public static let extractFacePath = "\(ApiHandler.baseUrl)extract_face"
    
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
        
        let url = URL(string: ApiHandler.extractFacePath)!
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
        
        let url = URL(string: ApiHandler.recognizePersonPath)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST" // Changed from GET to POST
        
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
}
