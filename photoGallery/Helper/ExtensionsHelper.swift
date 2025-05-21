//
//  ExtensionsHelper.swift
//  photoGallery
//
//  Created by apple on 28/04/2025.
//

import Foundation
import UIKit
import SwiftUI

//extension DateFormatter {
//    static let yyyyMMdd: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd"
//        return formatter
//    }()
//}

//extension Date {
//    func toString(format: String = "yyyy-MM-dd") -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = format
//        return formatter.string(from: self)
//    }
//}

extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

extension Date {
    func toDatabaseString() -> String {
        return DateFormatter.yyyyMMdd.string(from: self)
    }
    
    static func fromDatabaseString(_ string: String) -> Date? {
        return DateFormatter.yyyyMMdd.date(from: string)
    }
    
    func toISOString() -> String {
        return DateFormatter.iso8601Full.string(from: self)
    }
    
    static func fromISOString(_ string: String) -> Date? {
        return DateFormatter.iso8601Full.date(from: string)
    }
}


extension UIImage {
    func resize(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        self.draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}





extension NSNotification.Name {
    static let imageDataUpdated = Notification.Name("imageDataUpdated")
}


extension Notification.Name {
    static let refreshLabelView = Notification.Name("RefreshLabelView")
}


extension Binding where Value == String {
    func genderBinding() -> Binding<String> {
        Binding<String>(
            get: {
                switch self.wrappedValue {
                case "M": return "Male"
                case "F": return "Female"
                case "U": return "Unknown"
                default: return ""
                }
            },
            set: { newValue in
                switch newValue {
                case "Male": self.wrappedValue = "M"
                case "Female": self.wrappedValue = "F"
                default: self.wrappedValue = "U"
                }
            }
        )
    }
}
