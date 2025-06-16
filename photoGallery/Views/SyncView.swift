//
//  SyncView.swift
//  ComponentsApp
//
//  Created by apple on 02/11/2024.
//

import SwiftUI

struct SyncView: View {
    @State var isRequired: Bool = true
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var navBarState: NavBarState
    
    @State var isAlertShown: Bool = false
    @State var alertMessage: String = ""
    var body: some View {
        VStack{
            TextComponent(title: "Sync -> \(isRequired ? " Sync Required" : " 4 Items to Sync")")
            Image("sync").frame(width:300, height: 300)
            ButtonComponent(title: "Sync", action: {
                print("Sync Clicked")
                ApiHandler.syncUnsyncedImages() { result in
                    switch result {
                    case .success(let message):
                            alertMessage = "🎉 Success: \(message)"
                            isAlertShown = true
                    case .failure(let error):
                        alertMessage = "🚨 Failed to sync: \(error.localizedDescription)"
                            isAlertShown = true
                            
                    }
                }

            })
        }.onAppear {
            navBarState.isHidden = true
        }
        .onDisappear {
            navBarState.isHidden = false
        }
    }
}

#Preview {
    SyncView()
}
