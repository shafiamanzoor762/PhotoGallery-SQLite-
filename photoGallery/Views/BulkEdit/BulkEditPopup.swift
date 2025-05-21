////
////  BulkEdit.swift
////  photoGallery
////
////  Created by apple on 24/04/2025.
////
//
//import SwiftUI
//
//
//
//
//struct BulkEditView: View {
//    @StateObject private var viewModel = LabelViewModel()
//    @State private var selectedImageIDs: Set<Int> = []
//    @State private var showBulkEditPopup = false
//    @State private var bulkEditData = BulkEditData()
//    @State private var isSelectionModeActive = false
//    
//    struct BulkEditData {
//        var selectedEvents: [String] = []
//        var eventDate: Date = Date()
//        var locationName: String = ""
//    }
//    
//    var body: some View {
////        NavigationStack {
//            VStack {
//                // Top toolbar with selection toggle
//                HStack {
//                    Button(action: {
//                        isSelectionModeActive.toggle()
//                        if !isSelectionModeActive {
//                            selectedImageIDs.removeAll()
//                        }
//                    }) {
//                        Image(systemName: isSelectionModeActive ? "checkmark.circle.fill" : "checkmark.circle")
//                            .font(.title2)
//                    }
//                    
//                    Spacer()
//                    
//                    if isSelectionModeActive {
//                        Text("\(selectedImageIDs.count) selected")
//                            .font(.headline)
//                        
//                        Spacer()
//                        
//                        Button("Bulk Edit") {
//                            showBulkEditPopup = true
//                        }
//                        
//                        Button("Clear") {
//                            selectedImageIDs.removeAll()
//                        }
//                    }
//                }
//                .padding()
//                
//                // Main image grid
//                Pictures1View(
//                    screenName: "UnEdited",
//                    images: viewModel.unEditedImages,
//                    isSelectionModeActive: $isSelectionModeActive,
//                    selectedImageIDs: $selectedImageIDs
//                )
//            }
//            .sheet(isPresented: $showBulkEditPopup) {
//                bulkEditPopup
//            }
//            .onReceive(NotificationCenter.default.publisher(for: .refreshLabelView)) { _ in
//                viewModel.refreshImages()
//                selectedImageIDs.removeAll()
//                isSelectionModeActive = false
//            }
////        }
//    }
//
//    // Bulk Edit Popup (unchanged)
//    private var bulkEditPopup: some View {
//        NavigationView {
//            Form {
//                Section(header: Text("Events")) {
//                    MultiSelectPicker(
//                        items: viewModel.allEvents,
//                        selections: $bulkEditData.selectedEvents
//                    )
//                }
//                
//                Section(header: Text("Event Date")) {
//                    DatePicker(
//                        "Select Date",
//                        selection: $bulkEditData.eventDate,
//                        displayedComponents: .date
//                    )
//                }
//                
//                Section(header: Text("Location")) {
//                    TextField("Location Name", text: $bulkEditData.locationName)
//                }
//            }
//            .navigationTitle("Bulk Edit (\(selectedImageIDs.count) Images)")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .cancellationAction) {
//                    Button("Cancel") {
//                        showBulkEditPopup = false
//                    }
//                }
//                ToolbarItem(placement: .confirmationAction) {
//                    Button("Apply") {
//                        applyBulkEdits()
//                        showBulkEditPopup = false
//                    }
//                }
//            }
//        }
//    }
//    
//    private func applyBulkEdits() {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//        let eventDateString = dateFormatter.string(from: bulkEditData.eventDate)
//        
//        let location = bulkEditData.locationName.isEmpty ? nil :
//            Locationn(Id: 0, Name: bulkEditData.locationName, Lat: 0.0, Lon: 0.0)
//        
//        for imageId in selectedImageIDs {
//            print(imageId)
////            viewModel.editImage(
////                imageId: imageId,
////                persons: nil,
////                eventNames: bulkEditData.selectedEvents.isEmpty ? nil : bulkEditData.selectedEvents,
////                eventDate: eventDateString,
////                location: location
////            ) { result in
////                
////            }
//        }
//        
//        selectedImageIDs.removeAll()
//    }
//}
//
//
//
//struct Pictures1View: View {
//    let screenName: String
//    let images: [GalleryImage]
//    @Binding var isSelectionModeActive: Bool
//    @Binding var selectedImageIDs: Set<Int>
//    
//    var im = ImageHandler(dbHandler: DBHandler())
//    
//    var body: some View {
//        ScrollView {
//            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 5)]) {
//                ForEach(images) { image in
//                    // Wrap ImageCell in NavigationLink when not in selection mode
//                    if !isSelectionModeActive {
//                        NavigationLink(destination: PictureView(
//                            image: im.getImageDetails(imageId: image.id)!,
//                            screenName: screenName
//                        )) {
//                            ImageCell(
//                                image: image,
//                                isSelected: selectedImageIDs.contains(image.id)
//                            )
//                            .contentShape(Rectangle())
//                        }
//                        .buttonStyle(PlainButtonStyle())
//                        .simultaneousGesture(
//                            LongPressGesture(minimumDuration: 0.5)
//                                .onEnded { _ in
//                                    isSelectionModeActive = true
//                                    selectedImageIDs.insert(image.id)
//                                }
//                        )
//                    } else {
//                        // Selection mode - no navigation, just selection
//                        ImageCell(
//                            image: image,
//                            isSelected: selectedImageIDs.contains(image.id)
//                        )
//                        .onTapGesture {
//                            if selectedImageIDs.contains(image.id) {
//                                selectedImageIDs.remove(image.id)
//                            } else {
//                                selectedImageIDs.insert(image.id)
//                            }
//                        }
//                        .onLongPressGesture {
//                            isSelectionModeActive = true
//                            selectedImageIDs.insert(image.id)
//                        }
//                        .contentShape(Rectangle())
//                    }
//                }
//            }
//        }
//    }
//}
//
//
//struct ImageCell: View {
//    let image: GalleryImage
//    let isSelected: Bool
//    @State private var uiImage: UIImage?
//    
//    var body: some View {
//        ZStack(alignment: .topTrailing) {
//            Group {
//                if let uiImage = uiImage {
//                    Image(uiImage: uiImage)
//                        .resizable()
//                        .scaledToFill()
//                        .frame(width: 80, height: 80)
//                        .clipped()
//                } else {
//                    ProgressView()
//                        .frame(width: 80, height: 80)
//                }
//            }
//            .background(Color.gray.opacity(0.2))
//            .cornerRadius(8)
//            .overlay(
//                RoundedRectangle(cornerRadius: 8)
//                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
//            )
//            
//            if isSelected {
//                Image(systemName: "checkmark.circle.fill")
//                    .foregroundColor(.blue)
//                    .background(Color.white.clipShape(Circle()))
//                    .padding(4)
//            }
//        }
//        .onAppear {
//            loadImage()
//        }
//    }
//    
//    private func loadImage() {
//        let fileURL = URL(fileURLWithPath: image.fullPath)
//        DispatchQueue.global(qos: .userInitiated).async {
//            let loadedImage = UIImage(contentsOfFile: fileURL.path)
//            DispatchQueue.main.async {
//                uiImage = loadedImage
//            }
//        }
//    }
//}
//
//
//struct MultiSelectPicker: View {
//    let items: [String]
//    @Binding var selections: [String]
//    
//    var body: some View {
//        List {
//            ForEach(items, id: \.self) { item in
//                Button(action: {
//                    if selections.contains(item) {
//                        selections.removeAll { $0 == item }
//                    } else {
//                        selections.append(item)
//                    }
//                }) {
//                    HStack {
//                        Text(item)
//                        Spacer()
//                        if selections.contains(item) {
//                            Image(systemName: "checkmark")
//                        }
//                    }
//                }
//                .foregroundColor(.primary)
//            }
//        }
//    }
//}
