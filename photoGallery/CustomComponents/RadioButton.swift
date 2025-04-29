//
//  RadioButton.swift
//  ComponentsApp
//
//  Created by apple on 09/02/2025.
//

import SwiftUI

struct RadioButton: View {
    @Binding var selectedText:String
    var text: String = ""
    var foregroundColor: Color = Defs.seeGreenColor
    var body: some View {
        HStack{

            Image(systemName: text == selectedText ? "inset.filled.circle": "circle")
                .onTapGesture {
                    selectedText = text
                    //state.toggle()
                }
            Text(text)
        }.foregroundStyle(foregroundColor)
    }
}

#Preview {
//   RadioButton()
}
