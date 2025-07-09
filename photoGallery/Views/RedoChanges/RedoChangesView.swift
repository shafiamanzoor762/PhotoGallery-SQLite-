//
//  RedoChangesView.swift
//  photoGallery
//
//  Created by apple on 04/07/2025.
//

import SwiftUI

struct RedoChangesView: View {
    @StateObject private var viewModel = RedoChangesViewModel()
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
                    PictureView(image: image, screenName: "Redo View")
                }
            }
        
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Result"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        
            .onAppear {
                navBarState.isHidden = true
                viewModel.getRedoableImages()
            }
        
            .onDisappear {
                navBarState.isHidden = false
            }
    }
    
    private var mainContentView: some View {
        
        VStack(spacing: 20) {
            
            if viewModel.redoableImages.count > 0 {
                topBar
                imageList
                Spacer()
            }
            else{
                VStack(spacing: 10) {
                    Text("No Images To Redo Yet!")
                        .foregroundStyle(Defs.seeGreenColor)
                        .font(.headline)
                    
                    Text("Redoable images appear here and can be redo.")
                        .foregroundStyle(Defs.lightPink)
                        .font(.subheadline)
                }
            }
        }
    }
    
    private var topBar: some View {
        HStack {
            Spacer()
            ButtonWhite(title: "Redo All", action: {
                Task{
                    let success = await viewModel.redoAllData()
                    if success {
                        // Refresh the list or show success message
                        viewModel.getRedoableImages()
                    }
                    alertMessage = success ? "Redo all successful" : "Redo all failed"
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
                ForEach(viewModel.redoableImages) { item in
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
            ButtonOutline(title: "Redo", action: {
                Task{
                    let success = await viewModel.redoData(imageId: item.id, version: item.version_no)
                    if success {
                        //Refresh the list
                        viewModel.getRedoableImages()
                    }
                    alertMessage = success ? "Redo successful" : "Redo failed"
                    showAlert = true
                }
            })
        }
        .padding(.trailing)
    }
}

//#Preview {
//    RedoChangesView()
//}
