//
//  GalleryImage.swift
//  photoGallery
//
//  Created by apple on 28/04/2025.
//

import Foundation
struct GalleryImage: Identifiable, Equatable {
    let id: Int
    let path: String
    
    var fullPath: String {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsURL.appendingPathComponent("photogallery/\(path)").path
    }
}
