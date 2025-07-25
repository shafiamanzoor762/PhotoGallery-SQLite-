
import SwiftUI

struct PersonView: View {
    @State private var selectedIndex: Int? = nil
    @EnvironmentObject var navManager: NavManager
    @StateObject var viewModel = PersonViewModel()
    
    @State private var draggedPerson: Personn? = nil
    @State private var targetPerson: Personn? = nil
    @State private var showPopup = false
    
    @State private var selectedPersonGroup: PersonGroup? = nil
    
    @State private var isSelectionModeActive = false

    @State private var showShareSheet = false


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
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                } else if viewModel.error != nil {
                    errorView
                } else {
                    mainContentView
                    popupView
                    
                }
            }
//            mainContentView
//            popupView
        }
        .sheet(isPresented: $showShareSheet) {
            if let personGroup = selectedPersonGroup {
                ShareViewHelper(
                    images: ShareHelper.getSelectedGalleryImages(from: personGroup.images, selectedIDs: viewModel.selectedImages),
                )
            }
        }
        .sheet(isPresented: $viewModel.showMoveImagesPopup) {
            movePopupView
        }
        .onAppear {
            viewModel.fetchData()
            print("data Fetched", viewModel.personGroups)
            viewModel.selectedImages.removeAll()
            isSelectionModeActive = false
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: viewModel.refresh) {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
    }

    //MARK: - Main content view
    private var mainContentView: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: gridColumns, spacing: 20) {
                    ForEach(viewModel.personGroups, id: \.person.id) { group in
                        personGroupView(group: group)
                    }
                }
                .padding(.top)
                .padding(.bottom,100)
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
                        selectedItems: $viewModel.selectedImages,
                        mode: .moveAndShare,
                        onMove: {
                            if viewModel.selectedImages.count > 0 {
                                selectedPersonGroup = group
                                viewModel.showMoveImagesPopup = true
                                
                            }
                        },
                        onShare: {
                            print("Selected Images ------>>>>>>>>",viewModel.selectedImages.count)
                            if viewModel.selectedImages.count > 0 {
                                
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
                        selectedImageIDs: $viewModel.selectedImages,
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
                    ForEach(viewModel.personGroups, id: \.person.id) { group in
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
                                viewModel.showMoveImagesPopup = false
                            }
                        }
                    }
                }
                .padding()

        }
        .transition(.opacity)
    }
    
    private var errorView: some View {
        VStack {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.red)
            Text("Error loading people")
                .font(.title2)
            Text(viewModel.error?.localizedDescription ?? "Unknown error")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding()
            
            Button("Retry") {
                viewModel.fetchData()
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
    }
}


struct DraggableCardView: View {
    var content: String
    let person: Personn
    @Binding var draggedPerson: Personn?
    @Binding var targetPerson: Personn?
    @Binding var showPopup: Bool
    var onTap: () -> Void

    var body: some View {
        CardView(
            title: person.name,
            content: content,
            imagePath: person.path
        )
        .padding(.top, -10)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
        .onDrag {
            // Only set the dragged person when dragging starts
            self.draggedPerson = person
            return NSItemProvider(object: NSString(string: String(person.id)))
        }
        .onDrop(of: [.text], delegate: DropViewDelegate(
            currentPerson: person,
            draggedPerson: $draggedPerson,
            targetPerson: $targetPerson,
            showPopup: $showPopup
        ))
    }
}

struct DropViewDelegate: DropDelegate {
    let currentPerson: Personn  // This is the drop target
    @Binding var draggedPerson: Personn?
    @Binding var targetPerson: Personn?
    @Binding var showPopup: Bool

    func performDrop(info: DropInfo) -> Bool {
        guard let dragged = draggedPerson else { return false }
        
        // Only proceed if dragging a different person onto this one
        if dragged.id != currentPerson.id {
            targetPerson = currentPerson  // Set the drop target
            showPopup = true
            return true
        }
        return false
    }
    
}
