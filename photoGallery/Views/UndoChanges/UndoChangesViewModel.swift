//
//  UndoChangesViewModel.swift
//  photoGallery
//
//  Created by apple on 21/06/2025.
//

import Foundation
class UndoChangesViewModel: ObservableObject {
    
    @Published var undoableImages: [UndoData] = []

    
    let undoHandler = UndoHandler()
    
    func getUndoableImages(){
        undoableImages = undoHandler.getLatestInactiveNonDeletedImages()
    }
    
    func getImageCompleteDetailUndo(imageId: Int, version: Int) throws -> ImageeDetail {
        guard let detail = undoHandler.getImageCompleteDetailsUndo(imageId: imageId, version: version) else {
            throw ImageError.notFound
        }
        //print(detail)
        return detail
    }
    
    func undoData(imageId: Int, version: Int) async -> Bool {
        return await undoHandler.undoData(imageId: imageId, version: version)
    }
    
    func undoAllData() async -> Bool {
        var status  = false
        for imageData in undoableImages {
            status = await undoHandler.undoData(imageId: imageData.id, version: imageData.version_no)
            if  !status {
                return false
            }
        }
        return  status
    }
}

enum ImageError: Error {
    case notFound
}
