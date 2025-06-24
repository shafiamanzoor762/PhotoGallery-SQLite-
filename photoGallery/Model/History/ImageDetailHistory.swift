//
//  ImageDetailHistory.swift
//  photoGallery
//
//  Created by apple on 21/06/2025.
//

import Foundation
struct ImageeDetailHistory: Identifiable, Codable, Equatable {
    
    var sr_no: Int
    var id: Int
    var path: String
    var is_Sync: Bool
    var capture_date: Date
    var event_date: Date
    var last_modified: Date
    var location_id: Int
    var is_deleted: Bool
    var hash: String
    
    var version_no: Int
    var is_active: Bool
    var changed_at: Date
    
    var location: Locationn
    var events: [Eventt]
    var persons: [Personn]
    
    // Computed property to get full path when needed
    var fullPath: String {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsURL.appendingPathComponent("photogallery/\(path)").path
    }
    
    static func == (lhs: ImageeDetailHistory, rhs: ImageeDetailHistory) -> Bool {
            return lhs.id == rhs.id
        }
}
