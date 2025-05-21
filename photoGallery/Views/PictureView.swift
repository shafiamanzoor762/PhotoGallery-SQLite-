//
//  ImageView.swift
//  ComponentsApp
//
//  Created by apple on 14/03/2025.
//

import SwiftUI

struct PictureView: View {
    @State var image: ImageeDetail
    @State var screenName: String
    @State private var showEdit = false
    @State private var showDelete = false
    @State private var showDetails = false
    @State private var showInfo = false
    
    @State private var uiImage: UIImage?
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var navBarState: NavBarState
    
    @StateObject var viewModel = PersonViewModel()
    
//    var tabItems: [TabItemDescription] = [
//        .init(imageName: "photo", title: "PICTURE VIEW"),
//        .init(imageName: "pencil", title: "EDIT"),
//        .init(imageName: "list.bullet", title: "DETAILS"),
//        .init(imageName: "trash", title: "DELETE"),
//        .init(imageName: "info.circle", title: "INFO")
//    ]
    
    var body: some View {
        VStack {
 
            // Top Bar
            HStack {
                
                Spacer()
                
                Menu {
                    Button(action: {
                        showEdit = true
                    }) {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                    Button(action: {
                        showDetails = true
                    }) {
                        Label("Details", systemImage: "list.bullet")
                    }
                    
                    Button(action: {
                        showDelete = true
                    }) {
                        Label("Delete", systemImage: "trash")
                    }
                    Button(action: {
                        showInfo = true
                    }) {
                        Label("Info", systemImage: "info.circle")
                    }
                    
                }
                label: {
                    Image(systemName: "ellipsis")
                        .font(.title)
                        .foregroundColor(.white)
                }
            }
            .padding([.trailing, .bottom])
            .background(Defs.seeGreenColor)
            
            
            Spacer()
            
            if let uiImage = uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
//                    .padding()
            } else {
                ProgressView()
            }
            
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(image.persons, id: \.id) { p in
                        PersonImageCardView(imagePath: p.path)
                        
                            .onTapGesture {
                                if viewModel.selectedPersonId == p.id && viewModel.showTooltip {
                                    viewModel.showTooltip = false
                                    viewModel.selectedPersonId = nil
                                } else {
                                    viewModel.selectedPersonId = p.id
                                    viewModel.loadLinkedPersons(personId: p.id)
                                    viewModel.showTooltip = true
                                }
                            }

                    }
                }
            }
            
            
            if viewModel.showTooltip {

                
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 10) {
                        Text("Training Images of")
                            .font(.headline)
                            .padding([.top, .leading])
                        
                        if let firstPerson = viewModel.selectedPersons.first {
                            PersonImageCardView(imagePath: firstPerson.path)
                                .id(firstPerson.id)
                                .padding([.top])
                        }
                    }

                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 25) {
                            ForEach(viewModel.selectedPersons.dropFirst(), id: \.id) { person in
                                PersonImageView(imagePath: person.path)
                            }
                        }
                        .padding()
                    }
                    .frame(maxHeight: viewModel.selectedPersons.count > 6 ? 150 : .infinity)
                }

                .background(
                    Color(.systemGray6)
                        .opacity(0.95)
                )
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
                .padding()
                .transition(.opacity)
                .animation(.easeInOut, value: viewModel.showTooltip)
            }



            
            Spacer()
            
        }.onAppear {
            loadImage()
        }
        .onAppear {
            navBarState.isHidden = true
            print("hide")
        }
        .onDisappear {
            navBarState.isHidden = false
            print("unhide")
        }
        .navigationTitle(screenName)
        
        .sheet(isPresented: $showEdit) {  // Sheet to show Edit
                    EditImageView(image: image)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Defs.seeGreenColor)
                        .presentationDetents([.medium, .large])  // Custom sizes for the popup
                        .presentationDragIndicator(.visible) // Show a drag indicator for the popup
                }
        
        .sheet(isPresented: $showDetails) {  // Sheet to show details
                    DetailsImageView(image: image)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Defs.seeGreenColor)
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.visible)
                }
        
        .sheet(isPresented: $showDelete) {  // Sheet to show delete options
                    DeleteImageView(image: image)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Defs.seeGreenColor)
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.visible)
                }
        
        .sheet(isPresented: $showInfo) {  // Sheet to show info
                    InfoImageView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Defs.seeGreenColor)
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.visible)
        }
        
    }
    private func loadImage() {
        let fileURL = URL(fileURLWithPath: image.fullPath)
        uiImage = UIImage(contentsOfFile: fileURL.path)
    }
}



struct PersonImageCardView: View {
    let imagePath: String
    @State private var faceImage: UIImage?
    
    var body: some View {
        Group {
            if let faceImage = faceImage {
                
                Image(uiImage: faceImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25)
                    .cornerRadius(25)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.black, lineWidth: 1)
                    )
//                    .onTapGesture {
//                    
//                }
                
            } else {
                // Placeholder while loading
                Image(systemName: "person.crop.circle.fill")
                
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25)
                    .cornerRadius(25)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.black, lineWidth: 1)
                    )
                    .onAppear {
                        loadFaceImage()
                    }
            }
        }
    }
    
    private func loadFaceImage() {
        ApiHandler.loadFaceImage(from: imagePath) { image in
            print(imagePath)
            DispatchQueue.main.async {
                self.faceImage = image
            }
        }
    }
}



#Preview {
   //PictureView(image: ImageeDetail())
}
