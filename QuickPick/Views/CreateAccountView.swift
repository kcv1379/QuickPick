import SwiftUI

struct CreateAccountView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var region: String = ""

    @State private var regions: [TMDBRegion] = []
    @State private var isLoadingRegions = false
    @State private var regionLoadError = ""

    let onCreateAccount: (_ username: String, _ password: String, _ region: String) -> Void
    let onBack: () -> Void

    var body: some View {
        let _ = print("Lifecycle: CreateAccountView onCreate")

        ZStack {
            QPTheme.bg.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    Button {
                        onBack()
                    } label: {
                        Label("Back", systemImage: "chevron.left")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundStyle(.white)

                    Spacer()
                }
                .padding(.top, 10)

                Text("Create Account")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(.white)

                QPField(title: "Username", text: $username)
                QPField(title: "Password", text: $password, isSecure: true)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Region")
                        .font(.caption)
                        .foregroundStyle(QPTheme.subtle)

                    if isLoadingRegions {
                        HStack {
                            ProgressView()
                                .tint(.white)

                            Text("Loading regions...")
                                .foregroundStyle(QPTheme.subtle)

                            Spacer()
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 12)
                        .background(QPTheme.field)
                        .clipShape(RoundedRectangle(cornerRadius: 14))

                    } else if !regionLoadError.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(regionLoadError)
                                .font(.system(size: 14))
                                .foregroundStyle(.red)

                            Button("Try Again") {
                                Task {
                                    await loadRegions()
                                }
                            }
                            .foregroundStyle(.white)
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 12)
                        .background(QPTheme.field)
                        .clipShape(RoundedRectangle(cornerRadius: 14))

                    } else {
                        HStack {
                            Picker("Region", selection: $region) {
                                Text("Select region").tag("")
                                ForEach(regions, id: \.iso_3166_1) { r in
                                    Text("\(r.iso_3166_1) - \(r.english_name)")
                                        .tag(r.iso_3166_1)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(.white)

                            Spacer()

                            Text(region.isEmpty ? "None" : region)
                                .foregroundStyle(.white.opacity(0.65))
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 12)
                        .background(QPTheme.field)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }

                Button("Create Account") {
                    onCreateAccount(username, password, region)
                }
                .buttonStyle(QPPrimaryButtonStyle())
                .padding(.top, 4)
                .disabled(region.isEmpty || isLoadingRegions || !regionLoadError.isEmpty)
                .opacity(region.isEmpty || isLoadingRegions || !regionLoadError.isEmpty ? 0.6 : 1.0)

                Spacer()
            }
            .padding(.horizontal, 20)
        }
        .preferredColorScheme(.dark)
        .task {
            await loadRegions()
        }
        .onAppear {
            print("Lifecycle: CreateAccountView onStart")
            print("Lifecycle: CreateAccountView onResume")
        }
        .onDisappear {
            print("Lifecycle: CreateAccountView onPause")
            print("Lifecycle: CreateAccountView onStop")
        }
    }

    private func loadRegions() async {
        isLoadingRegions = true
        regionLoadError = ""

        do {
            regions = try await TMDBService.shared.fetchRegions()
        } catch {
            regionLoadError = "Failed to load regions."
        }

        isLoadingRegions = false
    }
}
