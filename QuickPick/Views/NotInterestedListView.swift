import SwiftUI

struct NotInterestedListView: View {
    @Binding var notInterestedMovies: [QPMovie]

    let onBack: () -> Void

    @State private var showClearAlert = false

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
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.white)

                        Text("Movies you mark as not interested will show up here.")
                            .font(.system(size: 14))
                            .foregroundStyle(QPTheme.subtle)
                            .multilineTextAlignment(.center)
                            .padding(.top, 4)
                            .padding(.horizontal, 24)

                        Spacer()
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 8) {
                            ForEach(notInterestedMovies) { movie in
                                ZStack(alignment: .topTrailing) {
                                    NotInterestedPosterCard(movie: movie)

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
                        .padding(.horizontal, 14)
                        .padding(.top, 2)
                        .padding(.bottom, 16)
                    }

                    Button {
                        showClearAlert = true
                    } label: {
                        Text("Clear All")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(QPTheme.field)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal, 14)
                    .padding(.top, 8)
                    .padding(.bottom, 16)
                }
            }
        }
        .preferredColorScheme(.dark)
        .alert("Clear all movies?", isPresented: $showClearAlert) {
            Button("Clear", role: .destructive) {
                notInterestedMovies.removeAll()
            }
            Button("Cancel", role: .cancel) { }
        }
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
            Button("Back") {
                onBack()
            }
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(.white)

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private func removeMovie(_ movie: QPMovie) {
        notInterestedMovies.removeAll { $0.id == movie.id }
    }
}

private struct NotInterestedPosterCard: View {
    let movie: QPMovie

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(QPTheme.card)
                .aspectRatio(2/3, contentMode: .fit)

            if let posterURL = movie.posterURL {
                AsyncImage(url: posterURL) { phase in
                    switch phase {
                    case .empty:
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(QPTheme.card)
                                .aspectRatio(2/3, contentMode: .fit)

                            ProgressView()
                                .tint(.white)
                        }

                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .aspectRatio(2/3, contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                    case .failure(_):
                        fallbackCard

                    @unknown default:
                        fallbackCard
                    }
                }
            } else {
                fallbackCard
            }
        }
    }

    private var fallbackCard: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 12)
                .fill(QPTheme.card)
                .aspectRatio(2/3, contentMode: .fit)

            VStack(alignment: .leading, spacing: 2) {
                Text(movie.title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(3)

                Text(movie.year)
                    .font(.system(size: 11))
                    .foregroundStyle(QPTheme.subtle)
            }
            .padding(8)
        }
    }
}
