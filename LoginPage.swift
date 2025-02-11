import SwiftUI

struct LoginPage: View {
    @ObservedObject var userAuth: UserAuth
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all) // Ensures the background is black

            GeometryReader { geometry in
                VStack {
                    Spacer()
                    VStack {
                        TextField("Email", text: $email)
                            .foregroundColor(.white)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(5)

                        SecureField("Password", text: $password)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(5)

                        Button(action: {
                            userAuth.login(email: email, password: password) { error in
                                if let error = error {
                                    errorMessage = "You entered your email or password wrong, please check your information."
                                }
                            }
                        }) {
                            Text("Login")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(5)
                        }

                        if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .padding()
                        }
                    }
                    .padding()
                    Spacer()
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
}

struct LoginPage_Previews: PreviewProvider {
    static var previews: some View {
        LoginPage(userAuth: UserAuth())
    }
}
