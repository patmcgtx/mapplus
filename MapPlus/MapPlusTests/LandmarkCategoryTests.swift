//
//  LandmarkCategoryTests.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/21/26.
//
import Testing
import SwiftData
@testable import MapPlus

struct LandmarkCategoryTests {

    @Test("LandmarkCategory initialization", arguments: [
        "Cafes",
        "Schools",
        "Museums",
        "Parks",
        ""
    ])
    func testInitialization(name: String) {
        let category = LandmarkCategory(name: name)
        #expect(category.name == name)
    }

    @Test("LandmarkCategory id equals name", arguments: [
        "Cafes",
        "Schools",
        "Museums"
    ])
    func testIdEqualsName(name: String) {
        let category = LandmarkCategory(name: name)
        #expect(category.id == name)
    }

    @Test func testDefaultEmptyLandmarks() {
        let category = LandmarkCategory(name: "Cafes")
        #expect(category.landmarks.isEmpty)
    }

    @MainActor @Test func testUniqueUpsert() throws {

        // Set up in-memory persistence container
        let configInMemory = ModelConfiguration(
            isStoredInMemoryOnly: true
        )
        let container = try ModelContainer(
            for: LandmarkCategory.self,
            configurations: configInMemory
        )
        let descriptor = FetchDescriptor<LandmarkCategory>()

        // Start out with no categories
        var allCategories = try container.mainContext.fetch(descriptor)

        #expect(allCategories.isEmpty)

        let cafes = LandmarkCategory(name: "Cafes")

        // Add a category
        container.mainContext.insert(cafes)
        allCategories = try container.mainContext.fetch(descriptor)

        #expect(allCategories.count == 1)

        // Insert a second instance with the same name
        let cafesAgain = LandmarkCategory(name: "Cafes")
        container.mainContext.insert(cafesAgain)
        allCategories = try container.mainContext.fetch(descriptor)

        #expect(allCategories.count == 1)
    }
}
