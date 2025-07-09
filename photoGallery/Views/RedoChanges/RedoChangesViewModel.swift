//
//  RedoViewModel.swift
//  photoGallery
//
//  Created by apple on 04/07/2025.
//

import Foundation

class RedoChangesViewModel: ObservableObject {
    
    @Published var redoableImages: [UndoData] = []

    
    let redoHandler = RedoHandler()
    let undoHandler = UndoHandler()
    
    func getRedoableImages(){
        redoableImages = redoHandler.getLatestActiveNonDeletedRedoImages()
    }
    
    func getImageCompleteDetailUndo(imageId: Int, version: Int) throws -> ImageeDetail {
        guard let detail = undoHandler.getImageCompleteDetailsUndo(imageId: imageId, version: version) else {
            throw ImageError.notFound
        }
        //print(detail)
        return detail
    }
    
    func redoData(imageId: Int, version: Int) async -> Bool {
        return await redoHandler.redoData(imageId: imageId, version: version)
    }
    
    func redoAllData() async -> Bool {
        var status  = false
        for imageData in redoableImages {
            status = await redoHandler.redoData(imageId: imageData.id, version: imageData.version_no)
            if  !status {
                return false
            }
        }
        return  status
    }
}
