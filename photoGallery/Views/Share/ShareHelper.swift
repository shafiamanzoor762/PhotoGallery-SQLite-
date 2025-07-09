//
//  ShareHelper.swift
//  photoGallery
//
//  Created by apple on 07/07/2025.
//

import Foundation
class ShareHelper {
    
    static func generateMetadata(from image: ImageeDetail) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none

        let captureDate = formatter.string(from: image.capture_date)
        let eventDate = formatter.string(from: image.event_date)
        let locationName = image.location.name
        let coordinates = "(\(image.location.latitude), \(image.location.longitude))"

        let personDescriptions = image.persons.map { person -> String in
            let gender = person.gender == "M" ? "♂" : person.gender == "F" ? "♀" : "⚧"
            let age = person.age != nil ? "\(person.age!) yrs" : "Age N/A"
            return "\(person.name) \(gender), \(age)"
        }.joined(separator: ", ")

        let eventNames = image.events.map { $0.name }.joined(separator: ", ")

        return """
        📸 Photo taken on \(captureDate)
        🎉 Event: \(eventNames)
        📍 Location: \(locationName) \(coordinates)
        🧑‍🤝‍🧑 People in photo: \(personDescriptions)
        🗓️ Event Date: \(eventDate)
        """
    }
    
    static func getSelectedGalleryImages(from allImages: [GalleryImage], selectedIDs: Set<Int>) -> [GalleryImage] {
        return allImages.filter { selectedIDs.contains($0.id) }
    }

}
