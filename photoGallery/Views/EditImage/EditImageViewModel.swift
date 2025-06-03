//
//  EditImageModelView.swift
//  photoGallery
//
//  Created by apple on 27/04/2025.
//

import Foundation
import SwiftUI

struct UnlinkedPersonResponse: Codable {
    let person: Personn
    let persons: [Personn]
    let sharedGroups: [String]
}

struct APIError: Codable {
    let error: String
    let traceback: String?
}

struct UnlinkedPersonResponsePopupModel: Codable {
    let selectedPerson: Personn
    let unLinkedPersons: [UnlinkedPersonResponse]
}

// MARK: - ViewModel
class EditImageViewModel: ObservableObject {
    @Published var image: ImageeDetail
    @Published var inputEvent: String = ""
    @Published var allEvents = [Eventt]()
    //@Published var unLinkedPersons = [UnlinkedPersonResponse]()
    @Published var unlinkedPersonResponseModel = [UnlinkedPersonResponsePopupModel]()
    @Published var selectedGroupIDs: Set<Int> = []
    
    //@Published var selectedPerson = Personn(id: 0, name: "", gender: "", path: "")
    
    @Published var showLinkPopup = false
    @Published var isLoading = false
    @Published var error: Error?
    
    private let personViewModel = PersonViewModel()
    private let imageHandler: ImageHandler
    private let eventHandler: EventHandler
    private let dbHandler = DBHandler()
    
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
        let eventNames = image.events.isEmpty ? nil : image.events.map { $0.name }
        let eventDate = image.event_date.toDatabaseString()
        
        
        let lat = image.location.lat.isNaN ? nil : 0.0
        let lon = image.location.lon.isNaN ? nil : 0.0
        
        image.location.lat = lat ?? 0.0
        image.location.lon = lon ?? 0.0
        
//        print("Location Name:\(image.location.Name), \(image.location.Lat), \(image.location.Lon)")
        
        //print("Persons:\(image.persons)")
        
        imageHandler.editImage(
            imageId: image.id,
            persons: persons,
            eventNames: image.events,
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

    func personUnlinkDataRequest(selectedPerson: Personn) {
        do {
            // Get persons
            let personsQuery = try dbHandler.db?.prepare(dbHandler.personTable)
            let persons = personsQuery?.compactMap { row in
                return [
                    "id": row[dbHandler.personId],
                    "name": row[dbHandler.personName] ?? "",
                    "path": row[dbHandler.personPath] ?? "",
                    "gender": row[dbHandler.personGender] ?? ""
                ]
            } ?? []
            
            // Get links
            let linksQuery = try dbHandler.db?.prepare(dbHandler.linkTable)
            let links = linksQuery?.compactMap { row in
                return [
                    "person1_id": row[dbHandler.linkPerson1Id],
                    "person2_id": row[dbHandler.linkPerson2Id]
                ]
            } ?? []
            
            ApiHandler.getUnlinkedPersons(personId: selectedPerson.id, persons: persons, links: links) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let groups):
                            if groups.count > 0{
                                self?.unlinkedPersonResponseModel.append(UnlinkedPersonResponsePopupModel(selectedPerson: selectedPerson, unLinkedPersons: groups))
                            }
                            //self?.showLinkPopup = true
                            print("Successfully fetched \(self?.unlinkedPersonResponseModel) unlinked persons")
                            
                        
                    case .failure(let error):
                        print("Error fetching unlinked persons: \(error.localizedDescription)")
                        // Optionally handle the error (show alert, etc.)
                    }
                }
            }
            
        } catch {
            print("Error preparing data: \(error)")
            return
        }
    }
    
    func linkSelectedPersons(selectedPerson: Personn) {
        for id in selectedGroupIDs {
            personViewModel.createLinkBetween(person1Id: selectedPerson.id, person2Id: id)
        }
        
        selectedGroupIDs.removeAll()
    }
    
}
