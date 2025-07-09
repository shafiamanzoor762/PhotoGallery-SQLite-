//
//  FeaturedFacesViewModel.swift
//  photoGallery
//
//  Created by apple on 05/07/2025.
//

import SwiftUI

struct FeaturedFacesView: View {
    @StateObject private var viewModel = FeaturedFacesViewModel()
    @State private var uiImage: UIImage?
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var navBarState: NavBarState
    
    @State private var selectedPerson1: Personn?
    @State private var selectedPerson2: Personn?
    @State private var isShowingDetail = false
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        mainContentView
            .background(Color.white.edgesIgnoringSafeArea(.all))
            .navigationDestination(isPresented: $isShowingDetail) {
                if  let person1 = selectedPerson1, let person2 = selectedPerson2 {
                    PersonsView(person1: person1, person2: person2, screenName: "Featured Face")
                }

            }
            .alert(isPresented: $showAlert) {
                        Alert(title: Text("Result"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                    }
            .onAppear {
                navBarState.isHidden = true
                viewModel.loadLinks()
            }
            .onDisappear {
                navBarState.isHidden = false
            }
    }
    
    private var mainContentView: some View {
        VStack(spacing: 20) {
            if viewModel.allLinkedPersons.count > 0 {
                topBar
                imageList
                Spacer()
            }
            else {
                VStack(spacing: 10) {
                    Text("No Features Yet!")
                        .foregroundStyle(Defs.seeGreenColor)
                        .font(.headline)
                    
                    Text("Start linking people to see them here.")
                        .foregroundStyle(Defs.lightPink)
                        .font(.subheadline)
                }
            }
            
        }
    }
    
    private var topBar: some View {
        HStack {
            Spacer()
            ButtonWhite(title: "Feature Less All", action: {
                Task{
                    let success = await viewModel.removeAllLinks()
                    if success {
                        // Refresh the list or show success message
                        viewModel.loadLinks()
                    }
                    alertMessage = success ? "Feature less all successful" : "Feature less all failed"
                    showAlert = true
                }
            })
        }
        .padding(10)
        .background(Defs.seeGreenColor)
        .cornerRadius(20, corners: [.bottomLeft, .bottomRight])
    }
    
    private var imageList: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(viewModel.allLinkedPersons, id: \.id) { item in
                    imageRow(person1: item.person1, person2: item.person2)
                }
            }
            .padding(.top, 10)
        }
    }
    
    private func imageRow(person1: Personn, person2: Personn) -> some View {
        HStack(alignment: .center) {
            
            HStack(alignment: .center){
                PersonCircleImageView(imagePath: person1.path, size: 60)
                if person1.name.lowercased() == "unknown" {
                    
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 15))
                        .foregroundStyle(.blue)
                        .background(Color.white)
                        .clipShape(Circle())
                        .offset(x: -25, y: 20)
                }
                
                Image(systemName: "arrowshape.turn.up.right.fill")
                    .foregroundColor(.darkPurple)
                    .font(.title)
                    .offset(x: -10, y: 0)
                
                PersonCircleImageView(imagePath: person2.path, size: 60)
                if person2.name.lowercased() == "unknown" {
                    
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 15))
                        .foregroundStyle(.blue)
                        .background(Color.white)
                        .clipShape(Circle())
                        .offset(x: -25, y: 20)
                }
            }
            .padding(.leading,5)
            
            Spacer()
            actionButtons(person1: person1, person2: person2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Defs.lightSeeGreenColor)
        .cornerRadius(20)
        .padding(.horizontal)
    }
    
    private func actionButtons(person1: Personn, person2: Personn) -> some View {
        VStack(spacing: 10) {
            ButtonOutline(title: "View") {
                
                selectedPerson1  = person1
                selectedPerson2 = person2
                isShowingDetail = true
                    
            }
            ButtonOutline(title: "Feature Less", action: {
                Task{
                    let success = await viewModel.removeLink(person1Id: person1.id, person2Id: person2.id)
                    if success {
                        //Refresh the list
                        viewModel.loadLinks()
                    }
                    alertMessage = success ? "Feature less successful" : "Feature less failed"
                    showAlert = true
                }
            })
        }
        .padding(.trailing)
    }
}


//#Preview {
//    FeaturedFacesView()
//}
