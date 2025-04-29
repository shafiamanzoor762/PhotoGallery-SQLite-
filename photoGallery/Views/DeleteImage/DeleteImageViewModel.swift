//
//  DeleteImageViewModel.swift
//  photoGallery
//
//  Created by apple on 26/04/2025.
//

import Foundation
import Combine

class DeleteImageViewModel: ObservableObject {
    private let imageHandler: ImageHandler
    private let dbHandler = DBHandler()
    private var cancellables = Set<AnyCancellable>()
    
    @Published var isDeleting = false
    @Published var deletionSuccess = false
    @Published var error: Error?
    
    init() {
        self.imageHandler = ImageHandler(dbHandler: dbHandler)
    }
    
    func deleteImage(imageId: Int, completion: @escaping () -> Void = {}) {
        isDeleting = true
        deletionSuccess = false
        error = nil
        
        imageHandler.markImageAsDeleted(imageId: imageId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isDeleting = false
                
                switch result {
                    case .success:
                        self?.deletionSuccess = true
                        completion()
                    case .failure(let error):
                        self?.error = error
                }
            }
        }
    }
}
