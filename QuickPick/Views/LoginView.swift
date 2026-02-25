import SwiftUI

struct LoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""

    let onLogin: (_ username: String, _ password: String) -> Void
    let onCreateAccount: () -> Void

    var body: some View {
        ZStack {
            QPTheme.bg.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 18) {
                Spacer().frame(height: 40)

                Text("QuickPick")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundStyle(.white)

                Text("some sort of catch phrase")
                    .font(.system(size: 16))
                    .foregroundStyle(QPTheme.subtle)

                Spacer().frame(height: 8)

                QPField(title: "Username", text: $username)
                QPField(title: "Password", text: $password, isSecure: true)

                Button("Login") {
                    //hussan: navigate to MovieFeedView
                    onLogin(username, password)
                }
                .buttonStyle(QPPrimaryButtonStyle())
                .padding(.top, 4)

                Button("Create Account") {
                    //hussan: navigate to CreateAccountView
                    onCreateAccount()
                }
                .buttonStyle(QPSecondaryButtonStyle())

                Spacer()

            }
            .padding(.horizontal, 20)
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    LoginView(
        onLogin: { _, _ in },
        onCreateAccount: { }
    )
}
