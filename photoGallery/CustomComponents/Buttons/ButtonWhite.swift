//
//  ButtonWhite.swift
//  photoGallery
//
//  Created by apple on 03/05/2025.
//

import SwiftUI

struct ButtonWhite: View {
    var title: String
    var action: () -> Void
    @State private var pressed = false

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(Defs.seeGreenColor)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.white)
                .clipShape(Capsule())
        }
        
//            .onLongPressGesture(minimumDuration: .infinity,maximumDistance: .infinity, pressing: { pressing in withAnimation(.easeInOut(duration: 0.2)){
//                self.pressed = pressing
//            }},perform: {})
        
    }
}



#Preview {
    ButtonWhite(title: "click me", action: {})
}
