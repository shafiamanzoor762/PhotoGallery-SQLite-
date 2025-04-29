//
//  DetailsPersonCardView.swift
//  ComponentsApp
//
//  Created by apple on 23/03/2025.
//

import SwiftUI

struct DetailsPersonCardView: View {
    @Binding var person: Personn
    
    var body: some View {
        HStack {
//            Image(person.Path)
//                .resizable()
//                .scaledToFit()
//                .frame(width: 45, height: 45)
//                .clipShape(RoundedRectangle(cornerRadius: 5))
            
            PersonImageView(imagePath: person.Path)
            
            VStack(alignment: .leading) {
                HStack{
                    Text("Name")
                        .font(.caption)
                    
                    Text(person.Name)
                        .font(.caption)
                        .foregroundColor(Defs.seeGreenColor)
                
                }
                HStack{
                    Text("Gender")
                        .font(.caption)
                    
                    Text(person.Gender)
                        .font(.caption)
                        .foregroundColor(Defs.seeGreenColor)
                    
                }
            }
//            .padding()
            .frame(width: 120)
            .background(RoundedRectangle(cornerRadius: 10).stroke(Defs.seeGreenColor, lineWidth: 1))
            
        }
    }
}

#Preview {
    //DetailsPersonCardView()
}
