import SwiftUI

@main
struct QuickPickApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var screen = "login"
    @State private var selectedTitle = "Jaws"
    @State private var selectedYear = "1975"

    var body: some Scene {
        WindowGroup {
            if screen == "login" {
                LoginView(
                    onLogin: { username, password in
                        print("Login tapped: \(username), \(password)")
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
                        print("Back button tapped")
                        screen = "login"
                    }
                )

            } else if screen == "settings" {
                SettingsView(
                    region: "US",
                    shakeEnabled: true,
                    onBack: {
                        screen = "feed"
                    },
                    onSave: { region, shakeEnabled in
                        print("Saved settings: \(region), shakeEnabled=\(shakeEnabled)")
                    },
                    onEditNotInterested: {
                        print("Edit not interested list tapped")
                    },
                    onLogout: {
                        print("Logout tapped")
                        screen = "login"
                    }
                )

            } else if screen == "selected" {
                MovieSelectedView(
                    title: selectedTitle,
                    year: selectedYear,
                    onClose: {
                        screen = "feed"
                    },
                    onDetails: {
                        screen = "details"
                    },
                    onMarkNotInterested: {
                        print("Marked not interested: \(selectedTitle)")
                        screen = "feed"
                    }
                )

            } else if screen == "details" {
                MovieDetailsView(
                    title: selectedTitle,
                    rating: "8.0",
                    runtime: "124 min",
                    genres: "Thriller, Adventure",
                    posterName: nil,
                    onBack: {
                        screen = "selected"
                    }
                )

            } else {
                MovieFeedView(
                    onOpenSettings: {
                        screen = "settings"
                    },
                    onOpenDetails: { movieTitle in
                        selectedTitle = movieTitle
                        selectedYear = "1975"
                        screen = "selected"
                    }
                )
            }
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
