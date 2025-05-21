//
//  CardSquare.swift
//  photoGallery
//
//  Created by apple on 22/04/2025.
//

import SwiftUI

struct CardSquare: View {
    var title: String
    var count: String
    var imageURL = "img2"
    @State private var image: UIImage?
    
    var body: some View {

            ZStack(alignment: .leading) {
                Rectangle()
                    //.foregroundStyle(Color(red: 132/255, green: 197/255, blue: 205/255))
                    .foregroundStyle(Defs.lightSeeGreenColor)
                    .cornerRadius(15)
                
                VStack{
                    
                    
                    Group {
                        if let image = image {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .cornerRadius(10)
                            
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.black, lineWidth: 1)
                                )
                                .padding(.top, 10)
                            
                            
                        } else {
                            ProgressView()
                                .frame(width: 90, height: 90)
                        }
                    }
                    .onAppear {
                        loadImage()
                    }
                    
                    
                    VStack(alignment: .leading){
                        Text(title)
                            .font(.subheadline)
                            .foregroundColor(Color.black)
                            //.frame(width: 130, alignment: .leading)
                            //.padding(.top, -8)
                            //.padding(.leading, 25)

                        Text(count)
                            .foregroundColor(.white)
                            .font(.body)
                            //.frame(width: 100, alignment: .leading).padding(.top, -25)
                    }.frame(width:110, alignment: .leading)
                    
                }.frame(width: 120)
                
            }.frame(width: 120, height: 135).padding(.vertical, 7)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.gray, lineWidth: 1)
                )
        
    }
    
    private func loadImage() {
        let fileURL = URL(fileURLWithPath: imageURL)
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            image = UIImage(contentsOfFile: fileURL.path)
        } else {
            print("Image not found at: \(fileURL.path)")
        }
    }
}

//#Preview {
//    CardSquare(title: "demo", count: "3")
//}
