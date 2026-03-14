import SwiftUI

struct MovieDetailsView: View {
    let title: String
    let rating: String
    let runtime: String
    let genres: String
    let posterName: String?

    let onBack: () -> Void

    var body: some View {
        let _ = print("Lifecycle: MovieDetailsView onCreateView")

        ZStack {
            QPTheme.bg.ignoresSafeArea()

            VStack {
                Spacer()

                VStack(alignment: .leading, spacing: 26) {

                    HStack {
                        Button("Back") {
                            onBack()
                        }
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)

                        Spacer()
                    }
                    .padding(.top, -10)

                    HStack {
                        Spacer()

                        Text("Movie Details")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundStyle(.white)

                        Spacer()
                    }

                    HStack {
                        Spacer()

                        RoundedRectangle(cornerRadius: 18)
                            .fill(QPTheme.card)
                            .frame(width: 180, height: 260)
                            .overlay {
                                Text(posterName ?? "Poster")
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundStyle(QPTheme.subtle)
                            }

                        Spacer()
                    }

                    detailRow(label: "Title", value: title)
                    detailRow(label: "Rating", value: rating)
                    detailRow(label: "Runtime", value: runtime)
                    detailRow(label: "Genres", value: genres)
                }

                Spacer()
            }
            .padding(.horizontal, 32)
        }
        .preferredColorScheme(.dark)
        .onAppear {
            print("Lifecycle: MovieDetailsView onStart")
            print("Lifecycle: MovieDetailsView onResume")
        }
        .onDisappear {
            print("Lifecycle: MovieDetailsView onPause")
            print("Lifecycle: MovieDetailsView onStop")
        }
    }

    private func detailRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(QPTheme.subtle)

            Text(value)
                .font(.system(size: 19, weight: .medium))
                .foregroundStyle(.white)
        }
    }
}
