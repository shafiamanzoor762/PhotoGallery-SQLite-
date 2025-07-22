//
//  Cover2.swift
//  ComponentsApp
//
//  Created by apple on 02/11/2024.
//

import SwiftUI

struct Cover2: View {
    let images: [String] = ["BabyGirl", "BabyGirl", "BabyGirl", "BabyGirl"]
    @State var tabViewName: String = "Sync"
    
    var emojiForView: String {
            switch tabViewName {
            case "Sync": return "⇄"
            case "Search": return "🔎"
            case "Undo Changes": return "↺"
            case "Redo Changes": return "↻"
            case "Trash Images": return "🗑"
            default: return ""
            }
        }
    
    var body: some View {
        VStack {
            
            
            // Top Bar
            HStack {
                Text(emojiForView+" "+tabViewName)
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
                
                if tabViewName == "Sync" {
                    Spacer()
                    
                    SyncView(isRequired: false)
                    Spacer()
                }
                
                if tabViewName == "Search" {
                    SearchView()
                }
//                if TabviewName == "Bulk Edit" {
////                    BulkEditView()
//                }
                
                if tabViewName == "Undo Changes" {
                    UndoChangesView()
                }
                
                if tabViewName == "Redo Changes" {
                    RedoChangesView()
                }
                
                if tabViewName == "Featured Faces" {
                    FeaturedFacesView()
                }
                
                if tabViewName == "Trash Images" {
                    TrashView()
                }
                
//                if tabViewName == "PeopleBirthdayTaskView" {
//                    PeopleBirthdayTaskView()
//                }
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
