import SwiftUI
import Firebase

@main
struct DMSApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var userAuth = UserAuth()

    var body: some Scene {
        WindowGroup {
            if userAuth.isLoggedIn {
                ContentView().environmentObject(userAuth)
            } else {
                LoginPage(userAuth: userAuth)
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        return true
    }
}
