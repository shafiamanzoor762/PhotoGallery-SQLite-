//
//  Cover.swift
//  ComponentsApp
//
//  Created by apple on 02/11/2024.
//

import SwiftUI
import AVFoundation

//enum AppRoute: Hashable {
//    case search
//    case sync
//    case bulkEdit
//    case undoChanges
//}

struct Cover: View {
    let images: [String] = ["BabyGirl", "BabyGirl", "BabyGirl", "BabyGirl"]
    @State var viewName: String = "Label"
    @State var isNavigate: Bool = false
    @State private var path: [String] = []
    
    var emojiForView: String {
            switch viewName {
            case "Label": return "🏷️"
            case "Table of Contents": return "☰"
            //case "People": return "👤"
            case "Location": return "📍"
            case "Event": return "🎉"
            case "Date": return "📅"
            default: return "🏷️"
            }
        }
    
    @State private var isShowingCamera = false
    @State private var capturedImage: UIImage?
    @State private var isImagePickerPresented: Bool = false
    @State private var inputImage: UIImage? = nil
    
    @State private var showImageConfirmation = false
    @State private var showAddSuccessAlert = false
    @State private var showAddErrorAlert = false
    @State private var addError: Error?
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var navBarState: NavBarState
    @EnvironmentObject var dbHandler: DBHandler
    
    var body: some View {
        NavigationStack(path: $path) {
            mainContentView
                .background(Defs.seeGreenColor.ignoresSafeArea())
                .navigationDestination(for: String.self) { value in
                    Cover2(tabViewName: value)
                }
                .sheet(isPresented: $isImagePickerPresented) {
                    CustomImagePicker(contactImage: $inputImage)
                        .onChange(of: inputImage) { newImage in
                            if newImage != nil {
                                showImageConfirmation = true
                            }
                        }
                }
                .confirmationDialog("Add Image", isPresented: $showImageConfirmation) {
                    Button("Add Image") {
                        addSelectedImage()
                    }
                    Button("Cancel", role: .cancel) {
                        inputImage = nil
                    }
                }
                .alert("Image Added", isPresented: $showAddSuccessAlert) {
                    Button("OK", role: .cancel) {
                        inputImage = nil
                    }
                } message: {
                    Text("Image was added successfully!")
                }
                .alert("Error", isPresented: $showAddErrorAlert) {
                    Button("OK", role: .cancel) {
                        inputImage = nil
                    }
                } message: {
                    Text(addError?.localizedDescription ?? "Unknown error occurred")
                }
        }
        .navigationBarBackButtonHidden(false)
        .tint(.black)
    }
    
    // MARK: - Subviews
    
    private var mainContentView: some View {
        VStack {
            topBar
            contentArea
        }
    }
    
    private var topBar: some View {
        HStack {
            Text(emojiForView+" "+viewName)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.bottom, 5)
            
            Spacer()
            
            Menu {
                menuButtons
            } label: {
                Image(systemName: "ellipsis")
                    .font(.title)
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(Defs.seeGreenColor)
    }
    
    private var menuButtons: some View {
        Group {
            Button(action: searchAction) {
                Label("Search", systemImage: "magnifyingglass")
            }
            
            Button(action: syncAction) {
                Label("Sync", systemImage: "arrow.trianglehead.2.clockwise.rotate.90")
            }
            
            Button(action: undoChangesAction) {
                Label("Undo Changes", systemImage: "arrow.uturn.backward")
            }
            
            Button(action: redoChangesAction) {
                Label("Redo Changes", systemImage: "arrow.uturn.forward")
            }
            
            Button(action: featuredFacesAction) {
                Label("Featured Faces", systemImage: "person.fill.badge.minus")
            }
            
            Button(action: trashAction) {
                Label("Trash Images", systemImage: "trash.fill")
            }
            
//            Button(action: PeopleBirthdayTaskViewAction) {
//                Label("PeopleBirthdayTaskView", systemImage: "line.3.horizontal.decrease.circle.fill")
//            }
        }
    }
    
    private var contentArea: some View {
        ZStack {
            Color.white
                .clipShape(RoundedCorner(radius: 30, corners: [.topLeft, .topRight]))
            
                currentView
//                Spacer()
//                capturedImageView
            //Add Image
                //floatingButtons

        }
        .ignoresSafeArea(edges: .bottom)
    }
    
    private var currentView: some View {
        switch viewName {
        case "Label":
            return AnyView(LabelView())
//        case "People":
        case "Table of Contents":
//            return AnyView(PersonView())
              return AnyView(PeopleBirthdayTaskView())
        case "Location":
            return AnyView(LocationView())
        case "Event":
            return AnyView(EventView())
        case "Date":
            return AnyView(DateView())
        default:
            return AnyView(EmptyView())
        }
    }
    
    private var capturedImageView: some View {
        Group {
            if let image = capturedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .cornerRadius(10)
                    .padding()
            }
        }
    }

    private var floatingButtons: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                VStack(spacing: 16) {
                    addImageButton
                    cameraButton
                }
                .padding(.trailing, 16)
                .padding(.bottom, 120) // Reduced from 120 to make it float higher
            }
        }
    }
    
        private var addImageButton: some View {
            Button(action: { isImagePickerPresented = true }) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .background(Defs.seeGreenColor)
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
            .padding(.trailing)
        }
    
        private var cameraButton: some View {
            Button(action: { isShowingCamera = true }) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Defs.seeGreenColor)
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
            .padding(.trailing)
            .fullScreenCover(isPresented: $isShowingCamera) {
                CameraView(isPresented: $isShowingCamera, capturedImage: $capturedImage)
            }
        }
    
    // MARK: - Actions
    
    private func searchAction() {
        path.append("Search")
        navBarState.isHidden = true
        dismiss()
    }
    
    private func syncAction() {
        path.append("Sync")
        navBarState.isHidden = true
        dismiss()
    }
    
//    private func bulkEditAction() {
//        path.append("Bulk Edit")
//        navBarState.isHidden = true
//        dismiss()
//    }
    
    private func undoChangesAction() {
        path.append("Undo Changes")
        navBarState.isHidden = true
        dismiss()
    }
    
    private func redoChangesAction() {
        path.append("Redo Changes")
        navBarState.isHidden = true
        dismiss()
    }
    
    private func featuredFacesAction() {
        path.append("Featured Faces")
        navBarState.isHidden = true
        dismiss()
    }
    
    private func trashAction() {
        path.append("Trash Images")
        navBarState.isHidden = true
        dismiss()
    }
    
//    private func PeopleBirthdayTaskViewAction() {
//        path.append("People Birthday Task View")
//        navBarState.isHidden = true
//        dismiss()
//    }
    
    
    // MARK: - Image Handling
    
    private func addSelectedImage() {
        guard let image = inputImage,
              let imageData = image.jpegData(compressionQuality: 0.8) else {
            addError = NSError(domain: "ImageError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid image data"])
            showAddErrorAlert = true
            return
        }
        
        let filename = "\(UUID().uuidString).jpg"
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let photogalleryDirectory = documentsDirectory.appendingPathComponent("photogallery")
        
        do {
            try FileManager.default.createDirectory(at: photogalleryDirectory,
                                                   withIntermediateDirectories: true,
                                                   attributes: nil)
            
            let fileURL = photogalleryDirectory.appendingPathComponent(filename)
            
            try imageData.write(to: fileURL)
            DispatchQueue.global(qos: .userInitiated).async {
                let imageHandler = ImageHandler(dbHandler: dbHandler)
                imageHandler.addImage(path: fileURL.path, filename: filename) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(_):
                            showAddSuccessAlert = true
                            NotificationCenter.default.post(name: .refreshLabelView, object: nil)
                        case .failure(let error):
                            addError = error
                            showAddErrorAlert = true
                            try? FileManager.default.removeItem(at: fileURL)
                        }
                    }
                }
            }
        } catch {
            DispatchQueue.main.async {
                addError = error
                showAddErrorAlert = true
            }
        }
    }
}


















//MARK:- Camera View
struct CameraView: View {
    @Binding var isPresented: Bool
    @Binding var capturedImage: UIImage?
    
    var body: some View {
        CameraPreview(capturedImage: $capturedImage, isPresented: $isPresented)
            .edgesIgnoringSafeArea(.all)
    }
}

struct CameraPreview: UIViewControllerRepresentable {
    @Binding var capturedImage: UIImage?
    @Binding var isPresented: Bool
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> CameraViewController {
        let cameraVC = CameraViewController()
        cameraVC.delegate = context.coordinator
        return cameraVC
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
    
    class Coordinator: NSObject, CameraViewControllerDelegate {
        var parent: CameraPreview

        init(_ parent: CameraPreview) {
            self.parent = parent
        }

        func didCapture(image: UIImage) {
            parent.capturedImage = image
            parent.isPresented = false
        }
    }
}

protocol CameraViewControllerDelegate: AnyObject {
    func didCapture(image: UIImage)
}

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var photoOutput: AVCapturePhotoOutput!
    weak var delegate: CameraViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }

    func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo

        guard let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("No camera available")
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
        } catch {
            print("Error setting up camera: \(error)")
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.layer.bounds
        view.layer.addSublayer(previewLayer)

        photoOutput = AVCapturePhotoOutput()
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }

        let captureButton = UIButton(frame: CGRect(x: (view.frame.width - 70) / 2, y: view.frame.height - 100, width: 70, height: 70))
        captureButton.layer.cornerRadius = 35
        captureButton.backgroundColor = .white
        captureButton.layer.borderWidth = 3
        captureButton.layer.borderColor = UIColor.black.cgColor
        captureButton.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
        
        view.addSubview(captureButton)

        captureSession.startRunning()
    }

    @objc func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            return
        }
        delegate?.didCapture(image: image)
    }
}

#Preview {
    Cover()
}
