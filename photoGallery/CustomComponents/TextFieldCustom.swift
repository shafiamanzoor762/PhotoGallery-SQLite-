import SwiftUI

struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String
    var systemImageString: String

    var body: some View {
        TextField(placeholder, text: $text)
            .textFieldStyle(
                GradientTextFieldBackground(
                    systemImageString: systemImageString
                )
            )
    }
}

struct GradientTextFieldBackground: TextFieldStyle {
    
    let systemImageString: String
    
    // Hidden function to conform to this protocol
    func _body(configuration: TextField<Self._Label>) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12.0)
                .stroke(
                    Color(red: 127/255, green: 85/255, blue: 57/255)
                )
                .frame(height: 40)
            
            HStack {
                Image(systemName: systemImageString)
                // Reference the TextField here
                configuration
            }
            .padding(.leading)
            .foregroundColor(.gray)
        }
    }
}
