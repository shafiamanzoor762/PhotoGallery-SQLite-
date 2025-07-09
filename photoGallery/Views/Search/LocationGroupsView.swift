//
//  LocationGroupsView.swift
//  photoGallery
//
//  Created by apple on 09/07/2025.
//

import SwiftUI
import Combine

struct LocationGroupsView: View {
    
    @State var groupedImages: [String: [GalleryImage]]
    
    @State var selectedImages: Set<Int> = []

    
    var cancellables = Set<AnyCancellable>()
    
    @State var selectedEventKey: String?
    @EnvironmentObject var navManager: NavManager
    
    //
    @State var isSelectionModeActive = false
    @State var selectedGalleryImages: [GalleryImage]? = nil
    @State var showShareSheet = false
    
    var body: some View {
        NavigationStack {
            Group {
                if groupedImages.count > 0 {
                    contentView
                } else {
                    Text("No images to display")
                }
            }
            
            .sheet(isPresented: $showShareSheet) {
                if let images = selectedGalleryImages {
                    ShareViewHelper(
                        images: ShareHelper.getSelectedGalleryImages(from: images, selectedIDs: selectedImages),
                    )
                }
            }
            
        }
    }
    
    private var contentView: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 20) {
                
                
                ForEach(Array(groupedImages.keys.sorted()), id: \.self) { key in
                    // Create a binding to the current key
                    let bindingKey = Binding<String>(
                        get: { key },
                        set: { _ in }
                    )
                    
                    // Use the binding in your view
                    if let firstImagePath = firstImagePath(for: bindingKey.wrappedValue) {
                        NavigationLink(
                            tag: bindingKey.wrappedValue,
                            selection: $selectedEventKey
                        ) {
                            if let images = groupedImages[bindingKey.wrappedValue] {
                                ZStack {
                                    SelectionToolbar(
                                        isSelectionModeActive: $isSelectionModeActive,
                                        selectedItems: $selectedImages,
                                        mode: .shareOnly,
                                        onShare: {
                                            print("Selected Images ------>>>>>>>>",selectedImages.count)
                                            if selectedImages.count > 0 {
                                                selectedGalleryImages = images
                                                showShareSheet = true
                                            }
                                        }
                                    )
                                    .zIndex(1)
                                    Pictures1View(
                                        screenName: key, images: images, isSelectionModeActive: $isSelectionModeActive, selectedImageIDs: $selectedImages
                                    )
                                }
                            }
                        } label: {
                            CardSquare(
                                title: bindingKey.wrappedValue,
                                count: "\(groupedImages[bindingKey.wrappedValue]?.count ?? 0)",
                                imageURL: firstImagePath
                            )
                            .padding(.top, -10)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedEventKey = bindingKey.wrappedValue
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding()
        }
    }
    
    
    func firstImagePath(for key: String) -> String? {
        return groupedImages[key]?.first?.fullPath
    }
}
//#Preview {
//    LocationGroupsView()
//}
