//
//  SearchView.swift
//  ComponentsApp
//
//  Created by apple on 24/11/2024.
//

import SwiftUI
import MapKit
//
//struct SearchView: View {
//    @State private var nameInput = ""
//    @State private var selectedNames: [String] = ["Alina", "Rimsha", "Aliya", "Esha", "Alishba", "Aliha"]
//    @State private var selectedGender: String = ""
//    @State private var selectedEvents: [String] = []
//    @State private var selectedDates: [String] = ["12.11.2024", "04.01.2022", "01.10.2009", "02.11.2024"]
//    @State private var captureDate = Date()
//    @State private var events = ["Birthday", "Eid", "Convocation", "Independence Day"]
//
//    @State private var region = MKCoordinateRegion(
//        center: CLLocationCoordinate2D(latitude: 33.6995, longitude: 73.0363), // Default to San Francisco
//        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
//    )
//    
//    @State private var selectedLocations: [MapLocation] = []
//
//    @Environment(\.dismiss) var dismiss
//    @EnvironmentObject var navBarState: NavBarState
//    
//    var body: some View {
//        ScrollView{
//            VStack(alignment: .leading, spacing: 20) {
//                //                Text("Search")
//                //                    .font(.largeTitle)
//                //                    .fontWeight(.bold)
//                
//                // Name Section
//                Text("Name")
//                    .font(.headline)
//                HStack {
//                    TextField("Eman", text: $nameInput)
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                    Button(action: {
//                        // Logic to add name to the selected list
//                        if !nameInput.isEmpty && !selectedNames.contains(nameInput) {
//                            selectedNames.append(nameInput)
//                            nameInput = ""
//                        }
//                    }) {
//                        Image(systemName: "checkmark.circle.fill")
//                            .foregroundColor(Defs.seeGreenColor)
//                            .font(.title)
//                    }
//                }
//                
//                ScrollView(.horizontal) {
//                    HStack {
//                        ForEach(selectedNames, id: \.self) { name in
//                            HStack {
//                                Text(name)
//                                    .padding(.horizontal, 8)
//                                    .padding(.vertical, 4)
//                                    .background(Color.gray.opacity(0.2)).foregroundColor(Color.white)
//                                    .cornerRadius(12)
//                                Button(action: {
//                                    // Logic to remove name from the list
//                                    selectedNames.removeAll { $0 == name }
//                                }) {
//                                    Image(systemName: "xmark")
//                                        .foregroundColor(.white)
//                                }
//                            }.frame(width:120, height:35).background(Defs.seeGreenColor).cornerRadius(25)
//                        }
//                    }
//                }
//                // Event Section
//                Text("Gender")
//                    .font(.headline)
//                HStack{
//                    RadioButton(selectedText: $selectedGender,text: "Male")
//                    RadioButton(selectedText: $selectedGender, text:"Female")
//                }
//                // Event Section
//                Text("Event")
//                    .font(.headline)
//                ForEach(events, id: \.self) { event in
//                    HStack {
//                        Toggle(isOn: Binding(
//                            get: { selectedEvents.contains(event) },
//                            set: { isSelected in
//                                if isSelected {
//                                    selectedEvents.append(event)
//                                } else {
//                                    selectedEvents.removeAll { $0 == event }
//                                }
//                            }
//                        )) {
//                            Text(event)
//                        }
//                    }
//                }
//                
//                // Capture Date Section
//                Text("Capture Date")
//                    .font(.headline)
//                HStack {
//                    DatePicker("", selection: $captureDate, displayedComponents: .date)
//                        .labelsHidden()
//                    Button(action: {
//                        let formatter = DateFormatter()
//                        formatter.dateStyle = .short
//                        let formattedDate = formatter.string(from: captureDate)
//                        if !selectedDates.contains(formattedDate) {
//                            selectedDates.append(formattedDate)
//                        }
//                    }) {
//                        Image(systemName: "checkmark.circle.fill")
//                            .foregroundColor(Defs.seeGreenColor)
//                            .font(.title)
//                    }
//                }
//                
//                ScrollView(.horizontal) {
//                    HStack {
//                        ForEach(selectedDates, id: \.self) { date in
//                            HStack {
//                                Text(date)
//                                    .padding(.horizontal, 8)
//                                    .padding(.vertical, 4)
//                                    .background(Color.gray.opacity(0.2)).foregroundColor(Color.white)
//                                    .cornerRadius(12)
//                                Button(action: {
//                                    // Logic to remove date from the list
//                                    selectedDates.removeAll { $0 == date }
//                                }) {
//                                    Image(systemName: "xmark")
//                                        .foregroundColor(.white)
//                                }
//                            }.frame(width:150, height:35).background(Defs.seeGreenColor).cornerRadius(25)
//                        }
//                    }
//                }
//                
//                // Location Section
//                Text("Location")
//                    .font(.headline)
//                //                Image("Map") // Replace with the actual image name in your assets
//                //                    .resizable()
//                //                    .scaledToFit()
//                //                    .frame(width: 350)
//                //                    .padding(.leading)
//                
////                Map(coordinateRegion: .constant(MKCoordinateRegion(
////                    center: CLLocationCoordinate2D(latitude: 30.3753, longitude: 69.3451), // Example: San Francisco
////                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
////                )))
////                .frame(height: 300)
////                .cornerRadius(12)
////                .padding(.horizontal)
//                
//                
//                Text("Tap on the map to select a location")
//                                .font(.headline)
//                                .padding()
//
//                            Map(coordinateRegion: $region, interactionModes: .all, annotationItems: selectedLocations) { location in
//                                MapMarker(coordinate: location.coordinate, tint: .red) // Marker at selected location
//                            }
//                            .frame(height: 300)
//                            .cornerRadius(12)
//                            .padding(.horizontal)
//                            .onTapGesture { location in
//                                let coordinate = convertTapToCoordinate(location: location, in: region)
//                                let newLocation = MapLocation(coordinate: coordinate)
//                                selectedLocations = [newLocation] // Updates the state with new location
//                            }
//                            
//                            // Display selected coordinates
//                            if let lastLocation = selectedLocations.last {
//                                Text("Latitude: \(lastLocation.coordinate.latitude), Longitude: \(lastLocation.coordinate.longitude)")
//                                    .padding()
//                            }
//
//                            Spacer()
//                
//                ButtonComponent(title: "Search", action: {}).padding(.leading, 100)
//                // Search Button
//                //                Button(action: {
//                //                    // Logic for search
//                //                }) {
//                //                    Text("Search")
//                //                        .frame(maxWidth: .infinity)
//                //                        .padding()
//                //                        .background(Defs.seeGreenColor)
//                //                        .foregroundColor(.white)
//                //                        .cornerRadius(10)
//                //                }
//            }
//            .padding()
//        }.onAppear {
//            navBarState.isHidden = true
//        }
//        .onDisappear {
//            navBarState.isHidden = false
//        }
//    }
//}
//
//// MARK: - Identifiable Struct for Locations
//struct MapLocation: Identifiable {
//    let id = UUID() // Unique identifier for SwiftUI
//    let coordinate: CLLocationCoordinate2D
//}
//
//// MARK: - Convert Tap to Coordinate Function
//func convertTapToCoordinate(location: CGPoint, in region: MKCoordinateRegion) -> CLLocationCoordinate2D {
//    let mapSize = UIScreen.main.bounds
//    let lat = region.center.latitude + (Double(location.y / mapSize.height) - 0.5) * region.span.latitudeDelta
//    let lon = region.center.longitude + (Double(location.x / mapSize.width) - 0.5) * region.span.longitudeDelta
//    return CLLocationCoordinate2D(latitude: lat, longitude: lon)
//}
//
//#Preview {
//    SearchView()
//}














//struct SearchView: View {
//    @StateObject private var viewModel = SearchModelView()
//    @State private var nameInput = ""
//    @State private var selectedNames: [String] = []
//    @State private var selectedGender: String = ""
//    @State private var selectedEvents: [String] = []
//    @State private var selectedDates: [Date] = []
//    @State private var captureDate = Date()
//    @State private var events = ["Birthday", "Eid", "Convocation", "Independence Day"]
//    @State private var locationNameInput = ""
//    @State private var selectedLocationNames: [String] = []
//    
//    @State private var region = MKCoordinateRegion(
//        center: CLLocationCoordinate2D(latitude: 33.6995, longitude: 73.0363),
//        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
//    )
//    @State private var selectedLocations: [MapLocation] = []
//    
//    @Environment(\.dismiss) var dismiss
//    @EnvironmentObject var navBarState: NavBarState
//    
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 20) {
//                // Name Section (existing)
//                Text("Name")
//                    .font(.headline)
//                HStack {
//                    TextField("Name", text: $nameInput)
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                    Button(action: {
//                        if !nameInput.isEmpty && !selectedNames.contains(nameInput) {
//                            selectedNames.append(nameInput)
//                            nameInput = ""
//                        }
//                    }) {
//                        Image(systemName: "checkmark.circle.fill")
//                            .foregroundColor(Defs.seeGreenColor)
//                            .font(.title)
//                    }
//                }
//                
//                // Selected Names (existing)
////                ScrollView(.horizontal) {
////                    HStack {
////                        ForEach(selectedNames, id: \.self) { name in
////                            // ... existing name chip view ...
////                        }
////                    }
////                }
//                
//                ScrollView(.horizontal) {
//                    HStack {
//                        ForEach(selectedNames, id: \.self) { name in
//                            HStack {
//                                Text(name)
//                                    .padding(.horizontal, 8)
//                                    .padding(.vertical, 4)
//                                    .background(Color.gray.opacity(0.2)).foregroundColor(Color.white)
//                                    .cornerRadius(12)
//                                Button(action: {
//                                    // Logic to remove name from the list
//                                    selectedNames.removeAll { $0 == name }
//                                }) {
//                                    Image(systemName: "xmark")
//                                        .foregroundColor(.white)
//                                }
//                            }.frame(width:120, height:35).background(Defs.seeGreenColor).cornerRadius(25)
//                        }
//                    }
//                }
//                
//                // Gender Section (existing)
//                Text("Gender")
//                    .font(.headline)
//                HStack {
//                    RadioButton(selectedText: $selectedGender, text: "Male")
//                    RadioButton(selectedText: $selectedGender, text: "Female")
//                }
//                
//                // Event Section (existing)
//                Text("Event")
//                    .font(.headline)
//                ForEach(events, id: \.self) { event in
//                    HStack {
//                        Toggle(isOn: Binding(
//                            get: { selectedEvents.contains(event) },
//                            set: { isSelected in
//                                if isSelected {
//                                    selectedEvents.append(event)
//                                } else {
//                                    selectedEvents.removeAll { $0 == event }
//                                }
//                            }
//                        )) {
//                            Text(event)
//                        }
//                    }
//                }
//                
//                // Date Section (updated to use Date instead of String)
//                Text("Capture Date")
//                    .font(.headline)
//                HStack {
//                    DatePicker("", selection: $captureDate, displayedComponents: .date)
//                        .labelsHidden()
//                    Button(action: {
//                        if !selectedDates.contains(captureDate) {
//                            selectedDates.append(captureDate)
//                        }
//                    }) {
//                        Image(systemName: "checkmark.circle.fill")
//                            .foregroundColor(Defs.seeGreenColor)
//                            .font(.title)
//                    }
//                }
//                
//                // Selected Dates (updated)
//                ScrollView(.horizontal) {
//                    HStack {
//                        ForEach(selectedDates, id: \.self) { date in
//                            let formattedDate = date.formatted(date: .numeric, time: .omitted)
//                            HStack {
//                                Text(formattedDate)
//                                    .padding(.horizontal, 8)
//                                    .padding(.vertical, 4)
//                                    .background(Color.gray.opacity(0.2)).foregroundColor(Color.white)
//                                    .cornerRadius(12)
//                                Button(action: {
//                                    // Logic to remove date from the list
//                                    selectedDates.removeAll { $0 == formattedDate }
//                                }) {
//                                    Image(systemName: "xmark")
//                                        .foregroundColor(.white)
//                                }
//                            }.frame(width:150, height:35).background(Defs.seeGreenColor).cornerRadius(25)
//                        }
//                    }
//                }
//                
//                // NEW: Location Name Section
//                Text("Location Name")
//                    .font(.headline)
//                HStack {
//                    TextField("Location Name", text: $locationNameInput)
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                    Button(action: {
//                        if !locationNameInput.isEmpty && !selectedLocationNames.contains(locationNameInput) {
//                            selectedLocationNames.append(locationNameInput)
//                            locationNameInput = ""
//                        }
//                    }) {
//                        Image(systemName: "checkmark.circle.fill")
//                            .foregroundColor(Defs.seeGreenColor)
//                            .font(.title)
//                    }
//                }
//                
//                // Selected Location Names
//                ScrollView(.horizontal) {
//                    HStack {
//                        ForEach(selectedLocationNames, id: \.self) { name in
//                            HStack {
//                                Text(name)
//                                    .padding(.horizontal, 8)
//                                    .padding(.vertical, 4)
//                                    .background(Color.gray.opacity(0.2)).foregroundColor(Color.white)
//                                    .cornerRadius(12)
//                                Button(action: {
//                                    // Logic to remove name from the list
//                                    selectedLocationNames.removeAll { $0 == name }
//                                }) {
//                                    Image(systemName: "xmark")
//                                        .foregroundColor(.white)
//                                }
//                            }.frame(width:120, height:35).background(Defs.seeGreenColor).cornerRadius(25)
//                        }
//                    }
//                }
//                
//                // Map Section (existing)
//                Text("Location Coordinates")
//                    .font(.headline)
//                Text("Tap on the map to select a location")
//                    .font(.subheadline)
//                
//                Map(coordinateRegion: $region, interactionModes: .all, annotationItems: selectedLocations) { location in
//                    MapMarker(coordinate: location.coordinate, tint: .red)
//                }
//                .frame(height: 300)
//                .cornerRadius(12)
//                .padding(.horizontal)
//                .onTapGesture { location in
//                    let coordinate = convertTapToCoordinate(location: location, in: region)
//                    let newLocation = MapLocation(coordinate: coordinate)
//                    selectedLocations = [newLocation]
//                }
//                
//                if let lastLocation = selectedLocations.last {
//                    Text("Latitude: \(lastLocation.coordinate.latitude), Longitude: \(lastLocation.coordinate.longitude)")
//                        .font(.caption)
//                }
//                
//                // Search Button
//                ButtonComponent(title: "Search", action: performSearch)
//                    .padding(.leading, 100)
//                
//                // Results Section
//                if viewModel.isLoading {
//                    ProgressView()
//                        .padding()
//                } else if let error = viewModel.error {
//                    Text("Error: \(error.localizedDescription)")
//                        .foregroundColor(.red)
//                        .padding()
//                } else if let results = viewModel.searchResults {
//                    if results.isEmpty {
//                        Text("No results found")
//                            .padding()
//                    } else {
//                        Text("Found \(results.count) results")
//                            .font(.headline)
//                            .padding(.top)
//                        
//                        // Display results in a simple list
//                        ForEach(results.prefix(5)) { image in
//                            Text(image.path)
//                        }
//                    }
//                }
//            }
//            .padding()
//        }
//        .onAppear {
//            navBarState.isHidden = true
//        }
//        .onDisappear {
//            navBarState.isHidden = false
//        }
//    }
//    
//    private func performSearch() {
//        let genders = selectedGender.isEmpty ? [] : [selectedGender]
//        viewModel.performSearch(
//            personNames: selectedNames,
//            genders: genders,
//            eventNames: selectedEvents,
//            dates: selectedDates,
//            locationNames: selectedLocationNames,
//            coordinates: selectedLocations.map { $0.coordinate },
//            dateSearchType: .day
//        )
//    }
//}















import SwiftUI
import MapKit

struct SearchView: View {
    // MARK: - State Properties
    @StateObject private var viewModel = SearchModelView()
    @State private var nameInput = ""
    @State private var selectedNames: [String] = []
    @State private var selectedGender: String = ""
    @State private var selectedEvents: [String] = []
    @State private var selectedDates: [Date] = []
    @State private var captureDate = Date()
    @State private var events = ["Birthday Party", "Eid", "Conference", "Independence Day"]
    @State private var locationNameInput = ""
    @State private var selectedLocationNames: [String] = []
    @State private var navigateToPicturesView = false
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 33.6995, longitude: 73.0363),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var selectedLocations: [MapLocation] = []
    
    // MARK: - Environment Properties
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var navBarState: NavBarState
    
    // MARK: - Main View
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                nameSection
                genderSection
                eventSection
                dateSection
                locationNameSection
                mapSection
                searchButton
                resultsSection
            }
            .padding()
        }
        .onAppear {
            navBarState.isHidden = true
        }
        .onDisappear {
            navBarState.isHidden = false
        }
        .navigationDestination(isPresented: $navigateToPicturesView) {
            if let results = viewModel.searchResults {
                PicturesView(screenName: "Search Results", images: results)
            }
        }
    }
    
    // MARK: - View Components
    
    // Name Section
    private var nameSection: some View {
        VStack(alignment: .leading) {
            SectionHeader("Name")
            HStack {
                TextField("Name", text: $nameInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                addButton(action: addName)
            }
            selectedItemsView(items: selectedNames, removeAction: removeName)
        }
    }
    
    // Gender Section
    private var genderSection: some View {
        VStack(alignment: .leading) {
            SectionHeader("Gender")
            HStack {
                RadioButton(selectedText: $selectedGender, text: "Male")
                RadioButton(selectedText: $selectedGender, text: "Female")
            }
        }
    }
    
    // Event Section
    private var eventSection: some View {
        VStack(alignment: .leading) {
            SectionHeader("Event")
            ForEach(events, id: \.self) { event in
                HStack {
                    Toggle(isOn: bindingForEvent(event)) {
                        Text(event)
                    }
                }
            }
        }
    }
    
    // Date Section
    private var dateSection: some View {
        VStack(alignment: .leading) {
            SectionHeader("Capture Date")
            HStack {
                DatePicker("", selection: $captureDate, displayedComponents: .date)
                    .labelsHidden()
                addButton(action: addDate)
            }
            selectedItemsView(items: selectedDates.map { $0.formatted(date: .numeric, time: .omitted) }, removeAction: { dateString in
                if let index = selectedDates.firstIndex(where: { $0.formatted(date: .numeric, time: .omitted) == dateString }) {
                    selectedDates.remove(at: index)
                }
            })
        }
    }
    
    // Location Name Section
    private var locationNameSection: some View {
        VStack(alignment: .leading) {
            SectionHeader("Location Name")
            HStack {
                TextField("Location Name", text: $locationNameInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                addButton(action: addLocationName)
            }
            selectedItemsView(items: selectedLocationNames, removeAction: removeLocationName)
        }
    }
    
    // Map Section
    private var mapSection: some View {
        VStack(alignment: .leading) {
            SectionHeader("Location Coordinates")
            Text("Tap on the map to select a location")
                .font(.subheadline)
            
            Map(coordinateRegion: $region, interactionModes: .all, annotationItems: selectedLocations) { location in
                MapMarker(coordinate: location.coordinate, tint: .red)
            }
            .frame(height: 300)
            .cornerRadius(12)
            .padding(.horizontal)
            .onTapGesture { location in
                let coordinate = convertTapToCoordinate(location: location, in: region)
                let newLocation = MapLocation(coordinate: coordinate)
                selectedLocations = [newLocation]
            }
            
            if let lastLocation = selectedLocations.last {
                Text("Latitude: \(lastLocation.coordinate.latitude), Longitude: \(lastLocation.coordinate.longitude)")
                    .font(.caption)
            }
        }
    }
    
    // Search Button
    private var searchButton: some View {
        ButtonComponent(title: "Search", action: performSearch)
            .padding(.leading, 100)
    }
    
    // Results Section
    private var resultsSection: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .padding()
            } else if let error = viewModel.error {
                Text("\(error.localizedDescription)")
                    .foregroundColor(.red)
                    .padding()
            } else if let results = viewModel.searchResults {
                if results.isEmpty {
                    Text("No results found")
                        .padding()
                } else {
                    // Empty view since we'll navigate automatically
                    EmptyView()
                }
//                } else {
//                    VStack(alignment: .leading) {
//                        Text("Found \(results.count) results")
//                            .font(.headline)
//                            .padding(.top)
//                        
//                        // Display results in a simple list
//                        ForEach(results.prefix(5)) { image in
//                            Text(image.path)
//                        }
//                    }
//                }
            }
        }.onChange(of: viewModel.searchResults) { newResults in
            // Automatically navigate when results are found
            if let results = newResults, !results.isEmpty {
                navigateToPicturesView = true
            }
        }
    }
    
    // MARK: - Helper Views
    
    private func SectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.headline)
    }
    
    private func addButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(Defs.seeGreenColor)
                .font(.title)
        }
    }
    
    private func selectedItemsView(items: [String], removeAction: @escaping (String) -> Void) -> some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(items, id: \.self) { item in
                    HStack {
                        Text(item)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(Color.white)
                            .cornerRadius(12)
                        Button(action: { removeAction(item) }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.white)
                        }
                    }
                    .frame(width: 120, height: 35)
                    .background(Defs.seeGreenColor)
                    .cornerRadius(25)
                }
            }
        }
    }
    
    // MARK: - Action Methods
    
    private func addName() {
        if !nameInput.isEmpty && !selectedNames.contains(nameInput) {
            selectedNames.append(nameInput)
            nameInput = ""
        }
    }
    
    private func removeName(_ name: String) {
        selectedNames.removeAll { $0 == name }
    }
    
    private func addDate() {
        if !selectedDates.contains(where: { Calendar.current.isDate($0, inSameDayAs: captureDate) }) {
            selectedDates.append(captureDate)
        }
    }
    
    private func addLocationName() {
        if !locationNameInput.isEmpty && !selectedLocationNames.contains(locationNameInput) {
            selectedLocationNames.append(locationNameInput)
            locationNameInput = ""
        }
    }
    
    private func removeLocationName(_ name: String) {
        selectedLocationNames.removeAll { $0 == name }
    }
    
    private func bindingForEvent(_ event: String) -> Binding<Bool> {
        Binding(
            get: { selectedEvents.contains(event) },
            set: { isSelected in
                if isSelected {
                    selectedEvents.append(event)
                } else {
                    selectedEvents.removeAll { $0 == event }
                }
            }
        )
    }
    
    private func performSearch() {
        let genders = selectedGender.isEmpty ? [] : [selectedGender]
        Task{
            await viewModel.performSearch(
                personNames: selectedNames,
                genders: genders,
                eventNames: selectedEvents,
                dates: selectedDates,
                locationNames: selectedLocationNames,
                coordinates: selectedLocations.map { $0.coordinate },
                dateSearchType: .day
            )
        }
    }
}












// MARK: - Identifiable Struct for Locations
struct MapLocation: Identifiable {
    let id = UUID() // Unique identifier for SwiftUI
    let coordinate: CLLocationCoordinate2D
}

// MARK: - Convert Tap to Coordinate Function
func convertTapToCoordinate(location: CGPoint, in region: MKCoordinateRegion) -> CLLocationCoordinate2D {
    let mapSize = UIScreen.main.bounds
    let lat = region.center.latitude + (Double(location.y / mapSize.height) - 0.5) * region.span.latitudeDelta
    let lon = region.center.longitude + (Double(location.x / mapSize.width) - 0.5) * region.span.longitudeDelta
    return CLLocationCoordinate2D(latitude: lat, longitude: lon)
}
