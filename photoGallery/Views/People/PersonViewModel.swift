//
//  PeopleViewModel.swift
//  photoGallery
//
//  Created by apple on 24/04/2025.
//

import Foundation

//struct Person: Identifiable {
//    let id: Int
//    let name: String
//    let path: String
//    let gender: String
//}
//
//struct Img: Identifiable {
//    let id: Int
//    let path: String
//}

struct PersonGroup {
    let person: Personn
    let images: [GalleryImage]
}

class PersonViewModel: ObservableObject {
    @Published var showTooltip: Bool = false
    @Published var selectedPersons: [Personn] = []
    
    @Published var selectedPersonId: Int? = nil

    private var personHandler = PersonHandler()
    
    @Published var personGroups: [PersonGroup] = []

    
    
    func loadLinkedPersons(personId: Int) {
        print("Loading linked persons for ID: \(personId)")
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let persons = try self.personHandler.getPersonAndLinkedAsList(personId: personId)
                print("Loaded persons: \(persons.count)")
                DispatchQueue.main.async {
                    self.selectedPersons = persons
                    self.showTooltip = true
                    print("Tooltip should now show: \(self.showTooltip)")
                }
            } catch {
                print("Error loading linked persons: \(error)")
            }
        }
    }
    
    func fetchData() {
        ApiHandler.fetchPersonGroups { [weak self] groups, error in
            DispatchQueue.main.async {
                if let groups = groups {
                    self?.personGroups = groups
                    print(self?.personGroups)
                } else if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    
    func createLinkBetween(person1Id: Int, person2Id: Int) {
        let personHandler = PersonHandler()
        
        do {
            let result = try personHandler.insertLink(person1Id: person1Id, person2Id: person2Id)
            
            if let error = result["error"] as? String {
                let code = result["code"] as? Int ?? 0
                print("Error creating link (\(code)): \(error)")
                
                // You might want to show an alert to the user
                DispatchQueue.main.async {
                    // Update UI state to show error if needed
                }
            } else if let message = result["message"] as? String {
                // Handle success case
                print("Success: \(message)")
                
                // Refresh your data if needed
                DispatchQueue.main.async {
                    self.fetchData() // Refresh the person groups
                }
            }
        } catch {
            print("Failed to create link: \(error.localizedDescription)")
        }
    }
    
    
}
