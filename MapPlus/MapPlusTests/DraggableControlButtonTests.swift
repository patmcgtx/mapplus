//
//  DraggableControlButtonTests.swift
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
final class DraggableControlButtonTests: XCTestCase {

    func testTapInvokesOnTap() throws {
        var tapped = false

        let view = DraggableControlButton(
            systemImageName: "plus",
            onTap: { tapped = true },
            onMoved: { _ in }
        )

        try view.inspect().find(ViewType.Button.self).tap()

        XCTAssertTrue(tapped)
    }

    func testDisplaysSystemImage() throws {
        let view = DraggableControlButton(
            systemImageName: "location",
            onTap: {},
            onMoved: { _ in }
        )

        let image = try view.inspect().find(ViewType.Image.self)
        XCTAssertEqual(try image.actualImage().name(), "location")
    }
}
