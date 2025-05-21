//
//  EditPersonCardView.swift
//  ComponentsApp
//
//  Created by apple on 23/03/2025.
//

import SwiftUI

struct EditPersonCardView: View {
    @Binding var person: Personn
    
    var body: some View {
        HStack {

            
            PersonImageView(imagePath: person.path)
            
            VStack(alignment: .leading) {
                HStack{
                    Text("Name")
                        .font(.caption)
                    
                    TextField("Enter name", text: $person.name
                              
                    ).frame(maxWidth: 100) // Set width and height
                        .frame(height: 20).font(.caption)
                        .background(Color.clear)
//                        .border(.gray, width: 1)
                        .foregroundColor(Defs.seeGreenColor) // Text color white
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(Defs.seeGreenColor, lineWidth: 1))
                }
                Text("Gender")
                    .font(.caption)
                HStack{
                    
                    
//                    VStack{
                        
                        RadioButton(selectedText: Binding(
                            get: { person.gender},
                            set: { newValue in
                                if !person.gender.isEmpty {
                                    person.gender = newValue
                                }
                            }
                        ).genderBinding(), text: "Male", foregroundColor: Defs.seeGreenColor).font(.caption)
                        
                        RadioButton(selectedText: Binding(
                            get: { person.gender},
                            set: { newValue in
                                if !person.gender.isEmpty {
                                    person.gender = newValue
                                }
                            }
                        ).genderBinding(), text: "Female", foregroundColor: Defs.seeGreenColor).font(.caption2)
//                    }
                    
                    
                }
            }
            .padding(2)
            .frame(width: 120)
            .background(RoundedRectangle(cornerRadius: 10).stroke(Defs.lightSeeGreenColor, lineWidth: 0.5))
            
        }
    }
}

#Preview {
//    EditPersonCardView()
}
