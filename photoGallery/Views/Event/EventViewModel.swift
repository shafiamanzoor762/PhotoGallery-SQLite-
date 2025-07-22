//
//  EventViewModel.swift
//  photoGallery
//
//  Created by apple on 24/04/2025.
//

import Foundation
import SwiftUI
import Combine

class EventViewModel: ObservableObject {
    @Published var groupedImages: [String: [GalleryImage]] = [:]
    
    @Published var selectedImages: Set<Int> = []
    
    @Published var isLoading = false
    @Published var error: Error?
    
    private let eventHandler: EventHandler
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.eventHandler = EventHandler(dbHandler: DBHandler())
        loadGroupedImages()
    }
    
    func loadGroupedImages() {
        isLoading = true
        error = nil
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let grouped = self.eventHandler.groupImagesByEventName() {
                DispatchQueue.main.async {
                    self.groupedImages = grouped
                    self.isLoading = false
                }
            } else {
                DispatchQueue.main.async {
                    self.error = NSError(domain: "DataError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to group images"])
                    self.isLoading = false
                }
            }
        }
    }
    
    var sortedGroupedEventKeys: [String] {
        groupedImages.keys.sorted {
            if $0 == "No Event" { return true }
            if $1 == "No Event" { return false }
            return $0 < $1
        }
    }
    
    // Helper to get the first image path for a group
    func firstImagePath(for key: String) -> String? {
        return groupedImages[key]?.first?.fullPath
    }
    
    // Helper to get event name for a group
//    func eventName(for key: String) -> String {
//        return groupedImages[key]?.first?.events.first?.Name ?? "Unknown Event"
//    }
    
    func refresh() {
        loadGroupedImages()
    }
}
