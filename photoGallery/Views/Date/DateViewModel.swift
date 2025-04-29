//
//  DateViewModel.swift
//  photoGallery
//
//  Created by apple on 24/04/2025.
//

import Foundation
import SwiftUI
import Combine

class DateModelView: ObservableObject {
    @Published var groupedImages: [String: [GalleryImage]] = [:]
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
            if let grouped = self.eventHandler.groupImagesByEventDate() {
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
    
    // Helper to get the first image path for a group
    func firstImagePath(for key: String) -> String? {
        return groupedImages[key]?.first?.fullPath
    }
    
    // Helper to get event name for a group
//    func eventDate(for key: String) -> Date {
//        return groupedImages[key]?.first?.event_date ?? Date.distantFuture
//    }
//    
//    func eventName(for key: String) -> String {
//        return groupedImages[key]?.first?.events.first?.Name ?? "Unknown Event"
//    }
//
//    func formattedEventDate(for key: String) -> String {
//        guard let date = groupedImages[key]?.first?.event_date else {
//            return "Unknown Date"
//        }
//        let formatter = DateFormatter()
//        formatter.dateStyle = .medium
//        formatter.timeStyle = .none
//        return formatter.string(from: date)
//    }
    
    func refresh() {
        loadGroupedImages()
    }
}
