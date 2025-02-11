import SwiftUI
import Firebase

class UserAuth: ObservableObject {
    @Published var isLoggedIn: Bool = false

    init() {
        self.isLoggedIn = Auth.auth().currentUser != nil || UserDefaults.standard.bool(forKey: "isLoggedIn")
    }

    func login(email: String, password: String, completion: @escaping (String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(error.localizedDescription)
            } else {
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                self.isLoggedIn = true
                completion(nil)
            }
        }
    }

    func logout() {
        do {
            try Auth.auth().signOut()
            UserDefaults.standard.set(false, forKey: "isLoggedIn")
            APIManager().clearApiKey()
            self.isLoggedIn = false
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}
