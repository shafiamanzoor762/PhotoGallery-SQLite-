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
    @State private var selectedEvent: Eventt?
    
    @State private var showAddEventDialog = false
//    @State private var showErrorAlert = false
//       @State private var errorMessage = ""
    
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
//                Button(action: saveChanges) {
//                    Text("Save Changes")
//                        .frame(width: 150, height: 40)
//                        .background(Defs.seeGreenColor)
//                        .foregroundColor(.white)
//                        .cornerRadius(10)
//                }
//                .padding(.top)
                
                ButtonWhite(title: "Save Changes", action: saveChanges)
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
        .onAppear(){
            print(viewModel.allEvents.count)
        }
        .alert("Alert", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        
        
        .alert("Add New Event", isPresented: $showAddEventDialog) {
            TextField("Event Name", text: $viewModel.inputEvent)
                .frame(maxWidth: 150, maxHeight: 50)
                .font(.body)
                .background(Defs.seeGreenColor)
                .border(.gray, width: 1)
                .foregroundColor(.white)
                .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.white, lineWidth: 1))
            
            Button("Cancel", role: .cancel) {
                viewModel.inputEvent = ""
            }
            
            Button("Add") {
                addEvent()
            }
        } message: {
            Text("Enter the name for the new event")
        }
//        .alert("Alert", isPresented: $showAlert) {
//            Button("OK", role: .cancel) {}
//        } message: {
//            Text(alertMessage)
//        }
        
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
            Text("Select Events")
                .font(.headline)
                .foregroundColor(.white)
            Spacer()
            
            
            VStack{
//                Text("Select Events")
//                    .font(.headline)
                
                Spacer()
                
                HStack {
                    Picker("Event", selection: $selectedEvent) {
                        ForEach(viewModel.allEvents, id: \.self.Id) { event in
                            Text(event.Name).tag(event)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .onChange(of: selectedEvent ?? Eventt(Id: 0, Name: "")) { newEvent in
                        addEvent(newEvent)
                    }
                }
                selectedItemsView(items: viewModel.image.events, removeAction: removeEvent)
            }
            
            Button(action: { showAddEventDialog = true }) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 24))
                        .foregroundColor(.white)
                        .background(Defs.seeGreenColor)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
                .padding()

            
            
            
//            TextField("Enter Event Name", text: Binding(
//                get: { viewModel.inputEvent ?? "" },
//                set: { newValue in
//                    if !viewModel.inputEvent.isEmpty{
//                        viewModel.inputEvent = newValue
//                    }
//                }
//            ))
//            .frame(maxWidth: 150, maxHeight: 50)
//            .font(.body)
//                .background(Defs.seeGreenColor)
//                .border(.gray, width: 1)
//                .foregroundColor(.white)
//                .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.white, lineWidth: 1))
            
        }
        .frame(height: 50)
    }
    
    private var dateSections: some View {
        Group {
            HStack {
                Text("Location")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                TextField("Enter Location", text: $viewModel.image.location.Name
//                            Binding(
//                    get: { viewModel.image.location.Name },
//                    set: { newValue in
//                        if !viewModel.image.location.Name.isEmpty{
//                            viewModel.image.location.Name = newValue
//                        }
//                    }
//                )
                          
                )
                    .frame(maxWidth: 150, maxHeight: 50)
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
    
    private func addEvent() {
        viewModel.addNewEvent { success in
            if success {
                alertMessage = "Event added successfully!"
            } else {
                alertMessage = viewModel.error?.localizedDescription ?? "Failed to add event"
            }
            showAlert = true
        }
    }
    
    private func selectedItemsView(items: [Eventt], removeAction: @escaping (Eventt) -> Void) -> some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(items, id: \.self) { item in
                    HStack {
                        Text(item.Name)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(Defs.seeGreenColor)
                            .cornerRadius(12)
                        Button(action: { removeAction(item) }) {
                            Image(systemName: "xmark")
                                .foregroundColor(Defs.seeGreenColor)
                        }
                    }
                    .frame(width: 120, height: 35)
                    .background(.white)
                    .cornerRadius(25)
                }
            }
        }
    }
    
    private func removeEvent(_ event: Eventt) -> Void {
        viewModel.image.events.removeAll { $0.Id == event.Id }
    }
    
    private func addEvent(_ event: Eventt) {
        guard !viewModel.image.events.contains(where: { $0.Id == event.Id }) else { return }
        viewModel.image.events.append(event)
        selectedEvent = nil // Reset selection
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

