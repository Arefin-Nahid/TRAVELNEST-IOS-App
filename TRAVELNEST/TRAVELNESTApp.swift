import SwiftUI
import FirebaseCore

@main
struct TRAVELNESTApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            SplashScreen()
        }
    }
}
