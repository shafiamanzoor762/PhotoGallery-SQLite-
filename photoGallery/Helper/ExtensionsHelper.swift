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
//    
//    static let iso8601Full: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
//        formatter.calendar = Calendar(identifier: .iso8601)
//        formatter.timeZone = TimeZone(secondsFromGMT: 0)
//        formatter.locale = Locale(identifier: "en_US_POSIX")
//        return formatter
//    }()
//    
//    static let yyyyMMdd_HHmmss: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        formatter.locale = Locale(identifier: "en_US_POSIX")
//        return formatter
//    }()
//    
//    
//    // ✅ NEW: SQL Server format with milliseconds
//    static let sqlServerWithoutMillis: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        formatter.locale = Locale(identifier: "en_US_POSIX")
//        formatter.timeZone = TimeZone(secondsFromGMT: 0)
//        return formatter
//    }()
//}
//
//extension Date {
//    func toDatabaseString() -> String {
//        return DateFormatter.yyyyMMdd.string(from: self)
//    }
//
//    static func fromDatabaseString(_ string: String) -> Date? {
//        return DateFormatter.yyyyMMdd.date(from: string)
//    }
//
//    func toISOString() -> String {
//        return DateFormatter.iso8601Full.string(from: self)
//    }
//
//    static func fromISOString(_ string: String) -> Date? {
//        return DateFormatter.iso8601Full.date(from: string)
//    }
//
//    func toSqlServerFormat() -> String {
//        return DateFormatter.sqlServerWithoutMillis.string(from: self)
//    }
//    
//    // ✅ NEW: Parse SQL Server format with milliseconds
//    static func fromSqlServerFormat(_ string: String) -> Date? {
//        return DateFormatter.sqlServerWithoutMillis.date(from: string)
//    }
//    
//    static func toDayName() -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "EEEE"
//        return formatter.string(from: self)
//    }
//    
//    static func toMonthName() -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "MMMM"
//        return formatter.string(from: self)
//    }
//    
//    static func toYearString() -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy"
//        return formatter.string(from: self)
//    }
//}

extension DateFormatter {
    
    // Standard date formats
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
    
    static let yyyyMMdd_HHmmss: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    static let sqlServerWithoutMillis: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
    
    static let dayName: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE" // e.g., Monday
        return formatter
    }()
    
    static let monthName: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM" // e.g., January
        return formatter
    }()
    
    static let yearOnly: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy" // e.g., 2024
        return formatter
    }()
}

extension Date {
    
    // MARK: - Format to String
    func toDatabaseString() -> String {
        return DateFormatter.yyyyMMdd.string(from: self)
    }
    
    func toISOString() -> String {
        return DateFormatter.iso8601Full.string(from: self)
    }
    
    func toSqlServerFormat() -> String {
        return DateFormatter.sqlServerWithoutMillis.string(from: self)
    }
    
    func toDayName() -> String {
        return DateFormatter.dayName.string(from: self)
    }

    func toMonthName() -> String {
        return DateFormatter.monthName.string(from: self)
    }

    func toYearString() -> String {
        return DateFormatter.yearOnly.string(from: self)
    }
    
    // MARK: - Parse from String
    static func fromDatabaseString(_ string: String) -> Date? {
        return DateFormatter.yyyyMMdd.date(from: string)
    }
    
    static func fromISOString(_ string: String) -> Date? {
        return DateFormatter.iso8601Full.date(from: string)
    }
    
    static func fromSqlServerFormat(_ string: String) -> Date? {
        return DateFormatter.sqlServerWithoutMillis.date(from: string)
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
