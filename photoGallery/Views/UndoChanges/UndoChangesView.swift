//
//  UndoChanges.swift
//  photoGallery
//
//  Created by apple on 24/04/2025.
//

import SwiftUI

//struct UndoChangesView: View {
//    
//    @StateObject private var viewModel = UndoChangesViewModel()
//    @State private var uiImage: UIImage?
//    @Environment(\.dismiss) var dismiss
//    @EnvironmentObject var navBarState: NavBarState
//    
//    @State private var selectedImage: ImageeDetailHistory?
//    @State private var isShowingDetail = false
//    
//    var body: some View {
//        VStack(spacing: 20) {
//            // Top Bar
//            HStack {
//                Spacer()
//                ButtonWhite(title: "Undo All", action: {})
//            }
//            .padding(10)
//            .background(Defs.seeGreenColor)
//            .cornerRadius(20, corners: [.bottomLeft, .bottomRight])
//            
//            ScrollView {
//                VStack(spacing: 20) {
//                    // Correct ForEach usage
//                    ForEach(viewModel.undoableImages) { item in
//                        HStack(alignment: .center, spacing: 16) {
//                            
//                            // Display the image path or other identifier
//                            
//                            
//                            
////                            if let uiImage = uiImage {
////                                Image(uiImage: uiImage)
////                                    .resizable()
////                                    .aspectRatio(contentMode: .fill)
////                                    .frame(width: 100, height: 100)
////                                    .clipShape(RoundedRectangle(cornerRadius: 12))
////                                    .overlay(
////                                        RoundedRectangle(cornerRadius: 12)
////                                            .stroke(Color.white, lineWidth: 2)
////                                    )
////                                    .padding(.leading)
////                            } else {
////                                ProgressView()
////                            }
//                            
//                            Image2View(imagePath: item.fullPath)
//                            
//                            Spacer()
//                            
//                            // Buttons
//                            VStack(spacing: 10) {
//                                ButtonOutline(title: "View") {
//                                    if let imageDetail = viewModel.getImageCompleteDetailUndo(imageId: item.id, version: item.version_no) {
//                                        selectedImage = imageDetail
//                                        isShowingDetail = true
//                                    }
//                                }
//                                ButtonOutline(title: "Undo", action: {})
//                            }
//                            .padding(.trailing)
//                        }
//                        .frame(maxWidth: .infinity)
//                        .padding(.vertical, 10)
//                        .background(Defs.lightSeeGreenColor)
//                        .cornerRadius(20)
//                        .padding(.horizontal)
//                    }
//                }
//                .padding(.top, 10)
//            }
//            Spacer()
//        }
//        .background(Color.white.edgesIgnoringSafeArea(.all))
//        .navigationDestination(isPresented: $isShowingDetail) {
//                    if let image = selectedImage {
//                        PictureView(image: image, screenName: "UndoView")
//                    }
//                }
//        .onAppear {
//            navBarState.isHidden = true
//            viewModel.getUndoableImages()
//        }
//        .onDisappear {
//            navBarState.isHidden = false
//        }
//    }
//
//}

struct UndoChangesView: View {
    @StateObject private var viewModel = UndoChangesViewModel()
    @State private var uiImage: UIImage?
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var navBarState: NavBarState
    
    @State private var selectedImage: ImageeDetail?
    @State private var isShowingDetail = false
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        mainContentView
            .background(Color.white.edgesIgnoringSafeArea(.all))
            .navigationDestination(isPresented: $isShowingDetail) {
                if let image = selectedImage {
                    PictureView(image: image, screenName: "UndoView")
                }
            }
            .alert(isPresented: $showAlert) {
                        Alert(title: Text("Result"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                    }
            .onAppear {
                navBarState.isHidden = true
                viewModel.getUndoableImages()
            }
            .onDisappear {
                navBarState.isHidden = false
            }
    }
    
    private var mainContentView: some View {
        VStack(spacing: 20) {
            topBar
            imageList
            Spacer()
        }
    }
    
    private var topBar: some View {
        HStack {
            Spacer()
            ButtonWhite(title: "Undo All", action: {})
        }
        .padding(10)
        .background(Defs.seeGreenColor)
        .cornerRadius(20, corners: [.bottomLeft, .bottomRight])
    }
    
    private var imageList: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(viewModel.undoableImages) { item in
                    imageRow(for: item)
                }
            }
            .padding(.top, 10)
        }
    }
    
    private func imageRow(for item: UndoData) -> some View {
        HStack(alignment: .center, spacing: 16) {
            Image2View(imagePath: item.fullPath)
            Spacer()
            actionButtons(for: item)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Defs.lightSeeGreenColor)
        .cornerRadius(20)
        .padding(.horizontal)
    }
    
    private func actionButtons(for item: UndoData) -> some View {
        VStack(spacing: 10) {
            ButtonOutline(title: "View") {
                
                do {
                        let imageDetail = try viewModel.getImageCompleteDetailUndo(imageId: item.id, version: item.version_no)
                        selectedImage = imageDetail
                        isShowingDetail = true
                    } catch {
                        print("Error loading image details: \(error)")
                    }
            }
            ButtonOutline(title: "Undo", action: {
                Task{
                    let success = await viewModel.undoData(imageId: item.id, version: item.version_no)
                    if success {
                        // Refresh the list or show success message
                        viewModel.getUndoableImages()
                        
                        alertMessage = success ? "Undo successful" : "Undo failed"
                    } else {
                        alertMessage = "Please enter valid numbers"
                        
                    }
                    showAlert = true
                }
            })
        }
        .padding(.trailing)
    }
}


// Corner Radius Extension to only round specific corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCornerr(radius: radius, corners: corners) )
    }
}

struct RoundedCornerr: Shape {
    
    var radius: CGFloat = 0.0
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}



