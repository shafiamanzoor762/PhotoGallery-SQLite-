//
//  ButtonOutline.swift
//  photoGallery
//
//  Created by apple on 03/05/2025.
//

import SwiftUI

struct ButtonOutline: View {
    var title: String
    var action: () -> Void
    @State private var pressed = false

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 120, height: 40)
                .background(Defs.seeGreenColor)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.black, lineWidth: 1)
                )
        }
    }
}

#Preview {
    ButtonOutline(title: "click", action: {})
}
