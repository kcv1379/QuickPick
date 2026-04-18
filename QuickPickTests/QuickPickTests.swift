import XCTest
@testable import QuickPick

final class QuickPickTests: XCTestCase {

    func testQPMovieYearFromReleaseDate() {
        let movie = QPMovie(id: 1, title: "Test Movie", release_date: "2023-05-10", poster_path: nil)
        XCTAssertEqual(movie.year, "2023")
    }

    func testQPMovieYearWhenReleaseDateMissing() {
        let movie = QPMovie(id: 2, title: "Test Movie", release_date: nil, poster_path: nil)
        XCTAssertEqual(movie.year, "----")
    }

    func testMovieDetailsComputedTexts() {
        let detailsWithValues = TMDBMovieDetails(
            id: 1,
            title: "Movie A",
            vote_average: 8.4,
            runtime: 120,
            genres: [],
            release_date: "2024-01-01",
            poster_path: nil,
            overview: ""
        )

        XCTAssertEqual(detailsWithValues.runtimeText, "120 min")
        XCTAssertEqual(detailsWithValues.synopsisText, "No synopsis available.")

        let detailsWithoutRuntime = TMDBMovieDetails(
            id: 2,
            title: "Movie B",
            vote_average: 7.1,
            runtime: nil,
            genres: [],
            release_date: nil,
            poster_path: nil,
            overview: "A real overview."
        )

        XCTAssertEqual(detailsWithoutRuntime.runtimeText, "N/A")
        XCTAssertEqual(detailsWithoutRuntime.synopsisText, "A real overview.")
    }
}
