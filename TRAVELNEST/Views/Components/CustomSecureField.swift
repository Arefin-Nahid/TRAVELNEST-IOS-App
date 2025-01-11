import SwiftUI

struct CustomSecureField: View {
    @Binding var password: String
    @Binding var isSecured: Bool
    let placeholder: String
    
    var body: some View {
        HStack {
            Image(systemName: "lock.fill")
                .foregroundColor(.white)
                .frame(width: 44)
            
            if isSecured {
                SecureField(placeholder, text: $password)
                    .foregroundColor(.white)
            } else {
                TextField(placeholder, text: $password)
                    .foregroundColor(.white)
            }
            
            Button(action: {
                isSecured.toggle()
            }) {
                Image(systemName: isSecured ? "eye.slash.fill" : "eye.fill")
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.2))
        )
    }
} 