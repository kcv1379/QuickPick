import SwiftUI

struct MovieSelectedView: View {
    let title: String
    let year: String

    let onClose: () -> Void
    let onDetails: () -> Void
    let onMarkNotInterested: () -> Void

    var body: some View {
        let _ = print("Lifecycle: MovieSelectedView onCreateView")

        ZStack {
            QPTheme.bg.ignoresSafeArea()

            VStack {
                Spacer()

                VStack(spacing: 26) {

                    HStack {
                        Spacer()

                        Button {
                            onClose()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(10)
                                .background(.white.opacity(0.15))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.top, -20)

                    Text("Movie Selected:")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(.white)

                    Text("\(title) (\(year))")
                        .font(.system(size: 26, weight: .medium))
                        .foregroundStyle(QPTheme.subtle)

                    RoundedRectangle(cornerRadius: 22)
                        .fill(QPTheme.card)
                        .frame(width: 260, height: 380)
                        .overlay {
                            Text(title)
                                .font(.system(size: 26, weight: .medium))
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.white)
                                .padding(18)
                        }

                    Button {
                        onDetails()
                    } label: {
                        Text("Details")
                            .font(.system(size: 18, weight: .bold))
                            .underline()
                            .foregroundStyle(.white)
                    }

                    Button("Mark Not Interested") {
                        onMarkNotInterested()
                    }
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.black)
                    .frame(width: 200)
                    .padding(.vertical, 8)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 9))
                }

                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .preferredColorScheme(.dark)
        .onAppear {
            print("Lifecycle: MovieSelectedView onStart")
            print("Lifecycle: MovieSelectedView onResume")
        }
        .onDisappear {
            print("Lifecycle: MovieSelectedView onPause")
            print("Lifecycle: MovieSelectedView onStop")
        }
    }
}
