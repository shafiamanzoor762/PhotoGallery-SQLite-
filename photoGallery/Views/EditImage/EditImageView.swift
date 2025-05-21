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
                    .zIndex(1)
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            }
            
            // Persons Popup
            if showPopup {
                personsPopup
                    .zIndex(2)
            }
            
            // Link Persons Popup
//            if viewModel.showLinkPopup {
//                Color.black.opacity(0.4)
//                    .edgesIgnoringSafeArea(.all)
//                LinkPopupView(viewModel: viewModel)
//            }
            
            if viewModel.showLinkPopup {
                ZStack {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            withAnimation {
                                viewModel.showLinkPopup = false
                            }
                        }
                        .zIndex(3)
                    LinkPopupView(viewModel: viewModel)
                    //                }
                        .zIndex(4)
                    //.transition(.opacity)
                }
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
                .foregroundColor(Defs.seeGreenColor)
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
                PersonImageView(imagePath: viewModel.image.persons.first?.path ?? "")
                
                TextField("Enter name", text: Binding(
                    get: { viewModel.image.persons.first?.name ?? "" },
                    set: { newValue in
                        if !viewModel.image.persons.isEmpty {
                            viewModel.image.persons[0].name = newValue
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
                    get: { viewModel.image.persons.first?.gender ?? "" },
                    set: { newValue in
                        if !viewModel.image.persons.isEmpty {
                            viewModel.image.persons[0].gender = newValue
                        }
                    }
                ).genderBinding(),
                text: "Male",
                foregroundColor: .white
            )
            
            RadioButton(
                selectedText: Binding(
                    get: { viewModel.image.persons.first?.gender ?? "" },
                    set: { newValue in
                        if !viewModel.image.persons.isEmpty {
                            viewModel.image.persons[0].gender = newValue
                        }
                    }
                ).genderBinding(),
                text: "Female",
                foregroundColor: .white
            )
        }
    }
    
    private var eventSection: some View {
        VStack {
            
            HStack {
                Text("Select Events")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                
                
                //            VStack{
                //                Text("Select Events")
                //                    .font(.headline)
                
                //                Spacer()
                
                //                HStack {
                Picker("Event", selection: $selectedEvent) {
                    ForEach(viewModel.allEvents, id: \.self.Id) { event in
                        Text(event.Name).tag(event)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .onChange(of: selectedEvent ?? Eventt(Id: 0, Name: "")) { newEvent in
                    addEvent(newEvent)
                }
                //                }
                
                //            }
                
                Button(action: { showAddEventDialog = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                        .background(Defs.seeGreenColor)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
                .padding()
            }
            
            selectedItemsView(items: viewModel.image.events, removeAction: removeEvent)
            
            
        }
//        .frame(height: 90)
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
                        ForEach($viewModel.image.persons, id: \.id) { $person in
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
                viewModel.unlinkedPersonResponseModel.removeAll()
                for person in viewModel.image.persons {
                    if person.name != "unknown"{
                        viewModel.personUnlinkDataRequest(selectedPerson: person)
                    }
                }
                
//                if viewModel.unlinkedPersonResponseModel.count > 0 {
                    viewModel.showLinkPopup = true
//                }
                
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
                    .padding()
                    .frame(height: 25)
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
//        selectedEvent = nil // Reset selection
    }
    
}


struct LinkPopupView: View {
    @ObservedObject var viewModel: EditImageViewModel

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Spacer()
                Button(action: {
                    withAnimation {
                        viewModel.showLinkPopup = false
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
            //.padding()
            // Title
            Text("Same or different person?")
                .font(.headline)
            Text("Improve your people groups")
                .font(.subheadline)
                .foregroundColor(Defs.seeGreenColor)
            Text("Tap on Group")
                .font(.caption)
                .foregroundColor(Defs.lightSeeGreenColor)

            ScrollView {
                VStack(spacing: 20) {
                    ForEach($viewModel.unlinkedPersonResponseModel, id: \.selectedPerson.id) { $unlinkedModel in
                        VStack(spacing: 12) {
                            PersonCircleImageView(imagePath: unlinkedModel.selectedPerson.path, size: 65)

                            ForEach(unlinkedModel.unLinkedPersons, id: \.person.id) { group in
                                GroupView(group: group, isSelected: viewModel.selectedGroupIDs.contains(group.person.id)) {
                                    if viewModel.selectedGroupIDs.contains(group.person.id) {
                                        viewModel.selectedGroupIDs.remove(group.person.id)
                                    } else {
                                        viewModel.selectedGroupIDs.insert(group.person.id)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 4)
                    

            // Action Buttons
            HStack {
                ButtonWhite(title: "Different", action: {
                    //viewModel.showLinkPopup = false
                    viewModel.selectedGroupIDs.removeAll()
                    print(viewModel.unlinkedPersonResponseModel)
                })
                ButtonOutline(title: "Same", action: {
                    viewModel.linkSelectedPersons(selectedPerson: unlinkedModel.selectedPerson)
                })
            }
            .padding(.bottom)
                        
                    }
                }
                .padding()
            }
        }
        .padding()
        .background(Color(UIColor.systemGroupedBackground))
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding()
    }
}



struct GroupView: View {
    var group: UnlinkedPersonResponse
    var isSelected: Bool
    var onTap: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            PersonCircleImageView(imagePath: group.person.path, size: 55)

            ForEach(group.persons.prefix(2), id: \.id) { p in
                PersonCircleImageView(imagePath: p.path, size:55)
            }

            if group.persons.count == 1 {
                Spacer().frame(width: 60, height: 60)
            }
        }
        .padding()
        .background(isSelected ? Defs.lightSeeGreenColor.opacity(0.5) : Color.white)
        .cornerRadius(10)
        .shadow(radius: 0.5)
        .onTapGesture {
            onTap()
        }
    }
}

