//
//  PersonsGroupView.swift
//  photoGallery
//
//  Created by apple on 09/07/2025.
//

import SwiftUI


struct PersonsGroupView: View {
    
    @State var showTooltip: Bool = false
    @State var selectedPersons: [Personn] = []
    @State var selectedPersonId: Int? = nil
    @State var personGroups: [PersonGroup] = []
    @State var selectedImages: Set<Int> = []
    
    @State var showMoveImagesPopup = false
    @State var moveImagesData = MoveImageData()
    
    //
    @State private var selectedIndex: Int? = nil
    @EnvironmentObject var navManager: NavManager
    
    @State private var draggedPerson: Personn? = nil
    @State private var targetPerson: Personn? = nil
    @State private var showPopup = false
    
    @State private var selectedPersonGroup: PersonGroup? = nil
    
    @State private var isSelectionModeActive = false

    @State private var showShareSheet = false


    
    @StateObject var viewModel = PersonViewModel()
    
    private var gridColumns: [GridItem] {
        [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
    }

    var body: some View {
        ZStack {
            
            Group {
                if personGroups.count > 0 {
                    mainContentView
                    popupView
                    
                }
                else{
                    Text("No images to display")
                }
            }
//            mainContentView
//            popupView
        }
        .sheet(isPresented: $showShareSheet) {
            if let personGroup = selectedPersonGroup {
                ShareViewHelper(
                    images: ShareHelper.getSelectedGalleryImages(from: personGroup.images, selectedIDs: selectedImages),
                )
            }
        }
        .sheet(isPresented: $showMoveImagesPopup) {
            movePopupView
        }
        .onAppear {
            print("data Fetched", personGroups)
            selectedImages.removeAll()
            isSelectionModeActive = false
        }
    }

    //MARK: - Main content view
    private var mainContentView: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: gridColumns, spacing: 20) {
                    ForEach(personGroups, id: \.person.id) { group in
                        personGroupView(group: group)
                    }
                }
                .padding()
            }
        }
    }

    //MARK: - Person group view
    private func personGroupView(group: PersonGroup) -> some View {
        NavigationLink(
                tag: group.person.id,
                selection: $selectedIndex
            ) {
                ZStack {
                    SelectionToolbar(
                        isSelectionModeActive: $isSelectionModeActive,
                        selectedItems: $selectedImages,
                        mode: .moveAndShare,
                        onMove: {
                            if selectedImages.count > 0 {
                                selectedPersonGroup = group
                                showMoveImagesPopup = true
                                
                            }
                        },
                        onShare: {
                            print("Selected Images ------>>>>>>>>",selectedImages.count)
                            if selectedImages.count > 0 {
                                
                                selectedPersonGroup = group
                                showShareSheet = true
                            }
                        }
                    )
                    .zIndex(1)
                    Pictures1View(
                        screenName: group.person.name,
                        images: group.images,
                        isSelectionModeActive: $isSelectionModeActive,
                        selectedImageIDs: $selectedImages,
                        person: group.person
                    )
                }
            } label: {
                DraggableCardView(
                    content: "\(group.images.count)",
                    person: group.person,
                    draggedPerson: $draggedPerson,
                    targetPerson: $targetPerson,
                    showPopup: $showPopup
                ) {
                    selectedIndex = group.person.id
                    viewModel.loadLinkedPersons(personId: group.person.id)
                }
            }
            .buttonStyle(PlainButtonStyle())
    }

    // Extracted popup view
    private var popupView: some View {
        Group {
            if showPopup {
                mergePersonsPopup
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
    }

    private var mergePersonsPopup: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    withAnimation {
                        showPopup = false
                    }
                }

            VStack(spacing: 20) {
                Text("Is this the same person?")
                    .foregroundColor(.darkPurple)
                    .font(.headline)
                    .padding(.top)

                Text("By merging the photos of these two people, they will be recognized as the same person.")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .frame(height: 50)
                    .padding(.horizontal)
                
                Divider().background(.white)
                
                HStack(spacing: 16) {
                    if let dragged = draggedPerson {
                        PersonCircleImageView(imagePath: dragged.path, size: 80)
                    }

                    Image(systemName: "arrowshape.turn.up.right.fill")
                        .foregroundColor(.lightPink)
                        .font(.title)

                    if let target = targetPerson {
                        PersonCircleImageView(imagePath: target.path, size: 80)
                    }
                }

                Divider().background(.white)
                
                HStack(spacing: 30) {
                    Button(action: {
                        withAnimation {
                            showPopup = false
                        }
                    }) {
                        Text("Cancel")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 120, height: 40)
                            .background(Defs.seeGreenColor)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                    }
                    
                    Button(action: {
                        if let dragged = draggedPerson, let target = targetPerson {
                            print("merged -> person1Id: \(dragged.id), person2Id: \(target.id)")
                            viewModel.createLinkBetween(person1Id: dragged.id, person2Id: target.id)
                        }
                        withAnimation {
                            showPopup = false
                        }
                    }) {
                        Text("Merge")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 120, height: 40)
                            .background(Defs.seeGreenColor)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                    }
                }

                Spacer()
            }
            .frame(width: 380, height: 350)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 10)
            .padding()
        }
    }


    
    private var movePopupView: some View {
        
        ScrollView {
                LazyVGrid(columns: gridColumns, spacing: 20) {
                    ForEach(personGroups, id: \.person.id) { group in
                        CardView(
                            title: group.person.name,
                            content: "\(group.images.count)",
                            imagePath: group.person.path
                        )
                        .padding(.top, -10)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if let selectedGroup =  selectedPersonGroup {
                                viewModel.moveImages(destination: group.person.path, personGroup: selectedGroup)
                                showMoveImagesPopup = false
                            }
                        }
                    }
                }
                .padding()

        }
        .transition(.opacity)
    }
}



//#Preview {
//    PersonsGroupView()
//}
