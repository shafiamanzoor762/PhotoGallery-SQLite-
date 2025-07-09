//
//  TrashModelView.swift
//  photoGallery
//
//  Created by apple on 03/07/2025.
//

import Foundation

class TrashViewModel : ObservableObject {
    @Published var trashImages: [GalleryImage] = []
    
    let imageHandler = ImageHandler(dbHandler: DBHandler())
    
    func getTrashImages(){
        do {
            trashImages = try imageHandler.getDeletedImages()
            print("Deleted Images:", trashImages)
        } catch {
            print("Error fetching deleted images:", error)
        }
    }
    
    func getImageCompleteDetailTrash(imageId: Int) throws -> ImageeDetail {
        guard let detail = imageHandler.getImageDetails(imageId: imageId) else {
            throw ImageError.notFound
        }
        return detail
    }
    
    func restoreImage(imageId: Int) async -> Bool {
        return await imageHandler.restoreImage(imageId: imageId)
    }
    
    
    func restoreAllImages() async -> Bool {
        var status  = false
        for imageData in trashImages {
            status = await imageHandler.restoreImage(imageId: imageData.id)
            if  !status {
                return false
            }
        }
        return  status
    }
}
