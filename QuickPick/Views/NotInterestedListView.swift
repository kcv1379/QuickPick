import SwiftUI

struct NotInterestedListView: View {
    @Binding var notInterestedMovies: [QPMovie]

    let onBack: () -> Void

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        let _ = print("Lifecycle: NotInterestedListView onCreate")

        ZStack {
            QPTheme.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                if notInterestedMovies.isEmpty {
                    VStack {
                        Spacer()

                        Text("No not interested movies")
                            .font(.system(size: 18))
                            .foregroundStyle(QPTheme.subtle)
                            .multilineTextAlignment(.center)
                            .padding(.top, 4)
                            .padding(.horizontal, 24)

                        Spacer()
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(notInterestedMovies) { movie in
                                ZStack(alignment: .topTrailing) {
                                    NotInterestedPosterCard(title: movie.title, year: movie.year)

                                    Button {
                                        removeMovie(movie)
                                    } label: {
                                        Image(systemName: "xmark")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundStyle(.white)
                                            .frame(width: 22, height: 22)
                                            .background(Color.black.opacity(0.75))
                                            .clipShape(Circle())
                                    }
                                    .padding(6)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        .padding(.bottom, 24)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            print("Lifecycle: NotInterestedListView onStart")
            print("Lifecycle: NotInterestedListView onResume")
        }
        .onDisappear {
            print("Lifecycle: NotInterestedListView onPause")
            print("Lifecycle: NotInterestedListView onStop")
        }
    }

    private var header: some View {
        HStack {
            Button {
                onBack()
            } label: {
                Text("Back")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
            }

            Spacer()

            Text("Not Interested")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.white)

            Spacer()

            Text("Back")
                .font(.system(size: 16, weight: .semibold))
                .opacity(0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private func removeMovie(_ movie: QPMovie) {
        notInterestedMovies.removeAll { $0.id == movie.id }
        print("Removed not interested movie: \(movie.title)")
    }
}

private struct NotInterestedPosterCard: View {
    let title: String
    let year: String

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 12)
                .fill(QPTheme.card)
                .frame(height: 130)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .lineLimit(2)

                Text(year)
                    .font(.system(size: 11))
                    .foregroundStyle(QPTheme.subtle)
            }
            .padding(8)
        }
    }
}

#Preview {
    NotInterestedListPreviewWrapper()
}

private struct NotInterestedListPreviewWrapper: View {
    @State private var sampleMovies: [QPMovie] = [
        .init(title: "Jaws", year: "1975"),
        .init(title: "La La Land", year: "2016"),
        .init(title: "Her", year: "2013"),
        .init(title: "Moonlight", year: "2016"),
        .init(title: "Arrival", year: "2016")
    ]

    var body: some View {
        NotInterestedListView(
            notInterestedMovies: $sampleMovies,
            onBack: { }
        )
    }
}
