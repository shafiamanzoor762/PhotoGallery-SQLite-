//
//  CustomImagePicker.swift
//  photoGallery
//
//  Created by apple on 24/04/2025.
//

import Foundation
import SwiftUI

struct CustomImagePicker: UIViewControllerRepresentable{
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        
    }
    func makeUIViewController(context: Context) ->
        UIImagePickerController {
            let picker = UIImagePickerController()
            picker.delegate = context.coordinator
            return picker
        }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    @Binding var contactImage: UIImage?
    
    class Coordinator:NSObject,UINavigationControllerDelegate,UIImagePickerControllerDelegate{
        let parent: CustomImagePicker
        init(_ parent: CustomImagePicker){
            self.parent = parent
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage{
                parent.contactImage = image
            }
            picker.dismiss(animated: true)
            print("Image Selected")
        }
    }
}
