// Thanks, Claude Sonnet

import Testing
import SwiftData
@testable import MapPlus

struct LandmarkCategoryTests {

    @Test("LandmarkCategory initialization", arguments: [
        ("Coffee Shops", "#7B4F2E"),
        ("Entertainment", "#7B52AB"),
        ("Family", "#3A7BD5"),
        ("Travel", "#1A9E9E"),
    ])
    func testInitialization(name: String, colorHex: String) {
        let category = LandmarkCategory(name: name, colorHex: colorHex)
        #expect(category.name == name)
        #expect(category.colorHex == colorHex)
        #expect(category.landmarks.isEmpty)
    }

    @MainActor @Test func testPersistence() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: Landmark.self, LandmarkCategory.self,
            configurations: config
        )
        let ctx = container.mainContext

        let category = LandmarkCategory(name: "Work", colorHex: "#2E8B57")
        ctx.insert(category)
        try ctx.save()

        let fetched = try ctx.fetch(FetchDescriptor<LandmarkCategory>())
        #expect(fetched.count == 1)
        #expect(fetched.first?.name == "Work")
        #expect(fetched.first?.colorHex == "#2E8B57")
    }

    @MainActor @Test func testLandmarkCategoryRelationship() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: Landmark.self, LandmarkCategory.self,
            configurations: config
        )
        let ctx = container.mainContext

        let category = LandmarkCategory(name: "Coffee Shops", colorHex: "#7B4F2E")
        ctx.insert(category)

        let landmark = LandmarkSampleData().coffee
        landmark.categories = [category]
        ctx.insert(landmark)
        try ctx.save()

        let fetchedLandmarks = try ctx.fetch(FetchDescriptor<Landmark>())
        #expect(fetchedLandmarks.count == 1)
        #expect(fetchedLandmarks.first?.categories.count == 1)
        #expect(fetchedLandmarks.first?.categories.first?.name == "Coffee Shops")
    }

    @Test func testSampleDataHasAllCategories() {
        let samples = CategorySampleData()
        #expect(samples.all.count == 8)
        let names = samples.all.map { $0.name }
        #expect(names.contains("Coffee Shops"))
        #expect(names.contains("Entertainment"))
        #expect(names.contains("Family"))
        #expect(names.contains("Work"))
        #expect(names.contains("Travel"))
    }
}
