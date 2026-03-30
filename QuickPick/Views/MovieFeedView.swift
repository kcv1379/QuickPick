import SwiftUI

struct QPMovie: Identifiable, Hashable, Decodable {
    let id: Int
    let title: String
    let release_date: String?
    let poster_path: String?

    var year: String {
        guard let release_date, release_date.count >= 4 else { return "----" }
        return String(release_date.prefix(4))
    }

    var posterURL: URL? {
        guard let poster_path else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(poster_path)")
    }
}

struct MovieFeedView: View {
    @Binding var timeLimit: String
    @Binding var discoveryMode: String
    @Binding var page: Int

    @State private var showFilterSheet = false
    @State private var movies: [QPMovie] = []
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var totalPages = 1

    @State private var genres: [TMDBGenre] = []
    @State private var selectedGenreIds: Set<Int> = []

    @State private var providers: [TMDBProvider] = []
    @State private var selectedProviderIds: Set<Int> = []

    let region: String
    let onOpenSettings: () -> Void
    let onOpenDetails: (_ movie: QPMovie) -> Void
    let notInterestedMovies: [QPMovie]

    private let discoveryModes = ["Popular", "Top Rated"]

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        ZStack {
            QPTheme.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView {
                    VStack(alignment: .leading, spacing: 6) {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.top, 40)

                        } else if !errorMessage.isEmpty {
                            VStack(spacing: 12) {
                                Text("Failed to load movies")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(.white)

                                Text(errorMessage)
                                    .font(.system(size: 13))
                                    .foregroundStyle(QPTheme.subtle)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 20)

                                Button("Try Again") {
                                    Task {
                                        await loadMovies()
                                    }
                                }
                                .buttonStyle(QPPrimaryButtonStyle())
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 40)

                        } else if movies.isEmpty {
                            Text("No movies to show")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.top, 40)

                        } else {
                            LazyVGrid(columns: columns, spacing: 8) {
                                ForEach(Array(movies.prefix(20))) { movie in
                                    Button {
                                        onOpenDetails(movie)
                                    } label: {
                                        PosterCard(
                                            movie: movie,
                                            isNotInterested: notInterestedMovies.contains(where: { $0.id == movie.id })
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 14)
                            .padding(.top, 2)
                            .padding(.bottom, 20)
                        }
                    }
                }

                bottomBar
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showFilterSheet) {
            filterSheet
                .presentationDetents([.medium])
        }
        .task {
            await loadFilterOptions()
            await loadMovies()
        }
        .onChange(of: page) { _, _ in
            Task {
                await loadMovies()
            }
        }
        .onChange(of: discoveryMode) { _, _ in
            page = 1
            Task {
                await loadMovies()
            }
        }
        .onChange(of: region) { _, _ in
            selectedProviderIds.removeAll()
            Task {
                await loadProviders()
                page = 1
                await loadMovies()
            }
        }
        .onAppear {
            print("Lifecycle: MovieFeedView onStart")
            print("Lifecycle: MovieFeedView onResume")
        }
        .onDisappear {
            print("Lifecycle: MovieFeedView onPause")
            print("Lifecycle: MovieFeedView onStop")
        }
    }

    private var header: some View {
        HStack(spacing: 10) {
            Text("QuickPick")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)

            Spacer()

            Text("\(discoveryMode) • \(region)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(QPTheme.subtle)

            Button {
                showFilterSheet = true
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private var bottomBar: some View {
        HStack {
            Button {
                onOpenSettings()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
            }
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(.white.opacity(0.9))

            Spacer()

            HStack(spacing: 16) {
                Button("Prev") {
                    if page > 1 {
                        page -= 1
                    }
                    print("Prev page: \(page)")
                }
                .disabled(page == 1)

                Text("Page \(page)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(QPTheme.subtle)
                    .frame(minWidth: 70)

                Button("Next") {
                    if page < totalPages {
                        page += 1
                    }
                    print("Next page: \(page)")
                }
                .disabled(page >= totalPages)
            }
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(.white.opacity(0.85))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(QPTheme.bg.opacity(0.98))
    }

    private var filterSheet: some View {
        ZStack {
            QPTheme.bg.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {
                Text("Filters")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(.white)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Time limit (minutes)")
                        .font(.caption)
                        .foregroundStyle(QPTheme.subtle)

                    TextField("e.g. 120", text: $timeLimit)
                        .keyboardType(.numberPad)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 12)
                        .background(QPTheme.field)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Discovery mode")
                        .font(.caption)
                        .foregroundStyle(QPTheme.subtle)

                    Picker("Mode", selection: $discoveryMode) {
                        ForEach(discoveryModes, id: \.self) { m in
                            Text(m).tag(m)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Genres")
                        .font(.caption)
                        .foregroundStyle(QPTheme.subtle)

                    Menu {
                        ForEach(genres, id: \.id) { genre in
                            Button {
                                toggleGenre(genre.id)
                            } label: {
                                HStack {
                                    Text(genre.name)
                                    Spacer()
                                    if selectedGenreIds.contains(genre.id) {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedGenreLabel)
                                .foregroundStyle(.white)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundStyle(QPTheme.subtle)
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 12)
                        .background(QPTheme.field)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Streaming providers")
                        .font(.caption)
                        .foregroundStyle(QPTheme.subtle)

                    Menu {
                        ForEach(providers, id: \.provider_id) { provider in
                            Button {
                                toggleProvider(provider.provider_id)
                            } label: {
                                HStack {
                                    Text(provider.provider_name)
                                    Spacer()
                                    if selectedProviderIds.contains(provider.provider_id) {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedProviderLabel)
                                .foregroundStyle(.white)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundStyle(QPTheme.subtle)
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 12)
                        .background(QPTheme.field)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }

                HStack(spacing: 12) {
                    Button("Clear Filters") {
                        timeLimit = ""
                        discoveryMode = "Popular"
                        selectedGenreIds.removeAll()
                        selectedProviderIds.removeAll()
                        page = 1
                    }
                    .buttonStyle(QPPrimaryButtonStyle())

                    Button("Apply") {
                        page = 1
                        showFilterSheet = false
                        Task {
                            await loadMovies()
                        }
                    }
                    .buttonStyle(QPPrimaryButtonStyle())
                }
                .padding(.top, 4)

                Spacer()
            }
            .padding(20)
        }
        .preferredColorScheme(.dark)
    }

    private var selectedGenreLabel: String {
        if selectedGenreIds.isEmpty {
            return "Any"
        }
        return "\(selectedGenreIds.count) selected"
    }

    private var selectedProviderLabel: String {
        if selectedProviderIds.isEmpty {
            return "Any"
        }
        return "\(selectedProviderIds.count) selected"
    }

    private func loadMovies() async {
        isLoading = true
        errorMessage = ""

        do {
            let response = try await TMDBService.shared.fetchMovies(
                mode: discoveryMode,
                page: page,
                region: region,
                timeLimit: timeLimit,
                genreIds: Array(selectedGenreIds),
                providerIds: Array(selectedProviderIds)
            )
            movies = response.results
            totalPages = response.total_pages
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    private func loadFilterOptions() async {
        do {
            genres = try await TMDBService.shared.fetchGenres()
            providers = try await TMDBService.shared.fetchMovieProviders(region: region)
            print("Loaded genres: \(genres.count)")
            print("Loaded providers: \(providers.count)")
        } catch {
            print("Filter load error: \(error.localizedDescription)")
            genres = []
            providers = []
        }
    }

    private func loadProviders() async {
        do {
            providers = try await TMDBService.shared.fetchMovieProviders(region: region)
        } catch {
            providers = []
        }
    }

    private func toggleGenre(_ id: Int) {
        if selectedGenreIds.contains(id) {
            selectedGenreIds.remove(id)
        } else {
            selectedGenreIds.insert(id)
        }
    }

    private func toggleProvider(_ id: Int) {
        if selectedProviderIds.contains(id) {
            selectedProviderIds.remove(id)
        } else {
            selectedProviderIds.insert(id)
        }
    }
}

private struct PosterCard: View {
    let movie: QPMovie
    let isNotInterested: Bool

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
                            .saturation(isNotInterested ? 0 : 1)
                            .opacity(isNotInterested ? 0.35 : 1)

                    case .failure(_):
                        fallbackCard

                    @unknown default:
                        fallbackCard
                    }
                }
            } else {
                fallbackCard
            }

            if isNotInterested {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.25))
                    .aspectRatio(2/3, contentMode: .fit)
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
        .opacity(isNotInterested ? 0.5 : 1)
    }
}
