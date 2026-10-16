//
//  MapPlusUITests.swift
//  MapPlusUITests
//
//  Created by Patrick McGonigle on 9/6/25.
//

import XCTest

final class MapPlusUITests: XCTestCase {

    override func setUpWithError() throws {
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
    }

    // MARK: - Helpers

    /// Launches the app configured to use in-memory sample data and mock services,
    /// so tests are deterministic and don't touch the user's real data, location
    /// services, or on-device AI.
    @MainActor
    private func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["UI-Testing"]
        app.launch()
        return app
    }

    /// Finds the list row button whose label contains the given landmark name.
    private func landmarkRow(named name: String, in app: XCUIApplication) -> XCUIElement {
        app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] %@", name)
        ).firstMatch
    }

    /// Opens the "My Places..." toolbar menu and taps its "My Places..." entry to
    /// present the saved landmarks list.
    ///
    /// Both the toolbar's menu trigger and the menu's own entry share the exact
    /// label "My Places...", so the entry is disambiguated by its `list.bullet`
    /// accessibility identifier.
    private func openMyPlacesList(in app: XCUIApplication) {
        app.buttons["My Places..."].tap()
        app.buttons.matching(
            NSPredicate(format: "label == %@ AND identifier == %@", "My Places...", "list.bullet")
        ).firstMatch.tap()
    }

    // MARK: - Tests

    @MainActor
    func testMainMapControlsAreVisible() throws {
        let app = launchApp()

        XCTAssertTrue(app.buttons["Add a place"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["me"].exists)
        XCTAssertTrue(app.buttons["My Places..."].exists)
        XCTAssertTrue(app.buttons["Categories"].exists)
    }

    @MainActor
    func testOpeningMyPlacesShowsSampleLandmarks() throws {
        let app = launchApp()

        openMyPlacesList(in: app)

        XCTAssertTrue(app.navigationBars["My Places"].waitForExistence(timeout: 5))
        XCTAssertTrue(landmarkRow(named: "Texas Capital Lawn", in: app).exists)
        XCTAssertTrue(landmarkRow(named: "Cosmic Coffee & Beer Garden", in: app).exists)
        XCTAssertTrue(landmarkRow(named: "Work", in: app).exists)
    }

    @MainActor
    func testDeletingLandmarkFromMyPlacesList() throws {
        let app = launchApp()

        openMyPlacesList(in: app)

        let workRow = landmarkRow(named: "Work", in: app)
        XCTAssertTrue(workRow.waitForExistence(timeout: 5))

        workRow.swipeLeft()
        app.buttons["Delete"].tap()

        let deletedRow = landmarkRow(named: "Work", in: app)
        let goneExpectation = expectation(for: NSPredicate(format: "exists == false"), evaluatedWith: deletedRow)
        wait(for: [goneExpectation], timeout: 5)

        XCTAssertTrue(landmarkRow(named: "Texas Capital Lawn", in: app).exists)
        XCTAssertTrue(landmarkRow(named: "Cosmic Coffee & Beer Garden", in: app).exists)
    }

    @MainActor
    func testCategoriesPopoverShowsSampleCategories() throws {
        let app = launchApp()

        app.buttons["Categories"].tap()

        XCTAssertTrue(app.staticTexts["FAMILY"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["FUN"].exists)
        XCTAssertTrue(app.staticTexts["ARCADES"].exists)
        XCTAssertTrue(app.staticTexts["CAFES"].exists)
    }

    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
