//
//  UndoChanges.swift
//  photoGallery
//
//  Created by apple on 24/04/2025.
//

import SwiftUI

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
                    PictureView(image: image, screenName: "Undo View")
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
            
            if viewModel.undoableImages.count > 0 {
                topBar
                imageList
                Spacer()
            }
            else{
                VStack(spacing: 10) {
                    Text("No Images To Undo Yet!")
                        .foregroundStyle(Defs.seeGreenColor)
                        .font(.headline)
                    
                    Text("Undoable images appear here and can be undo.")
                        .foregroundStyle(Defs.lightPink)
                        .font(.subheadline)
                }
            }
        }
    }
    
    private var topBar: some View {
        HStack {
            Spacer()
            ButtonWhite(title: "Undo All", action: {
                Task{
                    let success = await viewModel.undoAllData()
                    if success {
                        // Refresh the list
                        viewModel.getUndoableImages()
                    }
                    alertMessage = success ? "Undo all data successful" : "Undo all  data failed"
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
                        // Refresh the list
                        viewModel.getUndoableImages()
                    }
                    alertMessage = success ? "Undo successful" : "Undo failed"
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



