//
//  PeopleViewModel.swift
//  photoGallery
//
//  Created by apple on 24/04/2025.
//

import Foundation

struct PersonGroup {
    let person: Personn
    var images: [GalleryImage]
}

struct MoveImageData {
    var source_path: String = ""
    var destination_path: String = ""
    var persons: [String] = []
}

class PersonViewModel: ObservableObject {
    @Published var showTooltip: Bool = false
    @Published var selectedPersons: [Personn] = []
    @Published var selectedPersonId: Int? = nil
    @Published var personGroups: [PersonGroup] = []
    @Published var selectedImages: Set<Int> = []
    
    @Published var showMoveImagesPopup = false
    @Published var moveImagesData = MoveImageData()
    
    @Published var isLoading = false
    @Published var error: Error?
    
    private var personHandler = PersonHandler()
    private var imageHandler = ImageHandler(dbHandler: DBHandler())


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
        isLoading = true
        error = nil
        
        // First check server status
        HelperFunctions.checkServerStatus { [weak self] isServerActive in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if !isServerActive {
                    // Server is down
                    self.error = NSError(domain: "ServerError",
                                       code: 0,
                                       userInfo: [NSLocalizedDescriptionKey: "Server is currently unavailable. Please try again later."])
                    self.isLoading = false
                    return
                }
                
                // Server is active - proceed with data fetch
                ApiHandler.fetchPersonGroups { groups, error in
                    DispatchQueue.main.async {
                        if let groups = groups {
                            self.personGroups = groups
                            print(self.personGroups)
                        } else if let error = error {
                            print("Error: \(error.localizedDescription)")
                            self.error = NSError(domain: "DataError",
                                               code: 1,
                                               userInfo: [NSLocalizedDescriptionKey: "Failed to load data from server"])
                        }
                        self.isLoading = false
                    }
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
    
    func moveImages(destination:  String, personGroup: PersonGroup){
        var uniquePersonPaths = Set<String>()
            
            for imageId in selectedImages {
                if let imageDetail = imageHandler.getImageDetails(imageId: imageId) {
                    for person in imageDetail.persons {
                        uniquePersonPaths.insert(person.path)
                    }
                }
            }
            
            // Convert to required payload format
            let personsPayload: [[String: Any]] = uniquePersonPaths.map { path in
                ["path": path]
            }

        print("sourcePath: \(personGroup.person.path), destinationPath: \(destination), selectedPersons: \(personsPayload)")
        moveSelectedImages(sourcePath: personGroup.person.path, destinationPath: destination, selectedPersons: personsPayload)
    }
    
    func moveSelectedImages(sourcePath: String, destinationPath: String, selectedPersons: [[String: Any]]) {
        isLoading = true
        error = nil

        HelperFunctions.checkServerStatus { [weak self] isServerActive in
            guard let self = self else { return }

            DispatchQueue.main.async {
                if !isServerActive {
                    self.error = NSError(
                        domain: "ServerError",
                        code: 0,
                        userInfo: [NSLocalizedDescriptionKey: "Server is currently unavailable. Please try again later."]
                    )
                    self.isLoading = false
                    return
                }

                // ✅ Proceed to API call
                ApiHandler.moveImagesForFrontend(
                    sourcePath: sourcePath,
                    destinationPath: destinationPath,
                    persons: selectedPersons
                ) { resultMessage in
                    DispatchQueue.main.async {
                        if resultMessage.starts(with: "❌") {
                            // Extract just the error text
                            let cleanMessage = resultMessage.replacingOccurrences(of: "❌ ", with: "")
                            self.error = NSError(
                                domain: "MoveError",
                                code: 1,
                                userInfo: [NSLocalizedDescriptionKey: cleanMessage]
                            )
                        } else {
                            // Move was successful — update your state/UI if needed
                            print("✅ \(resultMessage)")
                            // Optionally trigger a refresh or flag UI update
                        }
                        self.isLoading = false
                    }
                }
            }
        }
    }

    
    func refresh() {
        fetchData()
    }
    
}
