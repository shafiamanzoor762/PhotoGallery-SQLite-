
import SwiftUI

struct DateView: View {
    @StateObject var viewModel = DateViewModel()
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
            }            .toolbar {
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
