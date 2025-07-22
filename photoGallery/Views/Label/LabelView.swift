
//MARK: - NOTIFICATIONS

import SwiftUI

struct LabelView: View {
    @StateObject private var viewModel = LabelViewModel()
//    @State private var selectedImageIDs: Set<Int> = []
//    @State private var showBulkEditPopup = false
//    @State private var bulkEditData = BulkEditData()
    @State private var isSelectionModeActive = false
    
    @State private var selectedEvent: Eventt?
    
    @State private var showAddEventDialog = false
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    

    @State private var showShareSheet = false
    
    struct BulkEditData {
        var selectedEvents: [String] = []
        var eventDate: Date = Date()
        var locationName: String = ""
    }
    
    var body: some View {
//        NavigationStack {
        VStack {
            
            ZStack {
                
//                VStack {
//                   
//                    HStack {
//                        
//                        // Top toolbar with selection toggle
//                        HStack {
//                            Button(action: {
//                                isSelectionModeActive.toggle()
//                                if !isSelectionModeActive {
//                                    viewModel.selectedImages.removeAll()
//                                }
//                            }) {
//                                //                        Image(systemName: isSelectionModeActive ? "checkmark.circle.fill" : "checkmark.circle")
//                                Image(systemName: isSelectionModeActive ? "xmark.circle" : "rectangle.and.pencil.and.ellipsis")
//                                    .font(.title2)
//                                    .foregroundColor(Defs.seeGreenColor)
//                            }
//                            .padding(5)
//                            .background(.white)
//                            .cornerRadius(20)
//                            .shadow(radius: 5, x: 5, y: 5)
//                            
//                            Spacer()
//                            
//                            if isSelectionModeActive {
//                                Text("\(viewModel.selectedImages.count) selected")
//                                    .font(.headline)
//                                    .padding(5)
//                                    .background(.white)
//                                    .cornerRadius(15)
//                                    .shadow(radius: 5, x: 5, y: 5)
//                                
//                                Spacer()
//                                
//                                Button("Bulk Edit") {
//                                    viewModel.showBulkEditPopup = true
//                                }
//                                .padding(5)
//                                .background(.white)
//                                .cornerRadius(15)
//                                .shadow(radius: 5, x: 5, y: 5)
//                                
//                                Button("Clear") {
//                                    viewModel.selectedImages.removeAll()
//                                }
//                                .padding(5)
//                                .background(.white)
//                                .cornerRadius(15)
//                                .shadow(radius: 5, x: 5, y: 5)
//                            }
//                        }
//                        .padding([.leading,.trailing])
//                        
//                        Spacer()
//                    }
//                    Spacer()
//                }
                
                SelectionToolbar(
                    isSelectionModeActive: $isSelectionModeActive,
                    selectedItems: $viewModel.selectedImages,
                    mode: .bulkEditAndShare,
                    onShare: {
                        print("Selected Images ------>>>>>>>>",viewModel.selectedImages.count)
                        if viewModel.selectedImages.count > 0 {
                            showShareSheet = true
                        }
                    },
                    onBulkEdit: {
                        if viewModel.selectedImages.count > 0 {
                            viewModel.showBulkEditPopup = true
                            
                        }
                    }
                )
                .zIndex(1)
                
                // Main image grid
                Pictures1View(
                    screenName: "UnEdited",
                    images: viewModel.unEditedImages,
                    isSelectionModeActive: $isSelectionModeActive,
                    selectedImageIDs: $viewModel.selectedImages
                )
                .padding(5)
            }
            
            .sheet(isPresented: $viewModel.showBulkEditPopup) {
                bulkEditPopup
            }
            
            .sheet(isPresented: $showShareSheet) {
                ShareViewHelper(
                    images: ShareHelper.getSelectedGalleryImages(from: viewModel.unEditedImages, selectedIDs: viewModel.selectedImages),
                )
            }
            
            .onReceive(NotificationCenter.default.publisher(for: .refreshLabelView)) { _ in
                viewModel.refreshImages()
                viewModel.selectedImages.removeAll()
                isSelectionModeActive = false
            }
            
            .alert("Alert", isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
            
            .alert("Add New Event", isPresented: $showAddEventDialog) {
                TextField("Event Name", text: $viewModel.inputEvent)
                    .frame(maxWidth: 150, maxHeight: 50)
                    .font(.body)
                    .background(Defs.seeGreenColor)
                    .border(.gray, width: 1)
                    .foregroundColor(Defs.seeGreenColor)
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.white, lineWidth: 1))
                
                Button("Cancel", role: .cancel) {
                    viewModel.inputEvent = ""
                }
                
                Button("Add") {
                    addEvent()
                }
            } message: {
                Text("Enter the name for the new event")
            }
            //        }
        }
    }


    // Bulk Edit Popup (unchanged)
    private var bulkEditPopup: some View {
         return NavigationView {
            Form {
                Section(header: Text("Events")) {
                    VStack {
                        
                        HStack {
                            
                            
                            Picker("Select Event", selection: $selectedEvent) {
                                ForEach(viewModel.allEvents, id: \.self.id) { event in
                                    Text(event.name).tag(event)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .onChange(of: selectedEvent ?? Eventt(id: 0, name: "")) { newEvent in
                                addEvent(newEvent)
                            }
                            
                            Button(action: { showAddEventDialog = true }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                                    .background(Defs.seeGreenColor)
                                    .clipShape(Circle())
                                    .shadow(radius: 4)
                            }
                            .padding()
                        }
                        
                        selectedItemsView(items: viewModel.bulkEditData.events, removeAction: removeEvent)
                        
                    }
                }
                
                Section(header: Text("Event Date")) {
                    DatePicker(
                        "Select Event Date",
                        selection: $viewModel.bulkEditData.eventDate,
                        displayedComponents: .date
                    )
                }
                
                Section(header: Text("Location")) {
                    TextField("Location Name", text: $viewModel.bulkEditData.location.name)
                }
            }
            
            .navigationTitle("Bulk Edit (\(viewModel.selectedImages.count) Images)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.showBulkEditPopup = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        applyBulkEdits()
                        viewModel.showBulkEditPopup = false
                    }
                }
            }
        }
    }
    
    private func applyBulkEdits() {
        
        viewModel.bulkEditSelectedImages()
        viewModel.selectedImages.removeAll()
        
    }
    
    private func addEvent() {
        viewModel.addNewEvent { success in
            if success {
                alertMessage = "Event added successfully!"
            } else {
                alertMessage = viewModel.error?.localizedDescription ?? "Failed to add event"
            }
            showAlert = true
        }
    }
    
    private func selectedItemsView(items: [Eventt], removeAction: @escaping (Eventt) -> Void) -> some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(items, id: \.self) { item in
                    HStack {
                        Text(item.name)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        Button(action: { removeAction(item) }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                    .frame(height: 30)
                    .background(Defs.seeGreenColor)
                    .cornerRadius(25)
                }
            }
        }
    }
    
    private func removeEvent(_ event: Eventt) -> Void {
        viewModel.bulkEditData.events.removeAll { $0.id == event.id }
    }
    
    private func addEvent(_ event: Eventt) {
        guard !viewModel.bulkEditData.events.contains(where: { $0.id == event.id }) else { return }
        viewModel.bulkEditData.events.append(event)
//        selectedxEvent = Eventt(Id: 0, Name: "x") // Reset selection
    }

}



struct Pictures1View: View {
    let screenName: String
    let images: [GalleryImage]
    @Binding var isSelectionModeActive: Bool
    @Binding var selectedImageIDs: Set<Int>
    @State var person: Personn? = nil
    
    var im = ImageHandler(dbHandler: DBHandler())
    
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
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 5)]) {
                ForEach(images) { image in
                    // Wrap ImageCell in NavigationLink when not in selection mode
                    if !isSelectionModeActive {
                        NavigationLink(destination: PictureView(
                            image: im.getImageDetails(imageId: image.id)!,
                            screenName: screenName
                        )) {
                            ImageCell(
                                image: image,
                                isSelected: selectedImageIDs.contains(image.id)
                            )
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        .simultaneousGesture(
                            LongPressGesture(minimumDuration: 0.5)
                                .onEnded { _ in
                                    isSelectionModeActive = true
                                    selectedImageIDs.insert(image.id)
                                }
                        )
                    } else {
                        // Selection mode - no navigation, just selection
                        ImageCell(
                            image: image,
                            isSelected: selectedImageIDs.contains(image.id)
                        )
                        .onTapGesture {
                            if selectedImageIDs.contains(image.id) {
                                selectedImageIDs.remove(image.id)
                            } else {
                                selectedImageIDs.insert(image.id)
                            }
                        }
                        .onLongPressGesture {
                            isSelectionModeActive = true
                            selectedImageIDs.insert(image.id)
                        }
                        .contentShape(Rectangle())
                    }
                }
            }
        }
    }
}


struct ImageCell: View {
    let image: GalleryImage
    let isSelected: Bool
    @State private var uiImage: UIImage?
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Group {
                if let uiImage = uiImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipped()
                } else {
                    ProgressView()
                        .frame(width: 80, height: 80)
                }
            }
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
                    .background(Color.white.clipShape(Circle()))
                    .padding(4)
            }
        }
        .onAppear {
            loadImage()
        }
    }
    
//    private func loadImage() {
//        let fileURL = URL(fileURLWithPath: image.fullPath)
//        DispatchQueue.global(qos: .userInitiated).async {
//            let loadedImage = UIImage(contentsOfFile: fileURL.path)
//            DispatchQueue.main.async {
//                uiImage = loadedImage
//            }
//        }
//    }
    
    private func loadImage() {
        let fileURL = URL(fileURLWithPath: image.fullPath)
        print("Attempting to load image at path: \(fileURL.path)")
        DispatchQueue.global(qos: .userInitiated).async {
            let loaded = UIImage(contentsOfFile: fileURL.path)
            DispatchQueue.main.async {
                if loaded == nil {
                    print("⚠️ Failed to load image at path: \(fileURL.path)")
                }
                self.uiImage = loaded
            }
        }
    }

}


