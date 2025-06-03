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
    
    private let searchHandler: SearchHandler
    private let eventHandler: EventHandler
    
    init() {
        self.searchHandler = SearchHandler(dbHandler: DBHandler())
        self.eventHandler = EventHandler(dbHandler: DBHandler())
    }
    
    func performSearch(
        personNames: [String],
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
        
//        print(genders)
        
        DispatchQueue.global(qos: .userInitiated).async {
            // Convert coordinates to Locationn objects
            let locationObjects = coordinates.map { coordinate in
                Locationn(id: 0, name: "", lat: coordinate.latitude, lon: coordinate.longitude)
            }
            
            let results = self.searchHandler.searchImages(
                personNames: personNames,
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
}
