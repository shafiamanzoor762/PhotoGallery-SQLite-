//
//  Image2View.swift
//  photoGallery
//
//  Created by apple on 21/06/2025.
//

import SwiftUI



struct Image2View: View {
    let imagePath: String
    @State private var image: UIImage?
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white, lineWidth: 2)
                    )
                    .padding(.leading)
            } else {
                ProgressView()
                    .frame(width: 100, height: 100)
            }
        }
        .onAppear {
            loadImage()
        }
    }
    private func loadImage() {
        let fileURL = URL(fileURLWithPath: imagePath)
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            image = UIImage(contentsOfFile: fileURL.path)
        } else {
            print("Image not found at: \(fileURL.path)")
        }
    }
}

