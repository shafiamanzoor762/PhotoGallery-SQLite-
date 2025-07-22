//
//  PicturesView.swift
//  ComponentsApp
//
//  Created by apple on 06/03/2025.
//

import SwiftUI

struct PicturesView: View {
    
    @State var screenName: String = "Alina"
    @State var person: Personn? = nil
    
    let columns = [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
    
    @State var images: [GalleryImage]
    
    var im = ImageHandler(dbHandler: DBHandler())
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var navBarState: NavBarState
    
    var body: some View {
            ScrollView {
                
                if (person != nil) {
                    VStack(alignment:.center) {
                        PersonCircleImageView(imagePath: person!.path, size: 60)
                        if person?.name.lowercased() == "unknown" {
                            
                            Image(systemName: "questionmark.circle.fill")
                                .font(.system(size: 15))
                                .foregroundStyle(.blue)
                                .background(Color.white)
                                .clipShape(Circle())
                                .offset(x: 20, y: -12)
                        }
                        Text(person!.name).bold().foregroundStyle(.darkPurple)
                    }
                }
                
                VStack(alignment: .leading, spacing: 20) {
                    
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(images) { img in
                            
                            NavigationLink(destination: PictureView(image: im.getImageDetails(imageId: img.id)!, screenName: screenName)) {
                                ImageView(imagePath: img.fullPath)
                            }
                        }
                    }.frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                }
            }
            .onAppear {
                //navBarState.isHidden = true
                //dismiss()
            }
            .onDisappear {
                //navBarState.isHidden = false
            }
//            .navigationTitle(screenName)
    }

}

#Preview {
//    PicturesView()

}
