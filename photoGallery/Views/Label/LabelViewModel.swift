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
    
    @Published var inputEvent: String = ""
    
    private let eventHandler: EventHandler
    private let imageHandler: ImageHandler

    @Published var selectedImages: Set<Int> = [] // Track selected image IDs
    @Published var showBulkEditPopup = false
    @Published var bulkEditData = BulkEditData()
    
    @Published var error: Error?
    
    // Add these properties for the bulk edit form
//    @Published var selectedEvents: [String] = []
//    @Published var eventDate = Date()
//    @Published var locationName = ""
    
    @Published var allEvents = [Eventt]()
    
    init() {
        self.eventHandler = EventHandler(dbHandler: DBHandler())
        self.imageHandler = ImageHandler(dbHandler: DBHandler())
        self.allEvents = eventHandler.fetchAllEvents()
        refreshImages()
    }
    
    func refreshImages() {
        self.unEditedImages = dbHandler.getIncompleteImages()
    }
    
    struct BulkEditData {
            var events: [Eventt] = []
            var eventDate: Date = Date()
            var location: Locationn = Locationn(Id: 0, Name: "", Lat: 0.0, Lon: 0.0)
        }
        
        func bulkEditSelectedImages() {
            guard !selectedImages.isEmpty else { return }
            
            let dispatchGroup = DispatchGroup()
            var lastError: Error?
            
            for imageId in selectedImages {
                
                print("Done ->>>>>>>> \(imageId)")
                
                dispatchGroup.enter()
                
                imageHandler.editImage(
                    imageId: imageId,
                    persons: nil,
                    eventNames: bulkEditData.events,
                    eventDate: bulkEditData.eventDate.toDatabaseString(),
                    location: Locationn(Id: 0, Name: bulkEditData.location.Name, Lat: 0.0, Lon: 0.0)
                ) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .failure(let error):
                            lastError = error
                        case .success:
                            break
                        }
                        dispatchGroup.leave()
                    }
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                if let error = lastError {
                    self.error = error
                } else {
                    self.selectedImages.removeAll()
                    self.showBulkEditPopup = false
                    self.refreshImages()
                }
            }
        }
    
    func toggleImageSelection(id: Int) {
            if selectedImages.contains(id) {
                selectedImages.remove(id)
            } else {
                selectedImages.insert(id)
            }
        }
        

    func addNewEvent(completion: @escaping (Bool) -> Void){
        eventHandler.addEventIfNotExists(eventName: inputEvent) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let newEvent):
                        self.allEvents.append(newEvent)
                        self.inputEvent = ""
                        completion(true)
                case .failure(let error):
                    self.error = error
                        completion(false)
                }
            }
        }
    }
    
    
}

