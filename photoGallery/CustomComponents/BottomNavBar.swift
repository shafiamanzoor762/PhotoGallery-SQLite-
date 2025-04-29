//
//  BottomNavBar.swift
//  ComponentsApp
//
//  Created by apple on 02/11/2024.
//

import SwiftUI

class NavBarState: ObservableObject {
    @Published var isHidden: Bool = false  // Default: NavBar is visible
}
class NavManager: ObservableObject {
    @Published var nav: Int = 1
}


struct BottomNavBar: View {
    
    @State public var selectedIndex = 0
    var tabCount :Int
    var tabItems: [TabItemDescription]
    
    @EnvironmentObject var navBarState: NavBarState
    
    var body: some View {
        ZStack {
            if tabCount == 5 {
                if selectedIndex == 0 {
                    Cover(viewName: "Label")
//                    UndoChangesView()
                } else if selectedIndex == 1 {
                    Cover(viewName: "People")
                } else if selectedIndex == 2 {
                    Cover(viewName: "Location")
                } else if selectedIndex == 3 {
                    Cover(viewName: "Event")
                } else if selectedIndex == 4 {
                    Cover(viewName: "Date")
                }
            }
            if tabCount == 3{
                if selectedIndex == 0 {
                    Cover2(TabviewName: "Details")
                } else if selectedIndex == 1 {
                    Cover2(TabviewName: "Edit")
                } else if selectedIndex == 2 {
                    Cover2(TabviewName: "Delete")
                }
            }
            GeometryReader { proxy in
                VStack {
                    Spacer()
                    HStack(alignment: .bottom, spacing: 0){
                        ForEach( 0..<tabItems.count
                            //0..<Defs.tabItems.count
                        ) { (index) in
                            VStack(spacing: 0) {
                                Spacer()
                                Rectangle()
                                    .foregroundColor( .clear)
                                    .frame(width: Defs.iconCircleEdge, height: Defs.iconCircleEdge)
                                    .overlay(
                                        ZStack {
                                            tabItems[index].iconView(Defs.seeGreenColor).opacity(self.selectedIndex == index ? 1.0 : 0.0)
                                            tabItems[index].iconView(Defs.accentColor).opacity(self.selectedIndex != index ? 1.0 : 0.0)
                                        }
                                    )
                                    .background(
                                        ZStack {
                                            tabItems[index].labelView(Defs.seeGreenColor).opacity(self.selectedIndex == index ? 1.0 : 0.0)
                                            tabItems[index].labelView(Color.white).opacity(self.selectedIndex != index ? 1.0 : 0.0)
                                        }.offset(Defs.labelOffset)
                                    )
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(height: self.selectedIndex == index ? 26 : 5)
                            }

                            .frame(width: proxy.size.width / CGFloat(tabCount)
                            )
//                            .frame(width: proxy.size.width * 0.333)
                            //.frame(width: proxy.size.width / CGFloat(Defs.tabItems.count))
                            
                            .contentShape( Rectangle() )
                            .onTapGesture {
                                withAnimation(.interactiveSpring(response: 0.4, dampingFraction: 0.7) ) { self.selectedIndex = index }
                            }
                        }
                    }
                    .background(
                        Rectangle()
                            .frame(height: Defs.topFrameSize.height + Defs.tabbarHeight + Defs.bottomSafeArea)
                            .overlay(
                                Circle()
                                    .foregroundColor(Defs.accentColor)
                                    .frame(width: Defs.iconCircleEdge, height: Defs.iconCircleEdge)
                                    .offset(CGSize(width: tabCount == 5 ? (proxy.size.width / CGFloat(Defs.tabItems.count)) * CGFloat(selectedIndex - 2) : CGFloat(self.selectedIndex - 1) * (proxy.size.width * 0.333)  , height: -29 ))
                                    //.offset(x: (proxy.size.width / CGFloat(Defs.tabItems.count)) * CGFloat(selectedIndex - 2), y: -29)
                            )
                            .foregroundColor(Defs.seeGreenColor)
                            .offset(Defs.bottomSafeAreaOffset)
                            .mask(
                                VStack(spacing: 0) {
                                    TopFrameView()
                                        .frame(width: Defs.topFrameSize.width, height: Defs.topFrameSize.height)
                                    
                                        .offset(CGSize(width: tabCount == 5 ? (proxy.size.width / CGFloat(Defs.tabItems.count)) * CGFloat(selectedIndex - 2) : CGFloat(self.selectedIndex - 1) * (proxy.size.width * 0.333) , height: 0))
                                        //.offset(x: (proxy.size.width / CGFloat(Defs.tabItems.count)) * CGFloat(selectedIndex - 2))
                                    Rectangle()
                                        .frame(height: Defs.tabbarHeight + Defs.bottomSafeArea)
                                }.offset(Defs.bottomSafeAreaOffset)
                            )
                            .shadow(color: Color.black.opacity(0.3) , radius: 15, x: 0, y: 0)
                    )
                    .frame(height: Defs.topFrameSize.height + Defs.tabbarHeight)
                }
            }.ignoresSafeArea(edges: [.trailing, .leading])
                .opacity(navBarState.isHidden ? 0 : 1)
            
        }.background(Defs.backgroundColor)
    }
}

#Preview {
    BottomNavBar(tabCount: 5, tabItems: Defs.tabItems)
}
