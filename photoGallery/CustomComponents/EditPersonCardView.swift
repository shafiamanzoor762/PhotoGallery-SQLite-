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
                    
                    
                    TextField("Enter name", text: $person.Name
                              
//                                Binding(
//                        get: { person.Name },
//                        set: { newValue in
//                            if !person.Name.isEmpty {
//                                person.Name = newValue
//                            }
//                        }
//                    )
                              
                    ).frame(maxWidth: 100) // Set width and height
                        .frame(height: 20).font(.caption)
                        .background(Color.clear)
                        //.border(.gray, width: 1)
                        .foregroundColor(Defs.seeGreenColor) // Text color white
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(Defs.seeGreenColor, lineWidth: 1))
                    
                }
                Text("Gender")
                    .font(.caption)
                HStack{
                    
                    
//                    VStack{
                        
                        RadioButton(selectedText: Binding(
                            get: { person.Gender},
                            set: { newValue in
                                if !person.Gender.isEmpty {
                                    person.Gender = newValue
                                }
                            }
                        ).genderBinding(), text: "Male", foregroundColor: Defs.seeGreenColor).font(.caption)
                        
                        RadioButton(selectedText: Binding(
                            get: { person.Gender},
                            set: { newValue in
                                if !person.Gender.isEmpty {
                                    person.Gender = newValue
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
