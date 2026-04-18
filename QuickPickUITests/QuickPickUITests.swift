import XCTest

final class QuickPickUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLoginScreenLoads() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.buttons["Login"].exists)
        XCTAssertTrue(app.buttons["Create Account"].exists)
    }

    func testCreateAccountScreenOpens() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["Create Account"].tap()

        XCTAssertTrue(app.staticTexts["Create Account"].exists)
        XCTAssertTrue(app.buttons["Back"].exists)
    }

    func testBackFromCreateAccountReturnsToLogin() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["Create Account"].tap()
        app.buttons["Back"].tap()

        XCTAssertTrue(app.buttons["Login"].exists)
        XCTAssertTrue(app.buttons["Create Account"].exists)
    }
}
