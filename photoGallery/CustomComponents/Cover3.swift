//
//  Cover3.swift
//  ComponentsApp
//
//  Created by apple on 03/11/2024.
//

import SwiftUI

struct Cover3: View {
    
//    private var operationTabItems: [TabItemDescription] = [
//            .init(imageName: "list.bullet", title: "DETAILS"),
//            .init(imageName: "pencil", title: "EDIT"),
//            .init(imageName: "trash", title: "DELETE")
//        ]
    
    var body: some View {
        
        VStack{

            ZStack {
                Image("BabyGirl") // replace "children" with the name of your image asset
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 400)
                                .clipped()
                
                            RoundedRectangle(cornerRadius: 30)
                                .fill(Defs.seeGreenColor)
                                .frame(height: 300)
                                .padding(.top, 300)
                                
                            
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Name")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Spacer()
                                    VStack{
                                        Text("Eman")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        
                                        Image("BabyGirl")
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 40,height: 40)
                                            .clipped().padding(.top, -15)
                                    }
                                }
                                Divider().background(.white)
                                
//                                HStack {
//                                    Text("Name")
//                                        .font(.headline)
//                                        .foregroundColor(.white)
//                                    Spacer()
//                                    Text("Ahmed")
//                                        .font(.headline)
//                                        .foregroundColor(.white)
//                                }
//                                Divider()
                                
                                HStack {
                                    Text("Location")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text("Islamabad")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                                Divider().background(.white)
                                
                                HStack {
                                    Text("Event")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text("Eid")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                                Divider().background(.white)
                                
                                HStack {
                                    Text("Date")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text("12.12.2023")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                            }.padding(.top, 250)
                            .padding(.horizontal, 20)
            }.padding(.top, -100)
                        .padding(.horizontal, 5)
            //Spacer()
        }.navigationTitle("Cover 3")
    }
}


#Preview {
    NavigationStack {
        Cover3()
    }
}
