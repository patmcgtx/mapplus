//
//  ModelContainers.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/7/26.
//
import SwiftData

extension ModelContainer {
        
    @MainActor
    static func persistentContainer() throws -> ModelContainer {
        let config = ModelConfiguration()
        let container = try! ModelContainer(for: Landmark.self, configurations: config)
        return container
    }

    @MainActor
    static func inMemorySampleContainer() throws -> ModelContainer {
        
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Landmark.self, configurations: config)
        
        for landmark in LandmarkSampleData().austinPlaces {
            container.mainContext.insert(landmark)
        }
        
        try container.mainContext.save()
        
        return container
    }
}
