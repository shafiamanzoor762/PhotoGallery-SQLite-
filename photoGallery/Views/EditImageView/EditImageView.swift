//
//  EditView.swift
//  ComponentsApp
//
//  Created by apple on 23/03/2025.
//
//
import SwiftUI

struct EditImageView: View {
    @StateObject private var viewModel: EditImageViewModel
    @State private var showPopup = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    // Initialize with required dependencies
    init(image: ImageeDetail) {
        _viewModel = StateObject(wrappedValue: EditImageViewModel(image: image))
    }
    
    var body: some View {
        ZStack {
            VStack {
                Text("Image: \(viewModel.image.path)")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 12) {
                    // Name Section
                    if viewModel.image.persons.count >= 1 {
                        nameSection
                        Divider().background(.white)
                    }
                    
                    // Gender Section
                    genderSection
                    Divider().background(.white)
                    
                    // Event Section
                    eventSection
                    Divider().background(.white)
                    
                    // Date Sections
                    dateSections
                }
                
                // Save Button
                Button(action: saveChanges) {
                    Text("Save Changes")
                        .frame(width: 150, height: 40)
                        .background(Defs.seeGreenColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.top)
            }
            .padding(20)
            
            // Loading Indicator
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            }
            
            // Persons Popup
            if showPopup {
                personsPopup
            }
        }
        .alert("Error", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .background(Defs.seeGreenColor)
    }
    
    // MARK: - View Components
    private var nameSection: some View {
        HStack {
            Text("Name")
                .font(.headline)
                .foregroundColor(.white)
            Spacer()
            VStack(alignment: .leading) {
                PersonImageView(imagePath: viewModel.image.persons.first?.Path ?? "")
                
                TextField("Enter name", text: Binding(
                    get: { viewModel.image.persons.first?.Name ?? "" },
                    set: { newValue in
                        if !viewModel.image.persons.isEmpty {
                            viewModel.image.persons[0].Name = newValue
                        }
                    }
                ))
                .frame(maxWidth: 100, maxHeight: 20)
                .font(.caption)
                .background(Defs.seeGreenColor)
                .border(.gray, width: 1)
                .foregroundColor(.white)
                .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.white, lineWidth: 1))
                
                if viewModel.image.persons.count >= 2 {
                    Text("more..")
//                        .padding(.top, 55)
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
    }
    
    private var genderSection: some View {
        HStack {
            Text("Gender")
                .font(.headline)
                .foregroundColor(.white)
            Spacer()
            
            RadioButton(
                selectedText: Binding(
                    get: { viewModel.image.persons.first?.Gender ?? "" },
                    set: { newValue in
                        if !viewModel.image.persons.isEmpty {
                            viewModel.image.persons[0].Gender = newValue
                        }
                    }
                ).genderBinding(),
                text: "Male",
                foregroundColor: .white
            )
            
            RadioButton(
                selectedText: Binding(
                    get: { viewModel.image.persons.first?.Gender ?? "" },
                    set: { newValue in
                        if !viewModel.image.persons.isEmpty {
                            viewModel.image.persons[0].Gender = newValue
                        }
                    }
                ).genderBinding(),
                text: "Female",
                foregroundColor: .white
            )
        }
    }
    
    private var eventSection: some View {
        HStack {
            Text("Event")
                .font(.headline)
                .foregroundColor(.white)
            Spacer()

            
            TextField("Enter Event Name", text: Binding(
                get: { viewModel.image.events.first?.Name ?? "Gala" },
                set: { newValue in
//                    if !viewModel.image.events.isEmpty{
//                        viewModel.image.events.first.Name = newValue
//                    }
                }
            ))
            .frame(maxWidth: 150, maxHeight: 50)
            .font(.body)
                .background(Defs.seeGreenColor)
                .border(.gray, width: 1)
                .foregroundColor(.white)
                .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.white, lineWidth: 1))
        }
    }
    
    private var dateSections: some View {
        Group {
            HStack {
                Text("Location")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                TextField("Enter Location", text: Binding(
                    get: { viewModel.image.location.Name },
                    set: { newValue in
                        if !viewModel.image.location.Name.isEmpty{
                            viewModel.image.location.Name = "BIIT"
                        }
                    }
                )).frame(maxWidth: 150, maxHeight: 50)
                .font(.body)
                    .background(Defs.seeGreenColor)
                    .border(.gray, width: 1)
                    .foregroundColor(.white)
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.white, lineWidth: 1))
            }
            
            Divider().background(.white)
            
            HStack {
                Text("Event Date")
                    .font(.headline)
                    .foregroundColor(.white)

                
                DatePicker("", selection: $viewModel.image.event_date, displayedComponents: .date)
                    .labelsHidden()
                
            }
//            Divider().background(.white)
//            
//            HStack {
//                Text("Capture Date")
//                    .font(.headline)
//                    .foregroundColor(.white)
//                Spacer()
//                Text(HelperFunctions.dateString(from: viewModel.image.capture_date))
//                    .font(.headline)
//                    .foregroundColor(.white)
//            }
 
        }
    }
    
    private var personsPopup: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    withAnimation {
                        showPopup = false
                    }
                }
            
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
                        ForEach($viewModel.image.persons, id: \.Id) { $person in
                            EditPersonCardView(person: $person)
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
    
    // MARK: - Actions
    
    private func saveChanges() {
        viewModel.saveChanges { success in
            if success {
                alertMessage = "Changes saved successfully!"
            } else {
                alertMessage = viewModel.error?.localizedDescription ?? "Failed to save changes"
            }
            showAlert = true
        }
    }
}



extension Binding where Value == String {
    func genderBinding() -> Binding<String> {
        Binding<String>(
            get: {
                switch self.wrappedValue {
                case "M": return "Male"
                case "F": return "Female"
                case "U": return "Unknown"
                default: return ""
                }
            },
            set: { newValue in
                switch newValue {
                case "Male": self.wrappedValue = "M"
                case "Female": self.wrappedValue = "F"
                default: self.wrappedValue = "U"
                }
            }
        )
    }
}


















//=========================================







//struct EditImageView: View {
//    @StateObject private var viewModel: EditImageViewModel
//    @State private var showPopup = false
//    @State private var showAlert = false
//    @State private var alertMessage = ""
//    
//    let columns = [
//        GridItem(.flexible(), spacing: 10),
//        GridItem(.flexible(), spacing: 10)
//    ]
//    
//    init(image: ImageeDetail) {
//        _viewModel = StateObject(wrappedValue: EditImageViewModel(image: image))
//    }
//    
//    var body: some View {
//        ZStack {
//            VStack {
//                // Image preview or path display
//                Text("Editing: \(viewModel.image.path)")
//                    .fontWeight(.bold)
//                    .foregroundColor(.white)
//                
//                Form {
//                    // Persons Section
//                    Section(header: Text("People").foregroundColor(.white)) {
//                        ForEach($viewModel.image.persons, id:\.self.Id) { $person in
//                            HStack {
//                                PersonImageView(imagePath: person.Path)
//                                TextField("Name", text: $person.Name)
//                                Picker("Gender", selection: $person.Gender) {
//                                    Text("Male").tag("M")
//                                    Text("Female").tag("F")
//                                    Text("Unknown").tag("U")
//                                }
//                                .pickerStyle(MenuPickerStyle())
//                            }
//                        }
//                    }
//                    
//                    // Events Section
//                    Section(header: Text("Events").foregroundColor(.white)) {
//                        ForEach($viewModel.image.events, id:\.self.Id) { $event in
//                            TextField("Event Name", text: $event.Name)
//                        }
//                    }
//                    
//                    // Location Section
//                    Section(header: Text("Location").foregroundColor(.white)) {
//                        TextField("Location Name", text: $viewModel.image.location.Name)
//                        HStack {
//                            Text("Latitude: \(viewModel.image.location.Lat ?? 0)")
//                            Text("Longitude: \(viewModel.image.location.Lon ?? 0)")
//                        }
//                    }
//                    
//                    // Dates Section
//                    Section(header: Text("Dates").foregroundColor(.white)) {
//                        DatePicker("Event Date", selection: $viewModel.image.event_date, displayedComponents: .date)
//                        DatePicker("Capture Date", selection: $viewModel.image.capture_date, displayedComponents: .date)
//                    }
//                }
//                .scrollContentBackground(.hidden)
//                .background(Defs.seeGreenColor)
//                
//                // Save Button
//                Button(action: saveChanges) {
//                    Text("Save Changes")
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(10)
//                }
//                .padding()
//            }
//            
//            // Loading Indicator
//            if viewModel.isLoading {
//                ProgressView()
//                    .scaleEffect(1.5)
//                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                    .background(Color.black.opacity(0.4))
//            }
//        }
//        .background(Defs.seeGreenColor)
//        .alert("Error", isPresented: $showAlert) {
//            Button("OK", role: .cancel) { }
//        } message: {
//            Text(alertMessage)
//        }
//    }
//    
//    private func saveChanges() {
//        viewModel.saveChanges { success in
//            alertMessage = success ? "Changes saved successfully!" :
//                (viewModel.error?.localizedDescription ?? "Failed to save changes")
//            showAlert = true
//        }
//    }
//}

// MARK: - Helper Views
//struct PersonImageView: View {
//    let imagePath: String
//    
//    var body: some View {
//        Image(imagePath)
//            .resizable()
//            .scaledToFill()
//            .frame(width: 40, height: 40)
//            .clipShape(Circle())
//    }
//}
