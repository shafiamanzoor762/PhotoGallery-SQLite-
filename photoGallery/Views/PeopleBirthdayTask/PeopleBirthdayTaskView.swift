
import SwiftUI

struct PeopleBirthdayTaskView: View {
    @State private var selectedIndex: Int? = nil
    @EnvironmentObject var navManager: NavManager
    @StateObject var viewModel = PersonBirthdayTaskViewModel()
    
    
    
    @State private var draggedPerson: Personn? = nil
    @State private var targetPerson: Personn? = nil
    @State private var showPopup = false
    
    @State private var selectedPersonGroup: PersonGroup? = nil
    
    @State private var isSelectionModeActive = false

    @State private var showShareSheet = false
    @State var images: [GalleryImage]? = nil
    
    //new
    @State var selectedPerson: Personn? = nil
    


    private var gridColumns: [GridItem] {
        [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
    }

    var body: some View {
        ZStack {
            //
            
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
            VStack{
                HStack {
                    Text("Select Person Name")
                        .font(.headline)
                    Picker("Select Person name", selection: $viewModel.selectedPersonName) {
                        ForEach(viewModel.personNames, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding(.horizontal).foregroundStyle(Color.darkPurple)
                    .onChange(of: viewModel.selectedPersonName){
                        viewModel.getPersonGroupsByAge()
                    }
                }

                
                if(!viewModel.selectedPersonName.isEmpty){
                    
                    ScrollView {
                        
                        VStack(alignment: .leading){
                            
                            Text("Age variations for \(viewModel.selectedPersonName)")
                                    .font(.headline)
                                    .foregroundStyle(Defs.seeGreenColor)
                                
                                ForEach(viewModel.ageVariations.keys.sorted(), id:\.self){ key in
                                    let bindingKey = Binding<String>(
                                        get: { key },
                                        set: { _ in }
                                    )
                                    if let img = viewModel.ageVariations[bindingKey.wrappedValue] {
                                        
                                        NavigationLink(destination: PicturesView(screenName: viewModel.selectedPersonName, person: viewModel.selectedPerson, images:  img)) {
                                            HStack {
                                                Image(systemName: "person.circle")
                                                    .font(.largeTitle)
                                                    .foregroundStyle(Defs.lightPink)
                                                Text("\(key)")
                                                    .foregroundStyle(.black)
                                                    .font(.headline)
                                                
                                                Spacer()
                                                
                                                Image(systemName: "chevron.forward.circle.fill")
                                                    .font(.largeTitle)
                                                    .foregroundStyle(Defs.seeGreenColor)
                                            }
                                            .padding()
                                            .background(Defs.lightSeeGreenColor.opacity(0.5))
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                            
                                        }
                                    }
                                    
                                }
                                
                                
                                //Event Age Variations
                                
                                Text("Event age variations for \(viewModel.selectedPersonName)")
                                    .font(.headline)
                                    .foregroundStyle(Defs.seeGreenColor)
                            ForEach(viewModel.eventAgeVariations.keys.sorted(), id:\.self){ key in
                                let bindingKey = Binding<String>(
                                    get: { key },
                                    set: { _ in }
                                )
                                
                                if let img = viewModel.eventAgeVariations[bindingKey.wrappedValue] {
                                    
                                    NavigationLink(destination: PicturesView(screenName: viewModel.selectedPersonName, person: viewModel.selectedPerson, images:  img)) {
                                        HStack {
                                            Image(systemName: "party.popper.fill")
                                                .font(.largeTitle)
                                                .foregroundStyle(Defs.lightPink)
                                            Text("\(key)")
                                                .foregroundStyle(.black)
                                                .font(.headline)
                                            
                                            Spacer()
                                            
                                            Image(systemName: "chevron.forward.circle.fill")
                                                .font(.largeTitle)
                                                .foregroundStyle(Defs.seeGreenColor)
                                        }
                                        .padding()
                                        .background(Defs.lightSeeGreenColor.opacity(0.4))
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                }
                            }
                        }
                        
                    }
                    .padding(.horizontal)
                    .padding(.bottom,110)
                } else {
                    Text("No person name selected yet. Please select person name.")
                        .font(.headline)

                }
                Spacer()
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

