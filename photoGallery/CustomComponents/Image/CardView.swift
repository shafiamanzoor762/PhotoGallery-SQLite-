import SwiftUI

struct CardView: View {
    var title: String
    var content: String
    let imagePath: String
    
    var body: some View {

            ZStack(alignment: .leading) {
                Rectangle()
                    //.foregroundStyle(Color(red: 132/255, green: 197/255, blue: 205/255))
                    .foregroundStyle(Defs.lightSeeGreenColor)
                    .cornerRadius(15)
                
                VStack {
                    
                    PersonCircleImageView(imagePath: imagePath, size: 80)
                    
                    VStack(alignment: .leading){
                        Text(title)
                            .font(.subheadline)
                            .foregroundColor(Color.black)
                            //.frame(width: 130, alignment: .leading)
                            //.padding(.top, -8)
                            //.padding(.leading, 25)

                        Text(content)
                            .foregroundColor(.white)
                            .font(.body)
                            //.frame(width: 100, alignment: .leading).padding(.top, -25)
                    }.frame(width:110, alignment: .leading)
                    
                }.frame(width: 120)
                
            }.frame(width: 120, height: 135).padding(.vertical, 7)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.gray, lineWidth: 1)
                )
    }
}


struct PersonCircleImageView: View {
    @State var imagePath: String
    @State var size: CGFloat
    @State private var faceImage: UIImage?
    
    var body: some View {
        Group {
            if let image = faceImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size, height: size)
                    .cornerRadius(size)
                
                    .overlay(
                        RoundedRectangle(cornerRadius: size)
                            .stroke(Color.black, lineWidth: 1)
                    )
                    .padding(.top, 10)
            }  else {
                // Placeholder while loading
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size, height: size)
                    .cornerRadius(size)
                
                    .overlay(
                        RoundedRectangle(cornerRadius: size)
                            .stroke(Color.black, lineWidth: 1)
                    )
                    .onAppear {
                        loadFaceImage()
                    }
            }
        }
    }
    
    private func loadFaceImage() {
        ApiHandler.loadFaceImage(from: imagePath) { image in
            DispatchQueue.main.async {
                self.faceImage = image
            }
        }
    }
    
}
