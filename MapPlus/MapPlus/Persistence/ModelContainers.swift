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
        let container = try! ModelContainer(for: Landmark.self, configurations: config)
//        container.mainContext.autosaveEnabled = false
        
        for category in SampleCategories().all {
            container.mainContext.insert(category)
        }
        try container.mainContext.save()
        
        return container
    }

    @MainActor
    // TODO patmcg doc
    static func inMemorySampleContainer() throws -> ModelContainer {
        
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Landmark.self, configurations: config)
//        container.mainContext.autosaveEnabled = false

        for landmark in SampleLandmarks().austinPlaces {
            container.mainContext.insert(landmark)
        }
        
        try container.mainContext.save()
        
        return container
    }
}
