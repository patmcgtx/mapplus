// Thanks, Claude Sonnet

import Testing
import MapKit
import SwiftData
@testable import MapPlus

@MainActor
struct LandmarkStoreTests {
    
    // MARK: - Helpers
    
    private func makeContainer() throws -> ModelContainer {
        try ModelContainer(
            for: Landmark.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
    }
    
    private func fetchAll(from context: ModelContext) throws -> [Landmark] {
        try context.fetch(FetchDescriptor<Landmark>())
    }
    
    // MARK: - delete(landmark:) Tests
    
    @Test("Delete removes the landmark from the store") func testDeleteRemovesLandmark() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let store = LandmarkStore(modelContext: context)
        
        let landmark = Landmark(name: "Alamo", symbol: "🏛️",
                                location: .init(latitude: 29.4259, longitude: -98.4861))
        try store.commit(landmark: landmark)
        
        var all = try fetchAll(from: context)
        #expect(all.count == 1)
        
        try store.delete(landmark: landmark)
        
        all = try fetchAll(from: context)
        #expect(all.isEmpty, "Store should be empty after deleting the only landmark")
    }
    
    @Test("Delete removes only the target landmark") func testDeleteRemovesOnlyTargetLandmark() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let store = LandmarkStore(modelContext: context)
        
        let first = Landmark(name: "Space Needle", symbol: "🗼",
                             location: .init(latitude: 47.6205, longitude: -122.3493))
        let second = Landmark(name: "Pike Place Market", symbol: "🐟",
                              location: .init(latitude: 47.6090, longitude: -122.3420))
        try store.commit(landmark: first)
        try store.commit(landmark: second)
        
        var all = try fetchAll(from: context)
        #expect(all.count == 2)
        
        try store.delete(landmark: first)
        
        all = try fetchAll(from: context)
        #expect(all.count == 1, "Only the deleted landmark should be removed")
        #expect(all.first?.name == "Pike Place Market",
                "The remaining landmark should be the one that was not deleted")
    }
    
    @Test("Delete persists after re-fetch") func testDeletePersistsAfterFetch() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let store = LandmarkStore(modelContext: context)
        
        let landmark = Landmark(name: "Wrigley Field", symbol: "⚾",
                                location: .init(latitude: 41.9484, longitude: -87.6553))
        try store.commit(landmark: landmark)
        try store.delete(landmark: landmark)
        
        // Re-fetch to confirm deletion was saved
        let all = try fetchAll(from: context)
        #expect(all.isEmpty, "Deletion should persist in the model context")
    }
    
    // MARK: - commit(landmark:) Tests
    
    @Test("Commit inserts a landmark into the context") func testCommitInsertsLandmark() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let store = LandmarkStore(modelContext: context)
        
        let landmark = Landmark(name: "Fenway Park", symbol: "⚾",
                                location: .init(latitude: 42.3467, longitude: -71.0972))
        try store.commit(landmark: landmark)
        
        let all = try fetchAll(from: context)
        #expect(all.count == 1)
        #expect(all.first?.name == "Fenway Park")
    }
}
