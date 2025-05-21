//
//  DetailsView.swift
//  ComponentsApp
//
//  Created by apple on 14/03/2025.
//

import SwiftUI

struct DetailsImageView: View {
    @State var image: ImageeDetail
    
    @State private var showPopup = false // Track popup visibility
    
    let columns = [
            GridItem(.flexible(), spacing: 10),
            GridItem(.flexible(), spacing: 10)
        ]
    
    var body: some View {
        ZStack {
            VStack {
                //Defs.seeGreenColor
                
                Text("Details for Image: \(image.path)")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                //                            RoundedRectangle(cornerRadius: 30)
                //                                .fill(Defs.seeGreenColor)
                //                                .frame(height: 300)
                //.padding(.top, 300)
                
                
                VStack(alignment: .leading, spacing: 12) {
                    if image.persons.count >= 1 {
                        HStack {
                            Text("Name")
                                .font(.headline)
                                .foregroundColor(.white)
                            Spacer()
                            VStack{
                                Text(image.persons.first?.name ?? "No Name")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                
                                PersonImageView(imagePath: image.persons.first?.path ?? "")
                            }
                            if image.persons.count >= 2{
                                //Image(systemName: "plus")
                                Text("more..")
                                    .padding(.top, 55)
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .onTapGesture {
                                        withAnimation {
                                            showPopup = true
                                        }
                                    }
                            }
                        }
                    }
                    Divider().background(.white)

                    HStack {
                        Text("Gender")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                        Text(image.persons.first?.gender ?? "Not Mention")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    Divider().background(.white)
                    
                    HStack {
                        Text("Event")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                        Text(image.events.first?.Name ?? "No Event")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    Divider().background(.white)
                    
                    HStack {
                        Text("Event Date")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                        Text(
                            {
                                let formatter = DateFormatter()
                                formatter.dateFormat = "yyyy-MM-dd"
                                return formatter.string(from: image.event_date)
                            }()
                        )
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    Divider().background(.white)
                    
                    HStack {
                        Text("Capture Date")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                        Text(
                            {
                                let formatter = DateFormatter()
                                formatter.dateFormat = "yyyy-MM-dd"
                                return formatter.string(from: image.capture_date)
                            }()
                        )
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    Divider().background(.white)
                    
                    HStack {
                        Text("Location")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                        Text(image.location.Name)
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(20)
            
            // Popup View
            if showPopup {
                ZStack {
                    // Background Overlay to Dismiss on Tap
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            withAnimation {
                                showPopup = false
                            }
                        }
                    
                    // Popup Content
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: {
                                withAnimation {
                                    showPopup = false
                                }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 10) {
                                ForEach($image.persons, id:\.self.id) { $person in
                                    DetailsPersonCardView(person: $person)
                                }
                            }
                            .padding()
                        }
                    }
                    .frame(width: 380, height: 280)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(radius: 10)
                }
            }
        }
        //.navigationTitle("Image Details")
    }
}





