//
//  PersonImageCardView.swift
//  photoGallery
//
//  Created by apple on 14/05/2025.
//

import SwiftUI

struct PersonImageView: View {
    let imagePath: String
    @State private var faceImage: UIImage?
    
    var body: some View {
        Group {
            if let faceImage = faceImage {
                Image(uiImage: faceImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .padding(.top, -15)
            } else {
                // Placeholder while loading
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 40)
                    .foregroundColor(.gray)
                    .padding(.top, -15)
                    .onAppear {
                        loadFaceImage()
                    }
            }
        }
    }
    
    private func loadFaceImage() {
        ApiHandler.loadFaceImage(from: imagePath) { image in
            DispatchQueue.main.async {
                self.faceImage = image
            }
        }
    }
}
