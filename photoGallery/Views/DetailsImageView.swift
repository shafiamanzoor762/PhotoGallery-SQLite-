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
                                Text(image.persons.first?.Name ?? "No Name")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
//                                Image(image.persons.first?.Path ?? "")
//                                    .resizable()
//                                    .aspectRatio(contentMode: .fill)
//                                    .frame(width: 40,height: 40)
//                                    .clipShape(RoundedRectangle(cornerRadius: 5))
//                                    .padding(.top, -15)
                                
                                PersonImageView(imagePath: image.persons.first?.Path ?? "")
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
                        Text(image.persons.first?.Gender ?? "Not Mention")
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
                                ForEach($image.persons, id:\.self.Id) { $person in
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


struct PersonImageView: View {
    let imagePath: String
    @State private var faceImage: UIImage?
    
    var body: some View {
        Group {
            if let faceImage = faceImage {
                Image(uiImage: faceImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .padding(.top, -15)
            } else {
                // Placeholder while loading
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 40)
                    .foregroundColor(.gray)
                    .padding(.top, -15)
                    .onAppear {
                        loadFaceImage()
                    }
            }
        }
    }
    
    private func loadFaceImage() {
        ApiHandler.loadFaceImage(from: imagePath) { image in
            DispatchQueue.main.async {
                self.faceImage = image
            }
        }
    }
}


#Preview {
    DetailsImageView(image: ImageeDetail(
        id: 1,
        path: "img1",
        is_Sync: true,
        capture_date: Date(),
        event_date: Date(),
        last_modified: Date(),
        location: Locationn(Id: 1, Name: "Islamabad Pakistan", Lat: 40.7128, Lon: -74.0060),
        events: [
            Eventt(Id: 1, Name: "Birthday"),
            Eventt(Id: 2, Name: "Wedding")
        ],
        persons: [
            Personn(Id: 1, Name: "Kiran", Gender: "F", Path: "p8"),
            Personn(Id: 2, Name: "Salman", Gender: "M", Path: "p12"),
            Personn(Id: 3, Name: "Kashaf", Gender: "F", Path: "p18")
        ]
    ))
}
