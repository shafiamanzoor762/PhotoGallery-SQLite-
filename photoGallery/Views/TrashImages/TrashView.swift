//
//  TrashView.swift
//  photoGallery
//
//  Created by apple on 03/07/2025.
//



import SwiftUI

struct TrashView: View {
    @StateObject private var viewModel = TrashViewModel()
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
                    PictureView(image: image, screenName: "Trash View")
                }
            }
            .alert(isPresented: $showAlert) {
                        Alert(title: Text("Result"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                    }
            .onAppear {
                navBarState.isHidden = true
                viewModel.getTrashImages()
            }
            .onDisappear {
                navBarState.isHidden = false
            }
    }
    
    private var mainContentView: some View {
        VStack(spacing: 20) {
            
            if viewModel.trashImages.count > 0 {
                topBar
                imageList
                Spacer()
            }
            else{
                VStack(spacing: 10) {
                    Text("No Deleted Images Yet!")
                        .foregroundStyle(Defs.seeGreenColor)
                        .font(.headline)
                    
                    Text("Deleted images appear here and can be restored.")
                        .foregroundStyle(Defs.lightPink)
                        .font(.subheadline)
                }
            }
        }
    }
    
    private var topBar: some View {
        HStack {
            Spacer()
            ButtonWhite(title: "Restore All", action: {
                Task{
                    let success = await viewModel.restoreAllImages()
                    if success {
                        // Refresh the list or show success message
                        viewModel.getTrashImages()
                    }
                    alertMessage = success ? "Restoring all images successful" : "Restoring all images failed"
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
                ForEach(viewModel.trashImages) { item in
                    imageRow(for: item)
                }
            }
            .padding(.top, 10)
        }
    }
    
    private func imageRow(for item: GalleryImage) -> some View {
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
    
    private func actionButtons(for item: GalleryImage) -> some View {
        VStack(spacing: 10) {
            ButtonOutline(title: "View") {
                
                do {
                    let imageDetail = try viewModel.getImageCompleteDetailTrash(imageId: item.id)
                        selectedImage = imageDetail
                        isShowingDetail = true
                    } catch {
                        print("Error loading image details: \(error)")
                    }
            }
            ButtonOutline(title: "Restore", action: {
                Task{
                    let success = await viewModel.restoreImage(imageId: item.id)
                    if success {
                        //Refresh the list
                        viewModel.getTrashImages()
                    }
                    alertMessage = success ? "Restore image successful" : "Restore image failed"
                    showAlert = true
                }
            })
        }
        .padding(.trailing)
    }
}


//#Preview {
//    TrashView()
//}
