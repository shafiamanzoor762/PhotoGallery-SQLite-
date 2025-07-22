//
//  CustomFoldersView.swift
//  photoGallery
//
//  Created by apple on 10/07/2025.
//

import SwiftUI

// MARK: - View
struct CustomFolderView: View {
    @ObservedObject var viewModel: CustomFolderViewModel

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Enter folder name", text: $viewModel.folderNameInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Button(action: {
                        viewModel.addFolder()
                    }) {
                        Image(systemName: "plus")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                    .disabled(viewModel.folderNameInput.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding()

                List(viewModel.folders) { folder in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(folder.name).font(.headline)
                            Text("Created: \(folder.createdAt.formatted(date: .abbreviated, time: .shortened))")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle("Custom Folders")
        }
    }
}

//#Preview {
//    CustomFolderView()
//}
