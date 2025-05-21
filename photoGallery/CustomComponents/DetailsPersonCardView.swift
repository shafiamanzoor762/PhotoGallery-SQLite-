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
            
            PersonImageView(imagePath: person.path)
            
            VStack(alignment: .leading) {
                HStack{
                    Text("Name")
                        .font(.caption)
                    
                    Text(person.name)
                        .font(.caption)
                        .foregroundColor(Defs.seeGreenColor)
                
                }
                HStack{
                    Text("Gender")
                        .font(.caption)
                    
                    Text(person.gender)
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
