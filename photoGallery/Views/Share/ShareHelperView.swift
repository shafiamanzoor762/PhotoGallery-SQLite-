//
//  ShareViewHelper.swift
//  photoGallery
//
//  Created by apple on 07/07/2025.
//

import SwiftUI

struct ShareViewHelper: View {
    var images: [GalleryImage]
    @State var shareWithMetadata: Bool = false
    
    @State private var showSharePopup = false

    @State private var shareItems: [Any] = []
    @State private var isDataReady = false

    @State private var imageHandler = ImageHandler(dbHandler: DBHandler())

    var body: some View {
        VStack {
            Group {
                if showSharePopup {
                    shareOptionPopup
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            
            if isDataReady {
                ShareSheet(activityItems: shareItems)
            } else {
                ProgressView()
            }
        }
        
        .onAppear {
            showSharePopup = true
        }
        .onChange(of: showSharePopup) { newValue in
            if !newValue {
                Task {
                    shareItems = prepareShareItems()
                    isDataReady = true
                }
            }
        }

    }
    
    private var shareOptionPopup: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    withAnimation {
                        showSharePopup = false
                    }
                }
            VStack {
                Button(action: {
                    shareWithMetadata = false
                    showSharePopup = false
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up.fill")
                            .font(.largeTitle)
                            .foregroundStyle(.darkPurple)
                        Text("Share Image Only")
                            .foregroundStyle(.white)
                            .font(.title3)
                    }
                }
                
                Button(action: {
                    shareWithMetadata = true
                    showSharePopup = false
                }) {
                    HStack {
                        Image(systemName: "richtext.page.fill")
                            .font(.largeTitle)
                            .foregroundStyle(.darkPurple)
                        Text("Share Image with Metadata")
                            .foregroundStyle(.white)
                            .font(.title3)
                    }
                }
                .padding()
            }
            .frame(width: 380, height: 350)
            .background(.lightPink)
            .cornerRadius(20)
            .shadow(radius: 10)
            .padding()
            Spacer()
        }
        
        
    }
    

    private func prepareShareItems() -> [Any] {
        var items: [Any] = []
        print("STARTED----->>>>")

        for image in images {
            let fileURL = URL(fileURLWithPath: image.fullPath)
            if let uiImage = UIImage(contentsOfFile: fileURL.path),
               let detail = imageHandler.getImageDetails(imageId: image.id) {
                
                items.append(uiImage)
                
                if shareWithMetadata {
                    let metadata = ShareHelper.generateMetadata(from: detail)
                    items.append(metadata)
                }
            }
        }

        print("DONE---->>>>>")
        return items
    }
}



//#Preview {
//    ShareViewHelper()
//}
