import SwiftUI

struct SettingsView: View {
    @State private var region: String
    @State private var shakeEnabled: Bool

    let onBack: () -> Void
    let onSave: (_ region: String, _ shakeEnabled: Bool) -> Void
    let onEditNotInterested: () -> Void
    let onLogout: () -> Void

    init(
        region: String = "US",
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

                    Picker("Region", selection: $region) {
                        Text("US").tag("US")
                        Text("UK").tag("UK")
                        Text("CA").tag("CA")
                        Text("JP").tag("JP")
                        Text("KR").tag("KR")
                    }
                    .pickerStyle(.menu)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 6)
                    .background(QPTheme.field)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .tint(.white)
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
        .onAppear {
            print("Lifecycle: SettingsView onStart")
            print("Lifecycle: SettingsView onResume")
        }
        .onDisappear {
            print("Lifecycle: SettingsView onPause")
            print("Lifecycle: SettingsView onStop")
        }
        .onChange(of: region) { _, newValue in
            onSave(newValue, shakeEnabled)
        }
        .onChange(of: shakeEnabled) { _, newValue in
            onSave(region, newValue)
        }
    }
}
