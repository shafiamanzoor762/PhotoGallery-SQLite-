//
//  ImageeDetails.swift
//  ComponentsApp
//
//  Created by apple on 14/03/2025.
//

import Foundation

struct ImageeDetail: Identifiable, Codable, Equatable {
    var id: Int
    var path: String  // Store just the filename
    var is_sync: Bool
    var capture_date: Date
    var event_date: Date
    var last_modified: Date
    var hash: String
    var location: Locationn
    var events: [Eventt]
    var persons: [Personn]
    
    // Computed property to get full path when needed
    var fullPath: String {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsURL.appendingPathComponent("photogallery/\(path)").path
    }
    
    static func == (lhs: ImageeDetail, rhs: ImageeDetail) -> Bool {
            return lhs.id == rhs.id
        }
}

//enum ImgesData {
//    // Creating an ImageeDetail object
//    static var imagesDetail = [
//        ImageeDetail(
//            id: 1,
//            path: "img1",
//            is_Sync: true,
//            capture_date: Date(),
//            event_date: Date(),
//            last_modified: Date(),
//        location: Locationn(Id: 1, Name: "Islamabad Pakistan", Lat: 40.7128, Lon: -74.0060),
//        events: [
//            Eventt(Id: 1, Name: "Birthday"),
//            Eventt(Id: 2, Name: "Wedding")
//        ],
//        persons: [
//            Personn(Id: 1, Name: "Moon", Gender: "Female", Path: "p19"),
//            Personn(Id: 2, Name: "Salman", Gender: "Male", Path: "p12"),
//            Personn(Id: 3, Name: "Umama", Gender: "Female", Path: "p18")
//        ]
//    ),ImageeDetail(
//        id: 4,
//        path: "img4",
//        is_Sync: true,
//        capture_date: Date(),
//        event_date: Date(),
//        last_modified: Date(),
//        location: Locationn(Id: 4, Name: "Islamabad Pakistan", Lat: 40.7128, Lon: -74.0060),
//        events: [
//            Eventt(Id: 5, Name: "Birthday"),
//            Eventt(Id: 6, Name: "Wedding")
//        ],
//        persons: [
//            Personn(Id: 6, Name: "Shahid", Gender: "M", Path: "p20"),
//            Personn(Id: 7, Name: "Salman", Gender: "M", Path: "p9"),
//            Personn(Id: 8, Name: "Raza", Gender: "M", Path: "p2"),
//            Personn(Id: 9, Name: "Saim", Gender: "M", Path: "p1")
//        ]
//    ),ImageeDetail(
//        id: 2,
//        path: "img2",
//        is_Sync: true,
//        capture_date: Date(),
//        event_date: Date(),
//        last_modified: Date(),
//        location: Locationn(Id: 2, Name: "BIIT", Lat: 40.7128, Lon: -74.0060),
//        events: [
//            Eventt(Id: 3, Name: "Ceremony")
//        ],
//        persons: [
//            Personn(Id: 4, Name: "Shahid Afridi", Gender: "M", Path: "p21")
//        ]
//    ),ImageeDetail(
//        id: 3,
//        path: "img3",
//        is_Sync: true,
//        capture_date: Date(),
//        event_date: Date(),
//        last_modified: Date(),
//        location: Locationn(Id: 3, Name: "BIIT", Lat: 40.7128, Lon: -74.0060),
//        events: [
//            Eventt(Id: 4, Name: "Debate")
//        ],
//        persons: [
//            Personn(Id: 5, Name: "Sir Ahsan", Gender: "M", Path: "p5")
//        ]
//    ),ImageeDetail(
//        id: 5,
//        path: "img5",
//        is_Sync: true,
//        capture_date: Date(),
//        event_date: Date(),
//        last_modified: Date(),
//        location: Locationn(Id: 5, Name: "Islamabad Pakistan", Lat: 40.7128, Lon: -74.0060),
//        events: [
//            Eventt(Id: 7, Name: "Birthday"),
//            Eventt(Id: 8, Name: "Wedding")
//        ],
//        persons: [
//            Personn(Id: 10, Name: "Umama", Gender: "F", Path: "p18")
//        ]
//    ),ImageeDetail(
//        id: 6,
//        path: "img6",
//        is_Sync: true,
//        capture_date: Date(),
//        event_date: Date(),
//        last_modified: Date(),
//        location: Locationn(Id: 6, Name: "BIIT", Lat: 40.7128, Lon: -74.0060),
//        events: [
//            Eventt(Id: 9, Name: "Prize Distribution"),
//            Eventt(Id: 10, Name: "Cyber Security Club")
//        ],
//        persons: [
//            Personn(Id: 13, Name: "Zaid", Gender: "M", Path: "p17"),
//            Personn(Id: 11, Name: "Sir Afraisaib", Gender: "M", Path: "p10"),
//            Personn(Id: 12, Name: "Sir Shahid", Gender: "M", Path: "p11")
//        ]
//    ),ImageeDetail(
//        id: 7,
//        path: "img7",
//        is_Sync: true,
//        capture_date: Date(),
//        event_date: Date(),
//        last_modified: Date(),
//        location: Locationn(Id: 7, Name: "Islamabad Pakistan", Lat: 40.7128, Lon: -74.0060),
//        events: [
//            Eventt(Id: 11, Name: "Birthday"),
//            Eventt(Id: 12, Name: "Wedding")
//        ],
//        persons: [
//        ]
//    ),ImageeDetail(
//        id: 8,
//        path: "img8",
//        is_Sync: true,
//        capture_date: Date(),
//        event_date: Date(),
//        last_modified: Date(),
//        location: Locationn(Id: 1, Name: "Islamabad Pakistan", Lat: 40.7128, Lon: -74.0060),
//        events: [
//            Eventt(Id: 13, Name: "Birthday"),
//            Eventt(Id: 14, Name: "Wedding")
//        ],
//        persons: [
//        ]
//    )
//    ]
//    
//}
