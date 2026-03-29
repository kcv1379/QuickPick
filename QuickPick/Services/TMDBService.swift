import Foundation

struct TMDBMovieResponse: Decodable {
    let page: Int
    let results: [QPMovie]
    let total_pages: Int
}

struct TMDBGenre: Decodable {
    let id: Int
    let name: String
}

struct TMDBMovieDetails: Decodable {
    let id: Int
    let title: String
    let vote_average: Double
    let runtime: Int?
    let genres: [TMDBGenre]
    let release_date: String?
    let poster_path: String?
    let overview: String

    var year: String {
        guard let release_date, release_date.count >= 4 else { return "----" }
        return String(release_date.prefix(4))
    }

    var ratingText: String {
        String(format: "%.1f", vote_average)
    }

    var runtimeText: String {
        guard let runtime else { return "N/A" }
        return "\(runtime) min"
    }

    var genresText: String {
        if genres.isEmpty { return "N/A" }
        return genres.map { $0.name }.joined(separator: ", ")
    }

    var synopsisText: String {
        overview.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "No synopsis available." : overview
    }
}

struct TMDBRegion: Decodable, Hashable {
    let iso_3166_1: String
    let english_name: String
}

struct TMDBRegionResponse: Decodable {
    let results: [TMDBRegion]
}

final class TMDBService {
    static let shared = TMDBService()

    private let bearerToken = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJmOGEzYzc4MThlYjYyMGFjNjM5MjBkMTc3NTY3OTVjOSIsIm5iZiI6MTcwNTI3ODA3NC44NDQsInN1YiI6IjY1YTQ3YTdhYmMyY2IzMDBiZTAyNTZlOSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ._s-6BhvPK-qoI0b9X94sXvqKS50-HSP93yC0iS7_Bto"

    private init() { }

    func fetchMovies(mode: String, page: Int, region: String, timeLimit: String) async throws -> TMDBMovieResponse {
        var components = URLComponents(string: "https://api.themoviedb.org/3/discover/movie")!

        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "region", value: region),
            URLQueryItem(name: "watch_region", value: region),
            URLQueryItem(name: "include_adult", value: "false")
        ]

        if mode == "Top Rated" {
            queryItems.append(URLQueryItem(name: "sort_by", value: "vote_average.desc"))
            queryItems.append(URLQueryItem(name: "vote_count.gte", value: "500"))
        } else {
            queryItems.append(URLQueryItem(name: "sort_by", value: "popularity.desc"))
        }

        let trimmedTime = timeLimit.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedTime.isEmpty {
            queryItems.append(URLQueryItem(name: "with_runtime.lte", value: trimmedTime))
        }

        components.queryItems = queryItems

        guard let url = components.url else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(TMDBMovieResponse.self, from: data)
    }

    func fetchMovieDetails(movieId: Int) async throws -> TMDBMovieDetails {
        guard let url = URL(string: "https://api.themoviedb.org/3/movie/\(movieId)") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(TMDBMovieDetails.self, from: data)
    }

    func fetchRegions() async throws -> [TMDBRegion] {
        guard let url = URL(string: "https://api.themoviedb.org/3/watch/providers/regions") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }

        let decoded = try JSONDecoder().decode(TMDBRegionResponse.self, from: data)
        return decoded.results.sorted { $0.iso_3166_1 < $1.iso_3166_1 }
    }
}
