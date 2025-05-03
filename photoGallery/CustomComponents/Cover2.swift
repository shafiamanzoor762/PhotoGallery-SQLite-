//
//  Cover2.swift
//  ComponentsApp
//
//  Created by apple on 02/11/2024.
//

import SwiftUI

struct Cover2: View {
    let images: [String] = ["BabyGirl", "BabyGirl", "BabyGirl", "BabyGirl"]
    @State var TabviewName: String = "Sync"
    //@State var PrevView: String = "Label"
    
    var body: some View {
        VStack {
            
            
            // Top Bar
            HStack {
                Text(TabviewName)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.bottom, 5).padding(.leading, 20)
                
                    Spacer()
            }
            //.padding()
            .background(Defs.seeGreenColor)
        
        //Spacer()

        ZStack {
            Color.white
                .clipShape(RoundedCorner(radius: 30, corners: [.topLeft, .topRight]))
            
            VStack {
                
                if TabviewName == "Sync" {
                    Spacer()
                    
                    SyncView(isRequired: false)
                    Spacer()
                }
                if TabviewName == "Search" {
                    SearchView()
                }
                if TabviewName == "Bulk Edit" {
                    BulkEditView()
                }
                if TabviewName == "Undo Changes" {
                    UndoChangesView()
                }
            }
            //.padding(.top)
        }
        .ignoresSafeArea(edges: .bottom)
        //.padding(.top, -25)
    }
        .background(Defs.seeGreenColor.ignoresSafeArea())
        

        
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = 30
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

#Preview {
    Cover2()
}
