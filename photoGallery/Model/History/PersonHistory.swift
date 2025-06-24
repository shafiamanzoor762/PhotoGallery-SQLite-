//
//  PersonHistory.swift
//  photoGallery
//
//  Created by apple on 20/06/2025.
//

import Foundation
struct PersonHistory: Codable {
    var sr_no: Int
    var id: Int
    var name: String
    var gender: String
    var path: String
    var dob: Date?
    var age: Int?
    
    var version_no: Int
    var is_active: Bool
    var changed_at: Date
}
