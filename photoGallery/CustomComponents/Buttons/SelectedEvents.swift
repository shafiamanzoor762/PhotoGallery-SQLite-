//
//  SelectedEvents.swift
//  photoGallery
//
//  Created by apple on 04/05/2025.
//

import SwiftUI

struct SelectedEvents: View {
    @State var items: [Eventt]
    @State var removeAction: (Eventt) -> Void
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(items, id: \.self) { item in
                    HStack {
                        Text(item.Name)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(Defs.seeGreenColor)
                            .cornerRadius(12)
                        Button(action: { removeAction(item) }) {
                            Image(systemName: "xmark")
                                .foregroundColor(Defs.seeGreenColor)
                        }
                    }
                    .frame(width: 120, height: 35)
                    .background(.white)
                    .cornerRadius(25)
                }
            }
        }
    }
}
