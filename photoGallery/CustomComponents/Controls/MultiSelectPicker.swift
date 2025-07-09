//
//  MultiSelectPicker.swift
//  photoGallery
//
//  Created by apple on 06/07/2025.
//

import SwiftUI

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

//#Preview {
//    MultiSelectPicker()
//}
