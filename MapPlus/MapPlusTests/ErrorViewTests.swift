//
//  ErrorViewTests.swift
//  MapPlusTests
//
//  Created by Patrick McGonigle.
//
//  NOTE: ViewInspector's inspect() relies on MainActor.assumeIsolated, which
//  assumes the real main thread the way XCTest guarantees. Swift Testing does
//  not provide that guarantee (even for @MainActor tests), which crashes
//  ViewInspector at runtime. So, unlike the rest of this project, ViewInspector
//  tests use XCTest rather than Swift Testing.

import XCTest
import ViewInspector
@testable import MapPlus

@MainActor
final class ErrorViewTests: XCTestCase {

    func testDisplaysMessages() throws {
        let view = ErrorView(
            shortMessage: "Something went wrong",
            error: MapPlusError.unknown("Detailed failure reason")
        )

        let shortMessage = try view.inspect().find(text: "Something went wrong")
        XCTAssertEqual(try shortMessage.string(), "Something went wrong")

        let detail = try view.inspect().find(text: "Detailed failure reason")
        XCTAssertEqual(try detail.string(), "Detailed failure reason")
    }

    func testDisplaysIcon() throws {
        let view = ErrorView(
            shortMessage: "Oops",
            error: MapPlusError.unknown("Oops detail")
        )

        let image = try view.inspect().find(ViewType.Image.self)
        XCTAssertEqual(try image.actualImage().name(), "exclamationmark.circle")
    }
}
