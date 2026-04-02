import SwiftUI
import FirebaseCore
import FirebaseAuth
extension Notification.Name {
    static let shake = Notification.Name("shake")
}
@main
struct QuickPickApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var screen = "login"
    @State private var selectedMovie: QPMovie? = nil

    @State private var region = "US"
    @State private var shakeEnabled = true

    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    @State private var feedTimeLimit = ""
    @State private var feedDiscoveryMode = "Popular"
    @State private var feedPage = 1

    @State private var notInterestedMovies: [QPMovie] = []

    init() {
        FirebaseApp.configure()
    }
    private func saveNotInterested() {
        let ids = notInterestedMovies.map { $0.id }
        if let data = try? JSONEncoder().encode(ids) {
            UserDefaults.standard.set(data, forKey: "notInterestedMovieIDs")
        }
    }

    private func loadNotInterested() {
        if let data = UserDefaults.standard.data(forKey: "notInterestedMovieIDs"),
           let ids = try? JSONDecoder().decode([Int].self, from: data) {
            notInterestedMovies = notInterestedMovies.filter { ids.contains($0.id) }
        }
    }
    private func handleShake(){
        guard shakeEnabled else { 
                                return
        }
        if screen == "feed" {
            print("QuickPick enabled")
        }
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

                            if trimmedUsername.isEmpty || trimmedPassword.isEmpty || region.isEmpty {
                                alertTitle = "Missing Info"
                                alertMessage = "Please enter username, password, and region."
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

                } else if screen == "selected", let movie = selectedMovie {
                    MovieSelectedView(
                        title: movie.title,
                        year: movie.year,
                        posterURL: movie.posterURL,
                        onClose: {
                            screen = "feed"
                        },
                        onDetails: {
                            screen = "details"
                        },
                        onMarkNotInterested: {
                            if !notInterestedMovies.contains(movie) {
                                notInterestedMovies.append(movie)
                            }
                            saveNotInterested()
                            print("Marked not interested: \(movie.title)")
                            screen = "feed"
                        }
                    )

                } else if screen == "details", let movie = selectedMovie {
                    MovieDetailsView(
                        movieId: movie.id,
                        onBack: {
                            screen = "selected"
                        }
                    )
                    
                } else {
                    MovieFeedView(
                        timeLimit: $feedTimeLimit,
                        discoveryMode: $feedDiscoveryMode,
                        page: $feedPage,
                        region: region,
                        onOpenSettings: {
                            screen = "settings"
                        },
                        onOpenDetails: { movie in
                            selectedMovie = movie
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
            .onAppear{
                loadNotInterested()
                NotificationCenter.default.addObserver(forName: .shake, object: nil, queue: .main){ _ in
                                                                                                   handleShake()
                }
            }
            .onDisappear{
                NotificationCenter.default.removeObserver(self, name: .shake, object: nil)
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
