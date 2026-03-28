import SwiftUI
import FirebaseCore
import FirebaseAuth

@main
struct QuickPickApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var screen = "login"
    @State private var selectedTitle = "Jaws"
    @State private var selectedYear = "1975"

    @State private var region = "US"
    @State private var shakeEnabled = true

    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""

    @State private var notInterestedMovies: [QPMovie] = [
        .init(title: "Jaws", year: "1975"),
        .init(title: "Her", year: "2013")
    ]

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if screen == "login" {
                    LoginView(
                        onLogin: { username, password in
                            let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
                            let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

                            if trimmedUsername.isEmpty || trimmedPassword.isEmpty {
                                alertTitle = "Missing Info"
                                alertMessage = "Please enter both username and password."
                                showAlert = true
                                return
                            }

                            let email = trimmedUsername + "@quickpick.com"

                            Auth.auth().signIn(withEmail: email, password: trimmedPassword) { result, error in
                                if let error = error {
                                    alertTitle = "Login Failed"
                                    alertMessage = error.localizedDescription
                                    showAlert = true
                                    return
                                }

                                print("Login success: \(trimmedUsername)")
                                screen = "feed"
                            }
                        },
                        onCreateAccount: {
                            print("Create account tapped")
                            screen = "create"
                        }
                    )

                } else if screen == "create" {
                    CreateAccountView(
                        onCreateAccount: { username, password, region in
                            let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
                            let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

                            if trimmedUsername.isEmpty || trimmedPassword.isEmpty {
                                alertTitle = "Missing Info"
                                alertMessage = "Please enter both username and password."
                                showAlert = true
                                return
                            }

                            let email = trimmedUsername + "@quickpick.com"

                            Auth.auth().createUser(withEmail: email, password: trimmedPassword) { result, error in
                                if let error = error {
                                    alertTitle = "Create Account Failed"
                                    alertMessage = error.localizedDescription
                                    showAlert = true
                                    return
                                }

                                if let uid = result?.user.uid {
                                    let repo = AccountRepository()
                                    repo.createAccount(vid: uid, username: trimmedUsername, region: region)
                                    print("Account created: \(trimmedUsername), \(region)")
                                }

                                self.region = region
                                screen = "login"
                                alertTitle = "Success"
                                alertMessage = "Account created! Please log in."
                                showAlert = true
                            }
                        },
                        onBack: {
                            print("Back button tapped")
                            screen = "login"
                        }
                    )

                } else if screen == "settings" {
                    SettingsView(
                        region: region,
                        shakeEnabled: shakeEnabled,
                        onBack: {
                            screen = "feed"
                        },
                        onSave: { newRegion, newShakeEnabled in
                            region = newRegion
                            shakeEnabled = newShakeEnabled
                            print("Saved settings: \(newRegion), shakeEnabled=\(newShakeEnabled)")
                        },
                        onEditNotInterested: {
                            print("Edit not interested list tapped")
                            screen = "notInterested"
                        },
                        onLogout: {
                            print("Logout tapped")
                            screen = "login"
                        }
                    )

                } else if screen == "notInterested" {
                    NotInterestedListView(
                        notInterestedMovies: $notInterestedMovies,
                        onBack: {
                            screen = "settings"
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
                            let movie = QPMovie(title: selectedTitle, year: selectedYear)

                            if !notInterestedMovies.contains(movie) {
                                notInterestedMovies.append(movie)
                            }

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
                            if let openParen = movieTitle.lastIndex(of: "("),
                               let closeParen = movieTitle.lastIndex(of: ")") {
                                let titlePart = movieTitle[..<openParen].trimmingCharacters(in: .whitespaces)
                                let yearPart = movieTitle[movieTitle.index(after: openParen)..<closeParen]
                                selectedTitle = String(titlePart)
                                selectedYear = String(yearPart)
                            } else {
                                selectedTitle = movieTitle
                                selectedYear = ""
                            }

                            screen = "selected"
                        },
                        notInterestedMovies: notInterestedMovies
                    )
                }
            }
            .alert(alertTitle, isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
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
