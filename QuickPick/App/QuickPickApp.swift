import SwiftUI

@main
struct QuickPickApp: App {
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
    }
}
