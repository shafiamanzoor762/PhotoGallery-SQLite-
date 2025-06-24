//
//  HelperFile.swift
//  photoGallery
//
//  Created by apple on 22/04/2025.
//

import Foundation
import CommonCrypto // For SHA256 hashing
class HelperFunctions{
    
    // MARK: - Helper Methods
    
    public static func currentDateString() -> String {
        return DateFormatter.sqlServerWithoutMillis.string(from: Date())
    }
    
    //MARK: - Check Server Availability

    
    public static func checkServerStatus(completion: @escaping (Bool) -> Void) {
        let serverURL = URL(string: ApiHandler.checkHealth)!
        print("Attempting to reach server at: \(serverURL.absoluteString)")
        
        var request = URLRequest(url: serverURL)
        request.httpMethod = "HEAD"
        request.timeoutInterval = 30
        
        let task = URLSession.shared.dataTask(with: request) { _, response, error in
            print("Server check completed. Error: \(error?.localizedDescription ?? "none")")
            print("Response: \(response.debugDescription)")
            
            DispatchQueue.main.async {
                if let error = error {
                    print("Server check error: \(error)")
                    completion(false)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Invalid response type")
                    completion(false)
                    return
                }
                
                print("Server status code: \(httpResponse.statusCode)")
                completion((200...399).contains(httpResponse.statusCode))
            }
        }
        task.resume()
    }
    
    //MARK: - HASHING METHODS
    
    public static func generateImageHashSimple(imagePath: String) -> String? {
        do {
            let fileData = try Data(contentsOf: URL(fileURLWithPath: imagePath))
            var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
            fileData.withUnsafeBytes {
                _ = CC_SHA256($0.baseAddress, CC_LONG(fileData.count), &digest)
            }
            return digest.map { String(format: "%02hhx", $0) }.joined()
        } catch {
            print("Error generating hash: \(error)")
            return nil
        }
    }
    
    func generateImageHash(imagePath: String) -> String? {
        do {
            // Open the file for reading
            let fileURL = URL(fileURLWithPath: imagePath)
            let fileHandle = try FileHandle(forReadingFrom: fileURL)
            
            // Initialize SHA256 context
            var context = CC_SHA256_CTX()
            CC_SHA256_Init(&context)
            
            // Read file in chunks to handle large files
            let chunkSize = 4096
            while true {
                autoreleasepool {
                    let data = fileHandle.readData(ofLength: chunkSize)
                    if data.count > 0 {
                        data.withUnsafeBytes {
                            _ = CC_SHA256_Update(&context, $0.baseAddress, CC_LONG(data.count))
                        }
                    } else {
                        // End of file
                        return
                    }
                }
            }
            
            // Finalize the hash
            var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
            CC_SHA256_Final(&digest, &context)
            
            // Convert to hexadecimal string
            let hexString = digest.map { String(format: "%02hhx", $0) }.joined()
            return hexString
            
        } catch {
            print("Error generating hash: \(error)")
            return nil
        }
    }
    
//    if let imagePath = Bundle.main.path(forResource: "example", ofType: "jpg") {
//        if let hash = generateImageHash(imagePath: imagePath) {
//            print("Image hash: \(hash)")
//        } else {
//            print("Failed to generate hash")
//        }
//    }
    

    static func dateString(from date: Date) -> String {
        return date.toDatabaseString() // Using the Date extension
        }
    
}
