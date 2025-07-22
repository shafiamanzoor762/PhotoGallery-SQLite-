//
//  CustomFolders.swift
//  photoGallery
//
//  Created by apple on 10/07/2025.
//

import SQLite
import Foundation
// MARK: - Model
struct CustomFolder: Identifiable, Hashable {
    let id: Int
    var name: String
    var createdAt: Date
}

// MARK: - ViewModel
class CustomFolderViewModel: ObservableObject {
    @Published var folders: [CustomFolder] = []
    @Published var folderNameInput: String = ""

    let dbHandler: DBHandler

    init(dbHandler: DBHandler) {
        self.dbHandler = dbHandler
        fetchFolders()
    }

    func fetchFolders() {
        folders.removeAll()
        guard let db = dbHandler.db else { return }
        do {
            for row in try db.prepare(dbHandler.customFolderTable) {
                let id = row[dbHandler.folderId]
                let name = row[dbHandler.folderName]
                let createdAtStr = row[dbHandler.folderCreatedAt] ?? ""
                let createdAt = DateFormatter.yyyyMMdd_HHmmss.date(from: createdAtStr) ?? Date()

                folders.append(CustomFolder(id: id, name: name, createdAt: createdAt))
            }
        } catch {
            print("Error fetching folders: \(error.localizedDescription)")
        }
    }

    func addFolder() {
        guard !folderNameInput.trimmingCharacters(in: .whitespaces).isEmpty,
              let db = dbHandler.db else { return }

        let insert = dbHandler.customFolderTable.insert(
            dbHandler.folderName <- folderNameInput,
            dbHandler.folderCreatedAt <- Date().toSqlServerFormat()
        )

        do {
            let rowId = try db.run(insert)
            let newFolder = CustomFolder(id: Int(rowId), name: folderNameInput, createdAt: Date())
            folders.append(newFolder)
            folderNameInput = ""
        } catch {
            print("Error adding folder: \(error.localizedDescription)")
        }
    }
}


