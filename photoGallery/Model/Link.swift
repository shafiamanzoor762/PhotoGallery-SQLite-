//
//  PersonLink.swift
//  photoGallery
//
//  Created by apple on 05/07/2025.
//

import Foundation

struct Link: Identifiable, Codable, Equatable, Hashable {
    var id: String { "\(person1Id)-\(person2Id)" } // unique identifier
    let person1Id: Int
    let person2Id: Int
}
