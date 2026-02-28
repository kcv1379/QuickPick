import SwiftUI

@main
struct QuickPickApp: App {
    @Environment(\.scenePhase) private var scenePhase
    var body: some Scene {
        WindowGroup {

            //temp root
            LoginView(
                onLogin: { username, password in
                    //hussan: navigate to MovieFeedView
                    print("Login tapped: \(username), \(password)")
                },
                onCreateAccount: {
                    //hussan: navigate to CreateAccountView
                    print("Create account tapped")
                }
            )
            .accentColor(.white)
        }
        .onChange(of: scenePhase) { _, newValue in
            switch newValue {
            case .active:
                print("Lifecycle: App onResume")
            case .inactive:
                print("Lifecycle: App onPause")
            case .background:
                print("Lifecycle: App onStop")
            @unknown default:
                break
            }
        }
    }
}
