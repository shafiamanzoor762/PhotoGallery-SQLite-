//
//  LabelViewModel.swift
//  photoGallery
//
//  Created by apple on 25/04/2025.
//

import Foundation

class LabelViewModel: ObservableObject {
    let dbHandler = DBHandler()
    @Published var unEditedImages: [GalleryImage] = []
    
    init() {
        refreshImages()
    }
    
    func refreshImages() {
        self.unEditedImages = dbHandler.getIncompleteImages()
    }
}

