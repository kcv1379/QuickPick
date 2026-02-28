import SwiftUI

@main
struct QuickPickApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var screen = "login"
    var body: some Scene {
        WindowGroup {
            if screen == "login" {
            //temp root
            LoginView(
                onLogin: { username, password in
                    print("Login tapped: \(username), \(password)")
                    // switch to feed
                    screen = "feed"
                },
                onCreateAccount: {
                    print("Create account tapped")
                    screen = "create"
                }
            )
            } else if screen == "create" {
                CreateAccountView(
                    onCreateAccount: { username, password, region in
                        print("Account created: \(username), \(region)")
                        screen = "feed"
                },
                onBack: {
                    screen = "login"
                }
                )
            }else { MovieFeedView(
                        onOpenSettings: {},
                        onOpenDetails: { _ in }
                )
            }
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
