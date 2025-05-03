import SwiftUI

struct ButtonComponent: View {
    var title: String
    var action: () -> Void
    @State private var pressed = false

    var body: some View {
        Button(action: action) {
            Text(title)
                .frame(width: 170, height: 20)
                .padding(10)
                .font(.system(size: 20))
                //.fontWeight(.bold)
                .foregroundColor(.white)
                
                .background(RoundedRectangle(cornerRadius: 8).foregroundColor(Defs.seeGreenColor))
                    .scaleEffect(self.pressed ? 1.2 : 1.0)
                    .cornerRadius(20).shadow(color:Color.gray,radius: 5, x: 4, y: 4)
        }
        
//            .onLongPressGesture(minimumDuration: .infinity,maximumDistance: .infinity, pressing: { pressing in withAnimation(.easeInOut(duration: 0.2)){
//                self.pressed = pressing
//            }},perform: {})
        
    }
}

struct ButtonComponent_Previews: PreviewProvider {
    static var previews: some View {
        ButtonComponent(title: "Click Me", action: {})
    }
}

