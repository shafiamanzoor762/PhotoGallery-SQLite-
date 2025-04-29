//
//  TextComponent.swift
//  ComponentsApp
//
//  Created by apple on 02/11/2024.
//

import SwiftUI

struct TextComponent: View {
    var title: String
    var body: some View {
        Text(title)
            .foregroundStyle(Defs.seeGreenColor)
            //.bold()
            .font(.title2)
    }
}

#Preview {
    TextComponent(title: "Text")
}
