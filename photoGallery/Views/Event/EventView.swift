//
//
//import SwiftUI
//
//struct EventView: View {
//    @State private var selectedIndex: Int? = nil
//    @EnvironmentObject var navManager: NavManager  // Access nav state
//    @State private var image = ImgesData.imagesDetail
//
//    private func getSelectedImages() -> [ImageeDetail] {
//        var images: [ImageeDetail] = []
//        if image.indices.contains(5) {
//            images.append(image[5])
//        }
//        if image.indices.contains(6) {
//            images.append(image[6])
//        }
//        return images
//    }
//
//    var body: some View {
//        let selectedImages = getSelectedImages()  // Compute outside the loop to improve performance
//        
//        return NavigationStack {
//            ScrollView {
//                LazyVGrid(columns: [
//                    GridItem(.flexible()),
//                    GridItem(.flexible()),
//                    GridItem(.flexible())
//                ], spacing: 20) {
//                    ForEach(Array(image.enumerated()), id: \.element.id) { index, img in
//                        
//                        NavigationLink(
//                            tag: index,
//                            selection: $selectedIndex
//                        ) {
//                            PicturesView(screenName: img.events.first?.Name ?? "Unknown", images: selectedImages)
//                        } label: {
//                            if img.persons.count>0{
//                                CardSquare(
//                                    title: img.events.first?.Name ?? "Unknown",
//                                    count: "\(index + 1)",
//                                    imageURL: img.path
//                                )
//                                
//                                .padding(.top, -10)
//                                .contentShape(Rectangle())
//                                .onTapGesture {
//                                    print("Card \(index + 1) tapped")
//                                    selectedIndex = index
//                                }
//                            }
//                        }
//                        .buttonStyle(PlainButtonStyle())
//                    }
//                }
//                .padding()
//            }
//        }
//    }
//}



import SwiftUI

struct EventView: View {
    @StateObject private var viewModel = EventModelView()
    @State private var selectedEventKey: String?
    @EnvironmentObject var navManager: NavManager
    
//    init() {
//        _viewModel = StateObject(wrappedValue: EventModelView())
//    }
    
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
        }
    }
    
    private var contentView: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 20) {
//                ForEach(Array(viewModel.groupedImages.keys.sorted() ?? []), id: \.self) { key in
//                    if let firstImagePath = viewModel.firstImagePath(for: key) {
//                        NavigationLink(
//                            tag: key,
//                            selection: $selectedEventKey
//                        ) {
//                            if let images = viewModel.groupedImages[key] {
//                                PicturesView(
//                                    screenName: viewModel.eventName(for: key),
//                                    images: images
//                                )
//                            }
//                        } label: {
//                            CardSquare(
//                                title: key,
//                                count: "\(viewModel.groupedImages[key]?.count ?? 0)",
//                                imageURL: firstImagePath
//                            )
//                            .padding(.top, -10)
//                            .contentShape(Rectangle())
//                            .onTapGesture {
//                                selectedEventKey = key
//                            }
//                        }
//                        .buttonStyle(PlainButtonStyle())
//                    }
//                }
                
                
                ForEach(Array(viewModel.groupedImages.keys.sorted()), id: \.self) { key in
                    // Create a binding to the current key
                    let bindingKey = Binding<String>(
                        get: { key },
                        set: { _ in }
                    )
                    
                    // Use the binding in your view
                    if let firstImagePath = viewModel.firstImagePath(for: bindingKey.wrappedValue) {
                        NavigationLink(
                            tag: bindingKey.wrappedValue,
                            selection: $selectedEventKey
                        ) {
                            if let images = viewModel.groupedImages[bindingKey.wrappedValue] {
                                PicturesView(
                                    screenName: bindingKey.wrappedValue,  // or viewModel.eventName(for: key) if you need formatting
                                    images: images
                                )
                            }
                        } label: {
                            CardSquare(
                                title: bindingKey.wrappedValue,
                                count: "\(viewModel.groupedImages[bindingKey.wrappedValue]?.count ?? 0)",
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
    
    private var errorView: some View {
        VStack {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.red)
            Text("Error loading events")
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
