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
        let container = try! ModelContainer(for: Landmark.self, LandmarkCategory.self, configurations: config)
        return container
    }

    @MainActor
    // TODO patmcg doc
    static func inMemorySampleContainer() throws -> ModelContainer {
        
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Landmark.self, LandmarkCategory.self, configurations: config)
        
        // Create and insert all sample categories first so we can assign them to landmarks
        let categories = CategorySampleData().all
        for category in categories {
            container.mainContext.insert(category)
        }
        
        // Helper to look up an inserted category by name
        func category(named name: String) -> LandmarkCategory? {
            categories.first { $0.name == name }
        }

        let sampleLandmarks = LandmarkSampleData()

        let capital = sampleLandmarks.capital
        if let travel = category(named: "Travel") {
            capital.categories = [travel]
        }
        container.mainContext.insert(capital)

        let coffee = sampleLandmarks.coffee
        if let coffeeShops = category(named: "Coffee Shops"),
           let work = category(named: "Work") {
            coffee.categories = [coffeeShops, work]
        }
        container.mainContext.insert(coffee)

        let school = sampleLandmarks.school
        container.mainContext.insert(school)

        let work = sampleLandmarks.work
        if let workCat = category(named: "Work") {
            work.categories = [workCat]
        }
        container.mainContext.insert(work)
        
        try container.mainContext.save()
        
        return container
    }
}
