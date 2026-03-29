import SwiftUI

struct MovieDetailsView: View {
    let movieId: Int
    let onBack: () -> Void

    @State private var details: TMDBMovieDetails? = nil
    @State private var isLoading = false
    @State private var errorMessage = ""

    var body: some View {
        let _ = print("Lifecycle: MovieDetailsView onCreateView")

        ZStack {
            QPTheme.bg.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    HStack {
                        Button("Back") {
                            onBack()
                        }
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)

                        Spacer()
                    }
                    .padding(.top, 4)

                    if isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                                .tint(.white)
                            Spacer()
                        }
                        .frame(height: 240)

                    } else if !errorMessage.isEmpty {
                        VStack(spacing: 12) {
                            Text("Failed to load details")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(.white)

                            Text(errorMessage)
                                .font(.system(size: 14))
                                .foregroundStyle(QPTheme.subtle)
                                .multilineTextAlignment(.center)

                            Button("Try Again") {
                                Task {
                                    await loadDetails()
                                }
                            }
                            .buttonStyle(QPPrimaryButtonStyle())
                        }
                        .frame(maxWidth: .infinity, minHeight: 240)

                    } else if let details {
                        HStack {
                            Spacer()

                            if let posterPath = details.poster_path,
                               let url = URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)") {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .empty:
                                        RoundedRectangle(cornerRadius: 18)
                                            .fill(QPTheme.card)
                                            .frame(width: 170, height: 245)
                                            .overlay {
                                                ProgressView()
                                                    .tint(.white)
                                            }

                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 170, height: 245)
                                            .clipShape(RoundedRectangle(cornerRadius: 18))

                                    case .failure(_):
                                        RoundedRectangle(cornerRadius: 18)
                                            .fill(QPTheme.card)
                                            .frame(width: 170, height: 245)
                                            .overlay {
                                                Text("Poster")
                                                    .font(.system(size: 22, weight: .medium))
                                                    .foregroundStyle(QPTheme.subtle)
                                            }

                                    @unknown default:
                                        RoundedRectangle(cornerRadius: 18)
                                            .fill(QPTheme.card)
                                            .frame(width: 170, height: 245)
                                    }
                                }
                            } else {
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(QPTheme.card)
                                    .frame(width: 170, height: 245)
                                    .overlay {
                                        Text("Poster")
                                            .font(.system(size: 22, weight: .medium))
                                            .foregroundStyle(QPTheme.subtle)
                                    }
                            }

                            Spacer()
                        }

                        detailRow(label: "Title", value: details.title)
                        detailRow(label: "Rating", value: details.ratingText)
                        detailRow(label: "Runtime", value: details.runtimeText)
                        detailRow(label: "Genres", value: details.genresText)
                        detailRow(label: "Synopsis", value: details.synopsisText, isSynopsis: true)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 8)
                .padding(.bottom, 20)
            }
        }
        .preferredColorScheme(.dark)
        .task {
            await loadDetails()
        }
        .onAppear {
            print("Lifecycle: MovieDetailsView onStart")
            print("Lifecycle: MovieDetailsView onResume")
        }
        .onDisappear {
            print("Lifecycle: MovieDetailsView onPause")
            print("Lifecycle: MovieDetailsView onStop")
        }
    }

    private func loadDetails() async {
        isLoading = true
        errorMessage = ""

        do {
            details = try await TMDBService.shared.fetchMovieDetails(movieId: movieId)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    private func detailRow(label: String, value: String, isSynopsis: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(QPTheme.subtle)

            Text(value)
                .font(.system(size: isSynopsis ? 16 : 18, weight: .medium))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
