//
//  FilteredResultsView.swift
//  photoGallery
//
//  Created by apple on 23/06/2025.
//

import SwiftUI

struct FilteredResultsView: View {
    let initialResults: [GalleryImage]
    @StateObject private var viewModel = SearchModelView()
    
    @State private var selectedFilter: String = "Show Images"
//    @State private var personVM: PersonViewModel = PersonViewModel()
    @State var personGroups: [PersonGroup] = []
    @State private var eventGroups: [String: [GalleryImage]] = [:]
    @State private var eventDateGroups: [String: [GalleryImage]] = [:]
    @State private var locationGroups: [String: [GalleryImage]] = [:]
    
    private let filterOptions = ["Show Images", "By People", "By Location", "By Event", "By Date"]
    
    var body: some View {
        VStack {
            // Filter Tabs
            filterTabs
            
            Divider()
            
            // Content View
            contentView
        }
        .onAppear {
            // Preload all filter data when view appears
            loadAllFilterData()
        }
//        .onChange(of: selectedFilter) { newValue in
//            loadAllFilterData() // if needed on each tab change
//        }
    }
    
    private var filterTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(filterOptions, id: \.self) { filter in
                    Text(filter)
                        .fontWeight(.medium)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            selectedFilter == filter ? Defs.lightPink : Defs.lightSeeGreenColor.opacity(0.5)
                        )
                        .foregroundColor(selectedFilter == filter ? .white : Defs.seeGreenColor)
                        .clipShape(Capsule())
                        .onTapGesture {
                            selectedFilter = filter
                        }
                }
            }
            .padding(.horizontal)
            .padding(.top)
        }
        //.background(Defs.seeGreenColor)
    }
    
    @ViewBuilder
    private var contentView: some View {
        switch selectedFilter {
        case "By People":
                return AnyView(PersonsGroupView(personGroups: personGroups))
        case "By Location":
                return AnyView(LocationGroupsView(groupedImages: locationGroups))
        case "By Event":
                return AnyView(EventGroupsView(groupedImages: eventGroups))
        case "By Date":
                return AnyView(DateGroupsView(groupedImages: eventDateGroups))
        default:
                return AnyView(
                    NavigationStack {
                        PicturesView(screenName: "Search Results", images: initialResults)
                    }
                )
        }
    }
    
    private func loadAllFilterData() {
        // Load all filter data upfront
        personGroups = viewModel.groupImagesByPerson(initialResults)
        eventGroups = viewModel.groupImagesByEvent(initialResults)
        eventDateGroups = viewModel.groupImagesByEventDate(initialResults)
        locationGroups = viewModel.groupImagesByLocation(initialResults)
    }
    

}
