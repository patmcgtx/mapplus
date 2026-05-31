//
//  ModelContainers.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/7/26.
//
import SwiftData

extension ModelContainer {
        
    @MainActor
    // TODO patmcg doc
    static func persistentContainer() throws -> ModelContainer {
        let config = ModelConfiguration()
        let container = try! ModelContainer(
            for: Landmark.self, SelectedCategories.self,
            configurations: config
        )
        
        // Only insert sample categories if the database is empty
        let descriptor = FetchDescriptor<LandmarkCategory>()
        let existingCategories = try container.mainContext.fetch(descriptor)
        
        if existingCategories.isEmpty {
            for category in SampleCategories().all {
                container.mainContext.insert(category)
            }
            try container.mainContext.save()
        }
        
        return container
    }

    /// Create an in-memory persistent container for testing.
    /// All changes are loaded fresh on each app launch and lost on each app exit.
    /// - Parameter category: The category to add
    /// - Parameter numExtraCategories: How many extra categories, beyond the basics, to add to the in-memory database.  This is useful for edge and stress testing.
    @MainActor
    static func inMemorySampleContainer(numExtraCategories: Int = 0) throws -> ModelContainer {
        
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(
            for: Landmark.self, SelectedCategories.self,
            configurations: config
        )

        for landmark in SampleLandmarks().austinPlaces {
            container.mainContext.insert(landmark)
        }
        
        try container.mainContext.save()
        
        for category in SampleCategories().manyCategories(howMany: numExtraCategories) {
            container.mainContext.insert(category)
        }

        try container.mainContext.save()

        return container
    }
}
