//
//  SearchViewModel.swift
//  photoGallery
//
//  Created by apple on 27/04/2025.
//

import Foundation
import Combine
import MapKit

class SearchModelView: ObservableObject {
    @Published var searchResults: [GalleryImage]?
    
    @Published var selectedGender: String = ""
    
    @Published var isLoading = false
    @Published var error: Error?
    
    @Published var nameSuggestions: [String] = []
    private var searchWorkItem: DispatchWorkItem?
    
    private let searchHandler: SearchHandler
    private let eventHandler: EventHandler
    private let imageHandler: ImageHandler
    
    init() {
        self.searchHandler = SearchHandler(dbHandler: DBHandler())
        self.eventHandler = EventHandler(dbHandler: DBHandler())
        self.imageHandler = ImageHandler(dbHandler: DBHandler())
    }
    
    func performSearch(
        personNames: [String],
        age: Int,
        genders: [String],
        eventNames: [String],
        dates: [Date],
        locationNames: [String],
        coordinates: [CLLocationCoordinate2D],
        dateSearchType: SearchHandler.DateSearchType
    ) {
        isLoading = true
        error = nil
        searchResults = nil
        
        
        DispatchQueue.global(qos: .userInitiated).async {
            // Convert coordinates to Locationn objects
            let locationObjects = coordinates.map { coordinate in
                Locationn(id: 0, name: "", latitude: coordinate.latitude, longitude: coordinate.longitude)
            }
            
            let results = self.searchHandler.searchImages(
                personNames: personNames,
                age: age,
                genders: genders,
                eventNames: eventNames,
                eventDates: dates,
                location: locationObjects.first,
                locationNames: locationNames,
                dateSearchType: dateSearchType
            )
            
            DispatchQueue.main.async {
                self.searchResults = results
                self.isLoading = false
                if results == nil {
                    self.error = NSError(domain: "SearchError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No results found"])
                }
            }
        }
    }
    
    func getAllEvents() -> [Eventt]{
        return eventHandler.fetchAllEvents()
    }


    // Main grouping function
    func groupImagesPerson(_ images: [GalleryImage]) -> PersonViewModel {
        let groups = groupImagesByPerson(images)
        print(groups)
        var pm = PersonViewModel()
        pm.personGroups = groups
        print("person VM groups", pm.personGroups)
        return pm
    }
    
    func groupImagesLocation(_ images: [GalleryImage]) -> LocationViewModel {
            let groups = groupImagesByLocation(images)
            print(groups)
            var lm = LocationViewModel()
            lm.groupedImages = groups
            print("person VM groups", lm.groupedImages)
            return lm
    }
    
    func groupImagesDate(_ images: [GalleryImage]) -> DateViewModel {
            let groups = groupImagesByEventDate(images)
            print(groups)
            var dm = DateViewModel()
            dm.groupedImages = groups
            print("person VM groups", dm.groupedImages)
            return dm
    }
    
    func groupImagesEvent(_ images: [GalleryImage]) -> EventViewModel {
            let groups = groupImagesByEvent(images)
            print(groups)
            var em = EventViewModel()
            em.groupedImages = groups
            print("person VM groups", em.groupedImages)
            return em
    }
    

    // MARK: - Person Grouping
    private func groupImagesByPerson(_ images: [GalleryImage]) -> [PersonGroup] {
        var personGroups = [String: PersonGroup]() // Using person ID as key
        
        for image in images {
            guard let detail = imageHandler.getImageDetails(imageId: image.id) else { continue }
            
            for person in detail.persons {
                if var existingGroup = personGroups[person.name] {
                    existingGroup.images.append(image)
                    personGroups[person.name] = existingGroup
                } else {
                    personGroups[person.name] = PersonGroup(person: person, images: [image])
                }
            }
        }
        
        return Array(personGroups.values)
    }

    // MARK: - Event Grouping
    private func groupImagesByEvent(_ images: [GalleryImage]) -> [String: [GalleryImage]] {
        var eventGroups = [String: [GalleryImage]]()
        
        for image in images {
            guard let detail = imageHandler.getImageDetails(imageId: image.id) else { continue }
            
            for event in detail.events {
                if eventGroups[event.name] != nil {
                    eventGroups[event.name]?.append(image)
                } else {
                    eventGroups[event.name] = [image]
                }
            }
        }
        
        return eventGroups
    }

    // MARK: - Event Date Grouping
    private func groupImagesByEventDate(_ images: [GalleryImage]) -> [String: [GalleryImage]] {
        var dateGroups = [String: [GalleryImage]]()
        
        for image in images {
            guard let detail = imageHandler.getImageDetails(imageId: image.id) else { continue }
            
            let dateString = detail.event_date.toDatabaseString()
            if dateGroups[dateString] != nil {
                dateGroups[dateString]?.append(image)
            } else {
                dateGroups[dateString] = [image]
            }
        }
        
        return dateGroups
    }

    // MARK: - Location Grouping
    private func groupImagesByLocation(_ images: [GalleryImage]) -> [String: [GalleryImage]] {
        var locationGroups = [String: [GalleryImage]]()
        
        for image in images {
            guard let detail = imageHandler.getImageDetails(imageId: image.id) else { continue }
            
            let locationName = detail.location.name
            if locationGroups[locationName] != nil {
                locationGroups[locationName]?.append(image)
            } else {
                locationGroups[locationName] = [image]
            }
        }
        
        return locationGroups
    }
    
    
    func fetchNameSuggestions(searchTerm: String) {
            // Cancel previous request if it exists
            searchWorkItem?.cancel()
            
            // Create new work item
            let workItem = DispatchWorkItem { [weak self] in
                let suggestions = self?.searchHandler.getNameSuggestions(for: searchTerm) ?? []
                DispatchQueue.main.async {
                    self?.nameSuggestions = suggestions
                }
            }
            
            // Save the work item and schedule it
            searchWorkItem = workItem
            DispatchQueue.global(qos: .userInteractive).asyncAfter(
                deadline: .now() + 0.3,
                execute: workItem
            )
        }

}
