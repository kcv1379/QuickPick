import SwiftUI

struct CreateAccountView: View {
    
    //temp local states
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var region: String = "US"

    //temp mock data
    let regions = ["US", "CA", "GB", "AU", "JP"]

    //hussan: back should return to login screen
    let onCreateAccount: (_ username: String, _ password: String, _ region: String) -> Void
    let onBack: () -> Void

    var body: some View {
        ZStack {
            QPTheme.bg.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    Button {
                        //navigate back to login screen
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

                    HStack {
                        Picker("Region", selection: $region) {
                            ForEach(regions, id: \.self) { r in
                                Text(r).tag(r)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(.white)

                        Spacer()

                        Text(region)
                            .foregroundStyle(.white.opacity(0.65))
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 12)
                    .background(QPTheme.field)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                Button("Create Account") {
                    onCreateAccount(username, password, region)
                }
                .buttonStyle(QPPrimaryButtonStyle())
                .padding(.top, 4)

                Spacer()
            }
            .padding(.horizontal, 20)
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    CreateAccountView(
        onCreateAccount: { _, _, _ in },
        onBack: { }
    )
}
