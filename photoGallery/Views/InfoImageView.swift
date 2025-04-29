//
//  InfoImageView.swift
//  ComponentsApp
//
//  Created by apple on 16/03/2025.
//

import SwiftUI

struct InfoImageView: View {
    var body: some View {
        VStack{
            HStack{
                Text("Title")
                Spacer()
                Text("7dfce34d.jpg")
            }
            .padding(.bottom)
            
            HStack{
                Text("File Size")
                Spacer()
                Text("202KB")
            }
            .padding(.bottom)
            
            HStack{
                Text("Path")
                Spacer()
                Text("/storage/emulated/pictures/7dfce34d.jpg")
            }
            .padding(.bottom)
            
            HStack{
                Text("Format")
                Spacer()
                Text("image/jpeg")
            }
            .padding(.bottom)
            
            HStack{
                Text("Time")
                Spacer()
                Text("03:00 PM")
            }
            .padding(.bottom)
            
            HStack{
                Text("Modified Date")
                Spacer()
                Text("11/3/2024")
            }
            .padding(.bottom)
            
            HStack{
                Text("Resolutions")
                Spacer()
                Text("738x1445")
            }
            .padding(.bottom)
            
            HStack{
                Text("Date")
                Spacer()
                Text("11/2/2022")
            }
            .padding(.bottom)
            //Divider().background(.white)
            
        }.padding()
         .foregroundColor(.white)
            
    }
}

#Preview {
    InfoImageView()
}
