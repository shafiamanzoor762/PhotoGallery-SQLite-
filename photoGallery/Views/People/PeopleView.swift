
import SwiftUI

struct PeopleView: View {
    @State private var selectedIndex: Int? = nil
    @EnvironmentObject var navManager: NavManager  // Access nav state
    @State private var image = ImgesData.imagesDetail
    
    
    @State private var draggedPerson: Personn? = nil
    @State private var targetPerson: Personn? = nil
    @State private var showPopup = false

    
    let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    private func getSelectedImages() -> [ImageeDetail] {
        var images: [ImageeDetail] = []
        if image.indices.contains(5) {
            images.append(image[5])
        }
        if image.indices.contains(7) {
            images.append(image[7])
        }
        return images
    }

    var body: some View {
        let selectedImages = getSelectedImages()  // Compute outside the loop to improve performance
        
        ZStack {
            NavigationStack {
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 20) {
                        ForEach(Array(image.enumerated()), id: \.element.id) { index, img in
                            
                            NavigationLink(
                                tag: index,
                                selection: $selectedIndex
                            ) {
                                //                            PicturesView(screenName: img.persons.first?.Name ?? "Unknown", images: selectedImages)
                            } label: {
                                if img.persons.count > 0 {
                                    //                                CardView(
                                    //                                    title: img.persons.first?.Name ?? "Unknown",
                                    //                                    content: "\(index % 2 == 0 ? index + 1 : 2)",
                                    //                                    imageURL: img.persons.first?.Path ?? "p1"
                                    //                                )
                                    //
                                    //                                .padding(.top, -10)
                                    //                                .contentShape(Rectangle())
                                    //                                .onTapGesture {
                                    //                                    print("Card \(index + 1) tapped")
                                    //                                    selectedIndex = index
                                    //                                }
                                    
                                    //                                CardView(
                                    //                                    title: img.persons.first?.Name ?? "Unknown",
                                    //                                    content: "\(index % 2 == 0 ? index + 1 : 2)",
                                    //                                    imageURL: img.persons.first?.Path ?? "p1"
                                    //                                )
                                    //                                .padding(.top, -10)
                                    //                                .contentShape(Rectangle())
                                    //                                .onTapGesture {
                                    //                                    selectedIndex = index
                                    //                                }
                                    //                                .onDrag {
                                    //                                    self.draggedPerson = img.persons.first
                                    //                                    return NSItemProvider(object: NSString(string: img.persons.first?.id.uuidString ?? ""))
                                    //                                }
                                    //                                .onDrop(of: [.text], delegate: DropViewDelegate(currentPerson: img.persons.first, draggedPerson: $draggedPerson, targetPerson: $targetPerson, showPopup: $showPopup))
                                    
                                    
                                    
                                    if let person = img.persons.first {
                                        DraggableCardView(
                                            person: person,
                                            index: index,
                                            draggedPerson: $draggedPerson,
                                            targetPerson: $targetPerson,
                                            showPopup: $showPopup
                                        ) {
                                            selectedIndex = index
                                        }
                                    }
                                    
                                    
                                    
                                    
                                    
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }
            }
            
            // Show popup when needed
                    if showPopup {
                        mergePersonsPopup
                            .transition(.opacity)
                            .zIndex(1)  // Ensure it shows on top
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
                        Image(dragged.Path)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 50))
                    }

                    Image(systemName: "arrow.right")
                        .foregroundColor(.gray)
                        .font(.title)

                    if let target = targetPerson {
                        Image(target.Path)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 50))
                    }
                }

                Divider().background(.white)
                
                HStack(spacing: 30) {
//                    Button("Cancel") {
//                        withAnimation {
//                            showPopup = false
//                        }
//                    }
//                    .foregroundColor(.white)

                    
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
                        // Merge Logic
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
                    .foregroundColor(.white)
                }

                Spacer()
            }
            .frame(width: 380, height: 350)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 10)
            .padding()
            .padding(.top, 170)
        }
    }
    

}


struct DraggableCardView: View {
    let person: Personn
    let index: Int
    @Binding var draggedPerson: Personn?
    @Binding var targetPerson: Personn?
    @Binding var showPopup: Bool
    var onTap: () -> Void

    var body: some View {
        CardView(
            title: person.Name,
            content: "\(index % 2 == 0 ? index + 1 : 2)",
            imageURL: person.Path
        )
        .padding(.top, -10)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
        .onDrag {
            self.draggedPerson = person
//            return NSItemProvider(object: NSString(string: person.id.uuidString))
            return NSItemProvider(object: NSString(string: String(person.Id)))
        }
        .onDrop(of: [.text], delegate: DropViewDelegate(currentPerson: person, draggedPerson: $draggedPerson, targetPerson: $targetPerson, showPopup: $showPopup))
    }
}





struct DropViewDelegate: DropDelegate {
    let currentPerson: Personn?
    @Binding var draggedPerson: Personn?
    @Binding var targetPerson: Personn?
    @Binding var showPopup: Bool

    func performDrop(info: DropInfo) -> Bool {
        if let dragged = draggedPerson, let target = currentPerson, dragged.Id != target.Id {
            targetPerson = target
            showPopup = true
        }
        return true
    }
}
