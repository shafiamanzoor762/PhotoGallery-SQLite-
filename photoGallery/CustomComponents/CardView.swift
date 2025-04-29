import SwiftUI

struct CardView: View {
    var title: String
    var content: String
    var imageURL = "BabyGirl"
    
    var body: some View {

            ZStack(alignment: .leading) {
                Rectangle()
                    //.foregroundStyle(Color(red: 132/255, green: 197/255, blue: 205/255))
                    .foregroundStyle(Defs.lightSeeGreenColor)
                    .cornerRadius(15)
                
                VStack{
                    Image("\(imageURL)")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .cornerRadius(80)
                    
                        .overlay(
                            RoundedRectangle(cornerRadius: 80)
                                .stroke(Color.black, lineWidth: 1)
                        )
                        .padding(.top, 10)
                    
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

#Preview {
    CardView(title: "demo", content: "3")
}
