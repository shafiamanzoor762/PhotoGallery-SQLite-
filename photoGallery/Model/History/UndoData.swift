//
//  UndoData.swift
//  photoGallery
//
//  Created by apple on 21/06/2025.
//

import Foundation
struct UndoData : Identifiable{
    var id: Int
    var path: String
    var version_no: Int
    
    var fullPath: String {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsURL.appendingPathComponent("photogallery/\(path)").path
    }
}
