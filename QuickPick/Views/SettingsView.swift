import SwiftUI

struct SettingsView: View {
    @State private var region: String
    @State private var shakeEnabled: Bool

    @State private var regions: [TMDBRegion] = []
    @State private var isLoadingRegions = false
    @State private var regionLoadError = ""

    let onBack: () -> Void
    let onSave: (_ region: String, _ shakeEnabled: Bool) -> Void
    let onEditNotInterested: () -> Void
    let onLogout: () -> Void

    init(
        region: String = "",
        shakeEnabled: Bool = true,
        onBack: @escaping () -> Void,
        onSave: @escaping (_ region: String, _ shakeEnabled: Bool) -> Void,
        onEditNotInterested: @escaping () -> Void,
        onLogout: @escaping () -> Void
    ) {
        _region = State(initialValue: region)
        _shakeEnabled = State(initialValue: shakeEnabled)
        self.onBack = onBack
        self.onSave = onSave
        self.onEditNotInterested = onEditNotInterested
        self.onLogout = onLogout
    }

    var body: some View {
        let _ = print("Lifecycle: SettingsView onCreateView")

        ZStack {
            QPTheme.bg.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 20) {
                Button("Back") {
                    onBack()
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)

                Text("Settings")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(.white)

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

                Toggle(isOn: $shakeEnabled) {
                    Text("Shake to QuickPick")
                        .foregroundStyle(.white)
                }
                .tint(.green)

                Button {
                    onEditNotInterested()
                } label: {
                    Text("Edit Not Interested List")
                        .font(.system(size: 16, weight: .medium))
                        .underline()
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)

                Spacer()

                Button("Logout") {
                    onLogout()
                }
                .buttonStyle(QPPrimaryButtonStyle())
            }
            .padding(20)
        }
        .preferredColorScheme(.dark)
        .task {
            await loadRegions()
        }
        .onAppear {
            print("Lifecycle: SettingsView onStart")
            print("Lifecycle: SettingsView onResume")
        }
        .onDisappear {
            print("Lifecycle: SettingsView onPause")
            print("Lifecycle: SettingsView onStop")
        }
        .onChange(of: region) { _, newValue in
            if !newValue.isEmpty {
                onSave(newValue, shakeEnabled)
            }
        }
        .onChange(of: shakeEnabled) { _, newValue in
            onSave(region, newValue)
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
