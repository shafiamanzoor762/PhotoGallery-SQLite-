//
//  LocationModel.swift
//  ComponentsApp
//
//  Created by apple on 06/03/2025.
//

import Foundation
import SQLite
import UIKit

class LocationHandler {
    
private let dbHandler: DBHandler

init(dbHandler: DBHandler) {
    self.dbHandler = dbHandler
}
    // MARK: - Get Image Complete Detail
    
    func groupImagesByLocation() -> [String: [GalleryImage]]? {
        do {
            guard let db = dbHandler.db else {
                print("Database not connected")
                return nil
            }
            
            var result = [String: [GalleryImage]]()
            
            // Query only image IDs, paths, and location names
            let imageQuery = dbHandler.imageTable
                .filter(dbHandler.isDeleted == false || dbHandler.isDeleted == nil)
                .join(.leftOuter, dbHandler.locationTable,
                      on: dbHandler.imageTable[dbHandler.imageLocationId] == dbHandler.locationTable[dbHandler.locationId])
                .select(dbHandler.imageTable[dbHandler.imageId],
                        dbHandler.imageTable[dbHandler.imagePath],
                        dbHandler.locationTable[dbHandler.locationName])
            
            for imageRow in try db.prepare(imageQuery) {
                // Get location name (use "Unknown Location" if nil)
                if let locationname = imageRow[dbHandler.locationTable[dbHandler.locationName]], !locationname.isEmpty {
                    
                    // Create GalleryImage with just the essential data
                    let galleryImage = GalleryImage(
                        id: imageRow[dbHandler.imageTable[dbHandler.imageId]],
                        path: imageRow[dbHandler.imageTable[dbHandler.imagePath]]
                    )
                    
                    // Add to dictionary
                    if result[locationname] == nil {
                        result[locationname] = [galleryImage]
                    } else {
                        result[locationname]?.append(galleryImage)
                    }
                }
                
            }
            
            return result.isEmpty ? nil : result
            
        } catch {
            print("Error grouping images by location: \(error)")
            return nil
        }
    }

}
