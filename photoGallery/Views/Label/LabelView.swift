
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
    
    
    struct BulkEditData {
        var selectedEvents: [String] = []
        var eventDate: Date = Date()
        var locationName: String = ""
    }
    
    var body: some View {
//        NavigationStack {
        VStack {
            
            ZStack {
                
                VStack {
                   
                    HStack {
                        
                        // Top toolbar with selection toggle
                        HStack {
                            Button(action: {
                                isSelectionModeActive.toggle()
                                if !isSelectionModeActive {
                                    viewModel.selectedImages.removeAll()
                                }
                            }) {
                                //                        Image(systemName: isSelectionModeActive ? "checkmark.circle.fill" : "checkmark.circle")
                                Image(systemName: isSelectionModeActive ? "xmark.circle" : "rectangle.and.pencil.and.ellipsis")
                                    .font(.title2)
                                    .foregroundColor(Defs.seeGreenColor)
                            }
                            .padding(5)
                            .background(.white)
                            .cornerRadius(20)
                            .shadow(radius: 5, x: 5, y: 5)
                            
                            Spacer()
                            
                            if isSelectionModeActive {
                                Text("\(viewModel.selectedImages.count) selected")
                                    .font(.headline)
                                    .padding(5)
                                    .background(.white)
                                    .cornerRadius(15)
                                    .shadow(radius: 5, x: 5, y: 5)
                                
                                Spacer()
                                
                                Button("Bulk Edit") {
                                    viewModel.showBulkEditPopup = true
                                }
                                .padding(5)
                                .background(.white)
                                .cornerRadius(15)
                                .shadow(radius: 5, x: 5, y: 5)
                                
                                Button("Clear") {
                                    viewModel.selectedImages.removeAll()
                                }
                                .padding(5)
                                .background(.white)
                                .cornerRadius(15)
                                .shadow(radius: 5, x: 5, y: 5)
                            }
                        }
                        .padding([.leading,.trailing])
                        
                        Spacer()
                    }
                    Spacer()
                }
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
    
    var im = ImageHandler(dbHandler: DBHandler())
    
    var body: some View {
        ScrollView {
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
    
    private func loadImage() {
        let fileURL = URL(fileURLWithPath: image.fullPath)
        DispatchQueue.global(qos: .userInitiated).async {
            let loadedImage = UIImage(contentsOfFile: fileURL.path)
            DispatchQueue.main.async {
                uiImage = loadedImage
            }
        }
    }
}


struct MultiSelectPicker: View {
    let items: [String]
    @Binding var selections: [String]
    
    var body: some View {
        List {
            ForEach(items, id: \.self) { item in
                Button(action: {
                    if selections.contains(item) {
                        selections.removeAll { $0 == item }
                    } else {
                        selections.append(item)
                    }
                }) {
                    HStack {
                        Text(item)
                        Spacer()
                        if selections.contains(item) {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                .foregroundColor(.primary)
            }
        }
    }
}



//===============================


//
//import PhotosUI
//
//struct HomeScreenView: View {
//    @State private var selectedImage: UIImage? = nil
//    @State private var imageUrl: URL? = nil
//    @State private var imageTags: [String: String] = [:]
//    
//    @State private var name: String = ""
//    @State private var event: String = ""
//    @State private var location: String = ""
//    
//    @State private var showImagePicker = false
//    @State private var showAlert = false
//    @State private var alertMessage = ""
//    
//    var body: some View {
//        VStack {
//            if let image = selectedImage {
//                Image(uiImage: image)
//                    .resizable()
//                    .scaledToFit()
//                    .frame(height: 250)
//            } else {
//                Rectangle()
//                    .fill(Color.gray.opacity(0.5))
//                    .frame(height: 250)
//                    .overlay(Text("Select Image").foregroundColor(.white))
//            }
//            
//            // Buttons to pick image or send to server
//            HStack {
//                Button("Select Image") {
//                    showImagePicker = true
//                }
//                .padding()
//                
//                Button("Tag Image") {
//                    if let imageUrl = imageUrl {
//                        sendImageWithTags(imageUrl: imageUrl)
//                    }
//                }
//                .padding()
//                .disabled(selectedImage == nil)
//            }
//            
//            // Metadata form
//            Form {
//                Section(header: Text("Tags")) {
//                    TextField("Name", text: $name)
//                    TextField("Event", text: $event)
//                    TextField("Location", text: $location)
//                }
//            }
//            
//            // Display extracted tags
//            if !imageTags.isEmpty {
//                VStack(alignment: .leading) {
//                    Text("Extracted Tags:")
//                    Text("Name: \(imageTags["name"] ?? "")")
//                    Text("Event: \(imageTags["event"] ?? "")")
//                    Text("Location: \(imageTags["location"] ?? "")")
//                }
//                .padding()
//            }
//        }
//        .sheet(isPresented: $showImagePicker) {
//            ImagePicker(image: $selectedImage, imageUrl: $imageUrl)
//        }
//        .alert(isPresented: $showAlert) {
//            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
//        }
//    }
//    
//    func sendImageWithTags(imageUrl: URL) {
//        let url = URL(string: "http://192.168.64.2:5000/tagimage")!
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        
//        let boundary = UUID().uuidString
//        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
////
//        print(imageUrl.absoluteString,name,event,location)
//        
//        var body = Data()
//        
//        // Append image data
//        if let imageData = try? Data(contentsOf: imageUrl) {
//            body.append("--\(boundary)\r\n".data(using: .utf8)!)
//            body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(imageUrl.lastPathComponent)\"\r\n".data(using: .utf8)!)
//            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
//            body.append(imageData)
//            body.append("\r\n".data(using: .utf8)!)
//        }
//        
//        // Append metadata (tags)
//        let jsonTags = ["name": name, "event": event, "location": location]
//        let jsonData = try? JSONSerialization.data(withJSONObject: jsonTags, options: [])
//        body.append("--\(boundary)\r\n".data(using: .utf8)!)
//        body.append("Content-Disposition: form-data; name=\"tags\"\r\n".data(using: .utf8)!)
//        body.append("Content-Type: application/json\r\n\r\n".data(using: .utf8)!)
//        body.append(jsonData!)
//        body.append("\r\n".data(using: .utf8)!)
//        
//        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
//        
//        // Send the request
//        let task = URLSession.shared.uploadTask(with: request, from: body) { data, response, error in
//            if let error = error {
//                DispatchQueue.main.async {
//                    alertMessage = "Error: \(error.localizedDescription)"
//                    showAlert = true
//                }
//                return
//            }
//            
//            guard let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 else {
//                DispatchQueue.main.async {
//                    alertMessage = "Server error or no response"
//                    showAlert = true
//                }
//                return
//            }
//            
//            DispatchQueue.main.async {
//                // Handle the received image (if any) or extract the metadata
//                if let receivedImage = UIImage(data: data) {
//                    self.selectedImage = receivedImage
//                    self.alertMessage = "Image received and updated successfully."
//                    self.showAlert = true
//                }
//            }
//        }
//        task.resume()
//    }
//}
//
////struct ContentView_Previews: PreviewProvider {
////    static var previews: some View {
////        ContentView()
////    }
////}
//
//
//struct ImagePicker: UIViewControllerRepresentable {
//    @Binding var image: UIImage?
//    @Binding var imageUrl: URL?
//    
//    func makeUIViewController(context: Context) -> PHPickerViewController {
//        var config = PHPickerConfiguration()
//        config.filter = .images
//        let picker = PHPickerViewController(configuration: config)
//        picker.delegate = context.coordinator
//        return picker
//    }
//    
//    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
//    
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//    
//    class Coordinator: NSObject, PHPickerViewControllerDelegate {
//        var parent: ImagePicker
//        
//        init(_ parent: ImagePicker) {
//            self.parent = parent
//        }
//        
//        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
//            picker.dismiss(animated: true)
//            
//            guard let provider = results.first?.itemProvider else { return }
//            
//            if provider.canLoadObject(ofClass: UIImage.self) {
//                provider.loadObject(ofClass: UIImage.self) { image, _ in
//                    self.parent.image = image as? UIImage
//                }
//            }
//            
//            provider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { url, _ in
//                if let url = url {
//                    self.parent.imageUrl = url
//                }
//            }
//        }
//    }
//}
//
