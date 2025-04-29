//
//import SwiftUI
//
//struct DateView: View {
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
//                            PicturesView(screenName:  {
//                                let formatter = DateFormatter()
//                                formatter.dateFormat = "yyyy-MM-dd"
//                                return formatter.string(from: img.event_date)
//                            }()
//                                         , images: selectedImages)
//                        } label: {
//                            if img.persons.count>0{
//                                CardSquare(
//                                    title: {
//                                        let formatter = DateFormatter()
//                                        formatter.dateFormat = "yyyy-MM-dd"
//                                        return formatter.string(from: img.event_date)
//                                    }(),
//                                    content: "\(index + 1)",
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


//import SwiftUI
//
//struct DateView: View {
//    @StateObject private var viewModel = DateModelView()
//    @State private var selectedEventKey: String?
//    @EnvironmentObject var navManager: NavManager
//    
////    init() {
////        _viewModel = StateObject(wrappedValue: EventModelView())
////    }
//    
//    var body: some View {
//        NavigationStack {
//            Group {
//                if viewModel.isLoading {
//                    ProgressView()
//                        .scaleEffect(1.5)
//                } else if viewModel.error != nil {
//                    errorView
//                } else {
//                    contentView
//                }
//            }
////            .navigationTitle("Events")
////            .toolbar {
////                ToolbarItem(placement: .navigationBarTrailing) {
////                    Button(action: viewModel.refresh) {
////                        Image(systemName: "arrow.clockwise")
////                    }
////                }
////            }
//        }
//    }
//    
//    private var contentView: some View {
//        ScrollView {
//            LazyVGrid(columns: [
//                GridItem(.flexible()),
//                GridItem(.flexible()),
//                GridItem(.flexible())
//            ], spacing: 20) {
//                ForEach(Array(viewModel.groupedImages.keys.sorted() ?? []), id: \.self) { key in
//                    if let firstImagePath = viewModel.firstImagePath(for: key) {
//                        NavigationLink(
//                            tag: key,
//                            selection: $selectedEventKey
//                        ) {
//                            if let images = viewModel.groupedImages[key] {
//                                PicturesView(
//                                    screenName: viewModel.formattedEventDate(for: key),
//                                    images: images
//                                )
//                            }
//                        } label: {
//                            CardSquare(
//                                title: viewModel.formattedEventDate(for: key),
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
//            }
//            .padding()
//        }
//    }
//    
//    private var errorView: some View {
//        VStack {
//            Image(systemName: "exclamationmark.triangle")
//                .font(.largeTitle)
//                .foregroundColor(.red)
//            Text("Error loading events")
//                .font(.title2)
//            Text(viewModel.error?.localizedDescription ?? "Unknown error")
//                .font(.subheadline)
//                .multilineTextAlignment(.center)
//                .padding()
//            
//            Button("Retry") {
//                viewModel.loadGroupedImages()
//            }
//            .buttonStyle(.borderedProminent)
//            .padding()
//        }
//    }
//}




import SwiftUI

struct DateView: View {
    @StateObject private var viewModel = DateModelView()
    @State private var selectedEventKey: String?
    @EnvironmentObject var navManager: NavManager
    
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
        }
    }
    
    private var contentView: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 20) {
                ForEach(sortedKeys, id: \.self) { key in
                    dateCard(for: key)
                }
            }
            .padding()
        }
    }
    
    private var sortedKeys: [String] {
        Array(viewModel.groupedImages.keys).sorted()
    }
    
    private func dateCard(for key: String) -> some View {
        Group {
            if let firstImagePath = viewModel.firstImagePath(for: key) {
                NavigationLink(
                    tag: key,
                    selection: $selectedEventKey
                ) {
                    destinationView(for: key)
                } label: {
                    cardContent(for: key, imagePath: firstImagePath)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    private func destinationView(for key: String) -> some View {
        Group {
            if let images = viewModel.groupedImages[key] {
                PicturesView(
                    screenName: key,
                    images: images
                )
            }
        }
    }
    
    private func cardContent(for key: String, imagePath: String) -> some View {
        CardSquare(
            title: key,
            count: "\(viewModel.groupedImages[key]?.count ?? 0)",
            imageURL: imagePath
        )
        .padding(.top, -10)
        .contentShape(Rectangle())
        .onTapGesture {
            selectedEventKey = key
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
