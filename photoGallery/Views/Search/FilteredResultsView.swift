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
    @State private var personVM: PersonViewModel = PersonViewModel()
    @State private var eventVM: EventViewModel = EventViewModel()
    @State private var dateVM: DateViewModel = DateViewModel()
    @State private var locationVM: LocationViewModel = LocationViewModel()
    
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
                return AnyView(PersonView(viewModel: personVM))
        case "By Location":
                return AnyView(LocationView(viewModel: locationVM))
        case "By Event":
                return AnyView(EventView(viewModel: eventVM))
        case "By Date":
                return AnyView(DateView(viewModel: dateVM))
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
        personVM = viewModel.groupImagesPerson(initialResults)
        eventVM = viewModel.groupImagesEvent(initialResults)
        dateVM = viewModel.groupImagesDate(initialResults)
        locationVM = viewModel.groupImagesLocation(initialResults)
    }
    

}
