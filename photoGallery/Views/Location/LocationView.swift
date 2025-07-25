
import SwiftUI

struct LocationView: View {
    @StateObject var viewModel = LocationViewModel()
    @State private var selectedEventKey: String?
    @EnvironmentObject var navManager: NavManager
    
    //
    @State private var isSelectionModeActive = false
    @State private var selectedGalleryImages: [GalleryImage]? = nil
    @State private var showShareSheet = false
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                } else if viewModel.error != nil {
                    errorView
                } else {
                    contentView
                }
            }
//            .navigationTitle("Events")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: viewModel.refresh) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            
            .sheet(isPresented: $showShareSheet) {
                if let images = selectedGalleryImages {
                    ShareViewHelper(
                        images: ShareHelper.getSelectedGalleryImages(from: images, selectedIDs: viewModel.selectedImages),
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
                ForEach(Array(viewModel.groupedImages.keys.sorted() ?? []), id: \.self) { key in
                    if let firstImagePath = viewModel.firstImagePath(for: key) {
                        NavigationLink(
                            tag: key,
                            selection: $selectedEventKey
                        ) {
                            if let images = viewModel.groupedImages[key] {
                                
                                ZStack {
                                    SelectionToolbar(
                                        isSelectionModeActive: $isSelectionModeActive,
                                        selectedItems: $viewModel.selectedImages,
                                        mode: .shareOnly,
                                        onShare: {
                                            print("Selected Images ------>>>>>>>>",viewModel.selectedImages.count)
                                            if viewModel.selectedImages.count > 0 {
                                                selectedGalleryImages = images
                                                showShareSheet = true
                                            }
                                        }
                                    )
                                    .zIndex(1)
                                    Pictures1View(
                                        screenName: key, images: images, isSelectionModeActive: $isSelectionModeActive, selectedImageIDs: $viewModel.selectedImages
                                    )
                                }
                                
//                                PicturesView(
//                                    screenName: key,
//                                    images: images
//                                )
                            }
                        } label: {
                            CardSquare(
                                title: key,
                                count: "\(viewModel.groupedImages[key]?.count ?? 0)",
                                imageURL: firstImagePath
                            )
                            .padding(.top, -10)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedEventKey = key
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding()
        }
    }
    
    private var errorView: some View {
        VStack {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.red)
            Text("Error loading location")
                .font(.title2)
            Text(viewModel.error?.localizedDescription ?? "Unknown error")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding()
            
            Button("Retry") {
                viewModel.loadGroupedImages()
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
    }
}



