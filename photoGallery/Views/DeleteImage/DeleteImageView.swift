//
//  DeleteImageView.swift
//  ComponentsApp
//
//  Created by apple on 23/03/2025.
//


import SwiftUI

struct DeleteImageView: View {
    @ObservedObject var viewModel = DeleteImageViewModel()
    @State var image: ImageeDetail
    @State private var showDeleteConfirmation = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(alignment: .leading) {
            // Delete Metadata Button
//            Button(action: {
//                NotificationCenter.default.post(name: .refreshLabelView, object: nil)
//            }, label: {
//                HStack {
//                    Image(systemName: "photo.badge.exclamationmark")
//                        .font(.largeTitle)
//                        .foregroundStyle(.red)
//                    Text("Delete Metadata")
//                        .foregroundStyle(.white)
//                        .font(.title3)
//                }
//            })
//            .padding()
            
            // Delete Image Button - Triggers confirmation dialog
            Button(action: {
                showDeleteConfirmation = true
                NotificationCenter.default.post(name: .refreshLabelView, object: nil)
            }, label: {
                HStack {
                    Image(systemName: "trash.square.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.red)
                    Text("Delete Image")
                        .foregroundStyle(.white)
                        .font(.title3)
                }
            })
            .padding()
            .disabled(viewModel.isDeleting)
            
            // Status indicators
            if viewModel.isDeleting {
                ProgressView()
                    .padding()
                Text("Deleting image...")
            }
            
            if viewModel.deletionSuccess {
                Text("Image deleted successfully!")
                    .foregroundColor(.green)
                    .padding()
            }
            
            if let error = viewModel.error {
                Text("Error: \(error.localizedDescription)")
                    .foregroundColor(.red)
                    .padding()
            }
        }
        // Proper confirmation dialog with actions
        .confirmationDialog(
            Text("Confirm Deletion"),
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                viewModel.deleteImage(imageId: image.id) {
                    if viewModel.deletionSuccess {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            VStack(spacing: 16) {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                        .foregroundColor(.gray)
                }
                
                Text("Are you sure you want to delete this image? This action cannot be undone.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
        }
    }
    
    // Helper function to load image from path
//    private func loadImage(from path: String) -> UIImage? {
//        let url = URL(fileURLWithPath: path)
//        guard FileManager.default.fileExists(atPath: path),
//              let imageData = try? Data(contentsOf: url) else {
//            return nil
//        }
//        return UIImage(data: imageData)
//    }
    
}
