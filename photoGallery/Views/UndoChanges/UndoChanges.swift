//
//  UndoChanges.swift
//  photoGallery
//
//  Created by apple on 24/04/2025.
//

//import SwiftUI
//
//struct UndoChanges: View {
//    var body: some View {
//        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
//    }
//}
//
//#Preview {
//    UndoChanges()
//}

import SwiftUI

struct UndoChangesView: View {
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var navBarState: NavBarState
    
    // Dummy data model
    struct ImageItem: Identifiable {
        let id = UUID()
        let imageName: String
    }
    
    // Sample data
    let images = [
        ImageItem(imageName: "img6"),
        ImageItem(imageName: "img2"),
        ImageItem(imageName: "img4")
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            
            // Top Bar
            HStack {
                Text("Undo Changes")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    // Handle Undo All action
                }) {
                    Text("Undo All")
                        .font(.headline)
                        .foregroundColor(Defs.seeGreenColor)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.white)
                        .clipShape(Capsule())
                }
            }
            .padding()
            .background(Defs.seeGreenColor)
            .cornerRadius(20, corners: [.bottomLeft, .bottomRight])
            
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(images) { item in
                        HStack(alignment: .center, spacing: 16) {
                            // Image
                            Image(item.imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white, lineWidth: 2)
                                )
                                .padding(.leading)
                            
                            Spacer()
                            
                            // Buttons
                            VStack(spacing: 10) {
                                Button(action: {
                                    // View button action
                                }) {
                                    Text("View")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(width: 120, height: 40)
                                        .background(Defs.seeGreenColor)
                                        .cornerRadius(20)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.black, lineWidth: 1)
                                        )
                                }
                                
                                Button(action: {
                                    // Undo button action
                                }) {
                                    Text("Undo")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(width: 120, height: 40)
                                        .background(Defs.seeGreenColor)
                                        .cornerRadius(20)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.black, lineWidth: 1)
                                        )
                                }
                            }
                            .padding(.trailing)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Defs.lightSeeGreenColor)
                        .cornerRadius(20)
                        .padding(.horizontal)
                    }
                }
                .padding(.top, 10)
            }
            Spacer()
        }
        .background(Color.white.edgesIgnoringSafeArea(.all))
        .onAppear {
            navBarState.isHidden = true
        }
        .onDisappear {
            navBarState.isHidden = false
        }
    }
}


// Corner Radius Extension to only round specific corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCornerr(radius: radius, corners: corners) )
    }
}

struct RoundedCornerr: Shape {
    
    var radius: CGFloat = 0.0
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}



