//
//  photoGalleryApp.swift
//  photoGallery
//
//  Created by apple on 21/04/2025.
//

import SwiftUI

@main
struct photoGalleryApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
    let dbHandler = DBHandler()
    
    @StateObject var navBarState = NavBarState()
    @StateObject var navManager = NavManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(navBarState)
                .environmentObject(navManager)
                .environmentObject(dbHandler)
        }
    }
}
