//
//  PersonsView.swift
//  photoGallery
//
//  Created by apple on 05/07/2025.
//

import SwiftUI


struct PersonsView: View {
    
    @State var person1: Personn
    @State var person2: Personn
    @State var screenName: String

    var body: some View {
        VStack {
            HStack(spacing: 16) {
                // Person 1
                VStack(alignment: .center, spacing: 8) {
                    ZStack(alignment: .bottomTrailing) {
                        PersonCircleImageView(imagePath: person1.path, size: 60)
                        
                        if person1.name.lowercased() == "unknown" {
                            Image(systemName: "questionmark.circle.fill")
                                .font(.system(size: 16))
                                .foregroundStyle(.blue)
                                .background(Color.white)
                                .clipShape(Circle())
                                .offset(x: -5, y: -5)
                        }
                    }
                    
                    personInfoView(person: person1)
                }
                .frame(maxWidth: .infinity)
                
                // Arrow between them
                Image(systemName: "arrowshape.turn.up.right.fill")
                    .font(.system(size: 28))
                //                .rotationEffect(.degrees(45))
                    .foregroundColor(.lightPink)
                
                // Person 2
                VStack(alignment: .center, spacing: 8) {
                    ZStack(alignment: .bottomTrailing) {
                        PersonCircleImageView(imagePath: person2.path, size: 60)
                        
                        if person2.name.lowercased() == "unknown" {
                            Image(systemName: "questionmark.circle.fill")
                                .font(.system(size: 16))
                                .foregroundStyle(.blue)
                                .background(Color.white)
                                .clipShape(Circle())
                                .offset(x: -5, y: -5)
                        }
                    }
                    
                    personInfoView(person: person2)
                }
                .frame(maxWidth: .infinity)
            }
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(radius: 4)
            .padding(.horizontal)
        }
        .navigationTitle(screenName)
        
    }

    @ViewBuilder
    private func personInfoView(person: Personn) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: "person.fill")
                Text(person.name.capitalized)
            }
            HStack {
                Image(systemName: "figure.stand")
                Text(person.gender.capitalized)
            }
            if let age = person.age {
                HStack {
                    Image(systemName: "calendar")
                    Text("\(age) years old")
                }
            }
            if let dob = person.dob {
                HStack {
                    Image(systemName: "gift.fill")
                    Text(dob.formatted(date: .abbreviated, time: .omitted))
                }
            }
        }
        .font(.footnote)
        .foregroundColor(.primary)
    }
}


//#Preview {
//    PersonsView()
//}
