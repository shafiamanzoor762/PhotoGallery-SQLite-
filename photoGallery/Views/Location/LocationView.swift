
import SwiftUI

struct LocationView: View {
    @StateObject var viewModel = LocationViewModel()
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
                ForEach(Array(viewModel.groupedImages.keys.sorted() ?? []), id: \.self) { key in
                    if let firstImagePath = viewModel.firstImagePath(for: key) {
                        NavigationLink(
                            tag: key,
                            selection: $selectedEventKey
                        ) {
                            if let images = viewModel.groupedImages[key] {
                                PicturesView(
                                    screenName: key,
                                    images: images
                                )
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



