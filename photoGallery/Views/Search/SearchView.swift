//
//  SearchView.swift
//  ComponentsApp
//
//  Created by apple on 24/11/2024.
//

import SwiftUI
import MapKit

enum DateFilterType: String, CaseIterable, Identifiable {
    case day = "Day"
    case month = "Month"
    case year = "Year"
    case complete = "Complete Date"
    
    var id: String { self.rawValue }
}


struct SearchView: View {
    // MARK: - State Properties
    @StateObject private var viewModel = SearchModelView()
    @State private var nameInput = ""
    @State private var ageInput = ""
    @State private var selectedNames: [String] = []
    //@State private var selectedAges: [String] = []
    @State private var selectedEvents: [String] = []
    
    @State private var selectedEventDates: [Date] = []
    @State private var eventDate = Date()
    
    @State private var selectedCaptureDates: [Date] = []
    @State private var captureDate = Date()
    
    @State private var selectedCaptureDates1: [Date] = []
    @State private var captureDate1 = Date()
    @State private var filterType: DateFilterType = .day
    
    @State private var events = [Eventt]()
    @State private var locationNameInput = ""
    @State private var selectedLocationNames: [String] = []


    
    @State private var navigateToPicturesView = false
    @State private var showSuggestions = false
    
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
                    .padding()
                ageSection
                genderSection
                eventSection
                eventDateSection
                captureDateSection
                captureDateSectionByDayMonthYear
                locationNameSection
//                mapSection
                searchButton
                resultsSection
            }
            .padding()
        }
        .onAppear {
            navBarState.isHidden = true
            events = viewModel.getAllEvents()
        }
        .onDisappear {
            navBarState.isHidden = false
        }
//        .navigationDestination(isPresented: $navigateToPicturesView) {
//            if let results = viewModel.searchResults {
//                PicturesView(screenName: "Search Results", images: results)
//            }
//        }
        
        .sheet(isPresented: $navigateToPicturesView) {
            if let results = viewModel.searchResults {
                FilteredResultsView(initialResults: results)
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
                    .onChange(of: nameInput) { newValue in
                                        if newValue.count >= 2 {
                                            viewModel.fetchNameSuggestions(searchTerm: newValue)
                                            showSuggestions = true
                                        } else {
                                            showSuggestions = false
                                            viewModel.nameSuggestions = []
                                        }
                                    }
                                
                                if showSuggestions && !viewModel.nameSuggestions.isEmpty {
                                    List(viewModel.nameSuggestions, id: \.self) { suggestion in
                                        Text(suggestion)
                                            .onTapGesture {
                                                nameInput = suggestion
                                                showSuggestions = false
                                            }
                                    }
                                    .frame(height: min(CGFloat(viewModel.nameSuggestions.count) * 44, 200))
                                    .listStyle(PlainListStyle())
                                }
                addButton(action: addName)
            }
            selectedItemsView(items: selectedNames, removeAction: removeName)
        }
    }
    
    private var ageSection: some View {
        VStack(alignment: .leading) {
            SectionHeader("Age")
            HStack {
                TextField("Age", text: $ageInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                addButton(action: addAge)
            }
//            selectedItemsView(items: selectedAges, removeAction: removeAge)
        }
    }
    
    // Gender Section
    private var genderSection: some View {
        VStack(alignment: .leading) {
            SectionHeader("Gender")
            HStack {
                RadioButton(selectedText: Binding(
                    get: { viewModel.selectedGender },
                    set: { newValue in
                        if !viewModel.selectedGender.isEmpty {
                            viewModel.selectedGender = newValue
                        }
                    }
                ).genderBinding(), text: "Male")
                
//                RadioButton(
//                    selectedText: Binding(
//                        get: { viewModel.selectedGender },
//                        set: { newValue in
//                            if !viewModel.selectedGender.isEmpty {
//                                viewModel.selectedGender = newValue
//                            }
//                        }
//                    ).genderBinding(),
//                    text: "Female"
//                )
                
                RadioButton(selectedText: $viewModel.selectedGender.genderBinding(), text: "Female")
                
                RadioButton(selectedText: $viewModel.selectedGender, text: "Both")
                RadioButton(selectedText: $viewModel.selectedGender, text: "Other")
                RadioButton(selectedText: $viewModel.selectedGender, text: "All")
            }
        }
    }
    
    // Event Section
    private var eventSection: some View {
        VStack(alignment: .leading) {
            SectionHeader("Event")

            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(events, id: \.self.id) { event in
                        HStack {
                            Toggle(isOn: bindingForEvent(event.name)) {
                                Text(event.name)
                            }
                        }
                    }
                }
            }
            .frame(height: 100)
        }
    }

    
    // Date Section
    private var eventDateSection: some View {
        VStack(alignment: .leading) {
            SectionHeader("Event Date")
            HStack {
                DatePicker("", selection: $eventDate, displayedComponents: .date)
                    .labelsHidden()
                addButton(action: addEventDate)
            }
            selectedItemsView(items: selectedEventDates.map { $0.formatted(date: .numeric, time: .omitted) }, removeAction: { dateString in
                if let index = selectedEventDates.firstIndex(where: { $0.formatted(date: .numeric, time: .omitted) == dateString }) {
                    selectedEventDates.remove(at: index)
                }
            })
        }
    }
    
    private var captureDateSection: some View {
        VStack(alignment: .leading) {
            SectionHeader("Capture Date")
            HStack {
                DatePicker("", selection: $captureDate, displayedComponents: .date)
                    .labelsHidden()
                addButton(action: addCaptureDate)
            }
            selectedItemsView(items: selectedCaptureDates.map { $0.formatted(date: .numeric, time: .omitted) }, removeAction: { dateString in
                if let index = selectedCaptureDates.firstIndex(where: { $0.formatted(date: .numeric, time: .omitted) == dateString }) {
                    selectedCaptureDates.remove(at: index)
                }
            })
        }
    }
    
    private var captureDateSectionByDayMonthYear: some View {
        VStack(alignment: .leading) {
            SectionHeader("Capture Date")

            // Filter Picker
            Picker("Filter", selection: $filterType) {
                ForEach(DateFilterType.allCases) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(SegmentedPickerStyle())

            HStack {
                DatePicker("", selection: $captureDate1, displayedComponents: .date)
                    .labelsHidden()

                addButton(action: addCaptureDate1)
            }

            selectedItemsView(items: selectedCaptureDates1.map { formatDate($0, as: filterType) }, removeAction: { dateString in
                if let index = selectedCaptureDates1.firstIndex(where: { formatDate($0, as: filterType) == dateString }) {
                    selectedCaptureDates1.remove(at: index)
                }
            })
        }
    }
    
//    func formatDate(_ date: Date, as filter: DateFilterType) -> String {
//        let formatter = DateFormatter()
//        switch filter {
//        case .day:
//            formatter.dateFormat = "EEEE" // Full weekday name
//        case .month:
//            formatter.dateFormat = "MMMM" // Full month name
//        case .year:
//            formatter.dateFormat = "yyyy" // Year
//        }
//        return formatter.string(from: date)
//    }
    
    func formatDate(_ date: Date, as filter: DateFilterType) -> String {
        let formatter = DateFormatter()
        switch filter {
        case .day:
            formatter.dateFormat = "EEEE"        // e.g., "Tuesday"
        case .month:
            formatter.dateFormat = "MMMM"        // e.g., "July"
        case .year:
            formatter.dateFormat = "yyyy"        // e.g., "2025"
        case .complete:
            formatter.dateFormat = "yyyy-MM-dd"  // e.g., "2025-07-08"
        }
        return formatter.string(from: date)
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
//    private var mapSection: some View {
//        VStack(alignment: .leading) {
//            SectionHeader("Location Coordinates")
//            Text("Tap on the map to select a location")
//                .font(.subheadline)
//            
//            Map(coordinateRegion: $region, interactionModes: .all, annotationItems: selectedLocations) { location in
//                MapMarker(coordinate: location.coordinate, tint: .red)
//            }
//            .frame(height: 300)
//            .cornerRadius(12)
//            .padding(.horizontal)
//            .onTapGesture { location in
//                let coordinate = convertTapToCoordinate(location: location, in: region)
//                let newLocation = MapLocation(coordinate: coordinate)
//                selectedLocations = [newLocation]
//            }
//            
//            if let lastLocation = selectedLocations.last {
//                Text("Latitude: \(lastLocation.coordinate.latitude), Longitude: \(lastLocation.coordinate.longitude)")
//                    .font(.caption)
//            }
//        }
//    }
    
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
    
    private func addAge() {
        if !nameInput.isEmpty && !selectedNames.contains(nameInput) {
            selectedNames.append(nameInput)
            nameInput = ""
        }
    }
    
    private func removeAge(_ name: String) {
        selectedNames.removeAll { $0 == name }
    }
    
    private func addEventDate() {
        if !selectedEventDates.contains(where: { Calendar.current.isDate($0, inSameDayAs: eventDate) }) {
            selectedEventDates.append(eventDate)
        }
    }
    
    private func addCaptureDate() {
        if !selectedCaptureDates.contains(where: { Calendar.current.isDate($0, inSameDayAs: captureDate) }) {
            selectedCaptureDates.append(captureDate)
        }
    }
    
    private func addCaptureDate1() {
        if !selectedCaptureDates1.contains(where: { Calendar.current.isDate($0, inSameDayAs: captureDate1) }) {
            selectedCaptureDates1.append(captureDate1)
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
        
        var genders = [viewModel.selectedGender]
        
        if viewModel.selectedGender == "Both" {
            genders = ["M","F"]
        }
        else if viewModel.selectedGender == "All" {
            genders = ["M","F","U"]
        }
        else if viewModel.selectedGender == "Other" {
            genders = ["U"]
        }

//        let genders = viewModel.selectedGender == "All" ? ["M,F,U"] : [viewModel.selectedGender]
        
        let formattedDates = selectedCaptureDates1.map { formatDate($0, as: filterType) }

        Task{
            //print(genders)
            await viewModel.performSearch(
                personNames: selectedNames,
                age: Int(ageInput) ?? 0,
                genders: genders,
                eventNames: selectedEvents,
                eventDates: selectedEventDates,
                captureDates: selectedCaptureDates,
                formatedDates: formattedDates,
                locationNames: selectedLocationNames,
                coordinates: selectedLocations.map { $0.coordinate },
                dateSearchType: filterType
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
