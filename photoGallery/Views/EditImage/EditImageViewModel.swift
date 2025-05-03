//
//  EditImageModelView.swift
//  photoGallery
//
//  Created by apple on 27/04/2025.
//

import Foundation
import SwiftUI

//class EditImageViewModel: ObservableObject {
//    private let imageHandler: ImageHandler
//    @Published var image: ImageeDetail
//    @Published var isLoading = false
//    @Published var error: Error?
//    
//    init(image: ImageeDetail) {
//        self.image = image
//        self.imageHandler = ImageHandler(dbHandler: DBHandler())
//    }
//    
//    func saveChanges(completion: @escaping (Bool) -> Void) {
//        isLoading = true
//        error = nil
//        
//        // Convert data to expected formats
//        let persons = image.persons.isEmpty ? nil : image.persons
//        let eventNames = image.events.isEmpty ? nil : image.events.map { $0.Name }
//        let eventDate = HelperFunctions.dateString(from: image.event_date)
//        let location = image.location
//        
//        imageHandler.editImage(
//            imageId: image.id,
//            persons: persons,
//            eventNames: eventNames,
//            eventDate: eventDate,
//            location: location
//        ) { [weak self] result in
//            DispatchQueue.main.async {
//                self?.isLoading = false
//                
//                switch result {
//                case .success:
//                    self?.image.last_modified = Date()
//                    completion(true)
//                case .failure(let error):
//                    self?.error = error
//                    completion(false)
//                }
//            }
//        }
//    }
//}





// MARK: - ViewModel
class EditImageViewModel: ObservableObject {
    @Published var image: ImageeDetail
    @Published var inputEvent: String = ""
    @Published var allEvents = [Eventt]()
    
    @Published var isLoading = false
    @Published var error: Error?
    
    private let imageHandler: ImageHandler
    private let eventHandler: EventHandler
    
    init(image: ImageeDetail) {
        self.image = image
        self.imageHandler = ImageHandler(dbHandler: DBHandler())
        self.eventHandler = EventHandler(dbHandler: DBHandler())
        allEvents = eventHandler.fetchAllEvents()
    }
    
    func saveChanges(completion: @escaping (Bool) -> Void) {
        isLoading = true
        error = nil
        
        let persons = image.persons.isEmpty ? nil : image.persons
        let eventNames = image.events.isEmpty ? nil : image.events.map { $0.Name }
        let eventDate = image.event_date.toDatabaseString()
        
        
        let lat = image.location.Lat.isNaN ? nil : 0.0
        let lon = image.location.Lon.isNaN ? nil : 0.0
        
        image.location.Lat = lat ?? 0.0
        image.location.Lon = lon ?? 0.0
        
//        print("Location Name:\(image.location.Name), \(image.location.Lat), \(image.location.Lon)")
        
        print("Persons:\(image.persons)")
        
        imageHandler.editImage(
            imageId: image.id,
            persons: persons,
            eventNames: eventNames,
            eventDate: eventDate,
            location: image.location
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success:
                    self?.image.last_modified = Date()
                    completion(true)
                case .failure(let error):
                    self?.error = error
                    completion(false)
                }
            }
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
