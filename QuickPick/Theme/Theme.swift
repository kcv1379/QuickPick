import SwiftUI

enum QPTheme {
    static let bg = Color(red: 0.06, green: 0.06, blue: 0.07)
    static let card = Color(red: 0.12, green: 0.12, blue: 0.14)
    static let field = Color(red: 0.14, green: 0.14, blue: 0.16)
    static let subtle = Color.white.opacity(0.65)
}

struct QPPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.white)
            .foregroundColor(.black)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .opacity(configuration.isPressed ? 0.85 : 1.0)
    }
}

struct QPSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(QPTheme.field)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .opacity(configuration.isPressed ? 0.85 : 1.0)
    }
}

struct QPField: View {
    let title: String
    @Binding var text: String
    var isSecure: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundStyle(QPTheme.subtle)

            if isSecure {
                SecureField("", text: $text)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 12)
                    .background(QPTheme.field)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            } else {
                TextField("", text: $text)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 12)
                    .background(QPTheme.field)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
    }
}
