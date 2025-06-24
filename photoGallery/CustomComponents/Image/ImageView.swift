//
//  SwiftUIView.swift
//  ComponentsApp
//
//  Created by apple on 02/11/2024.
//

import SwiftUI



struct ImageView: View {
    let imagePath: String
    @State private var image: UIImage?
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaledToFill()
                    .frame(width: 90, height: 90)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray, lineWidth: 1)
                    )
            } else {
                ProgressView()
                    .frame(width: 90, height: 90)
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
