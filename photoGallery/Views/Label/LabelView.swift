
//MARK: - NOTIFICATIONS

extension Notification.Name {
    static let refreshLabelView = Notification.Name("RefreshLabelView")
}

import SwiftUI

struct LabelView: View {
    let columns = [
        GridItem(.adaptive(minimum: 80), spacing: 5)
//                    GridItem(.flexible()),
//                    GridItem(.flexible()),
//                    GridItem(.flexible()),
//                    GridItem(.flexible())
    ]
    
    @StateObject private var viewModel = LabelViewModel()
    @State private var unLabeledImages: [GalleryImage] = []
    
    var body: some View {

        
        PicturesView(screenName: "UnEdited", images: viewModel.unEditedImages)
        
        .onReceive(NotificationCenter.default.publisher(for: .refreshLabelView)) { _ in
            viewModel.refreshImages()
        }
    }
}







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
