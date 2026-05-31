//
//  CategoriesSelectFlowViewModelTests.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 5/30/26.
//

import Testing
import SwiftData
@testable import MapPlus

@Suite("Categories Selection ViewModel Tests")
struct CategoriesSelectFlowViewModelTests {
    
    // MARK: - Helper
    
    /// Creates an in-memory model container for testing
    private func makeTestContainer() throws -> ModelContainer {
        let schema = Schema([
            LandmarkCategory.self,
            SelectedCategories.self,
            Landmark.self
        ])
        
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )
        
        return try ModelContainer(for: schema, configurations: [configuration])
    }
    
    // MARK: - Tests
    
    @MainActor @Test("Loading categories fetches from model context")
    func loadCategories() throws {
        let container = try makeTestContainer()
        let context = container.mainContext
        
        // Insert test categories
        let category1 = LandmarkCategory(name: "Cafes")
        let category2 = LandmarkCategory(name: "Museums")
        context.insert(category1)
        context.insert(category2)
        try context.save()
        
        // Create view model and load
        let viewModel = CategoriesSelectFlowViewModel(modelContext: context)
        viewModel.loadCategories()
        
        // Verify
        #expect(viewModel.allCategories.count == 2)
        #expect(viewModel.allCategories.contains { $0.name == "Cafes" })
        #expect(viewModel.allCategories.contains { $0.name == "Museums" })
    }
    
    @MainActor @Test("Initially has no selected categories")
    func initiallyNoSelections() throws {
        let container = try makeTestContainer()
        let context = container.mainContext
        
        let viewModel = CategoriesSelectFlowViewModel(modelContext: context)
        
        #expect(viewModel.hasSelectedCategories == false)
    }
    
    @MainActor @Test("Clear all selections removes all categories")
    func clearAllSelections() throws {
        let container = try makeTestContainer()
        let context = container.mainContext
        
        // Create categories
        let category1 = LandmarkCategory(name: "Cafes")
        let category2 = LandmarkCategory(name: "Museums")
        context.insert(category1)
        context.insert(category2)
        
        // Create selection model with categories
        let selection = SelectedCategories(categories: [category1, category2])
        context.insert(selection)
        try context.save()
        
        // Create view model
        let viewModel = CategoriesSelectFlowViewModel(modelContext: context)
        
        // Initially should have selections
        #expect(viewModel.hasSelectedCategories == true)
        
        // Clear all
        viewModel.clearAllSelections()
        
        // Should be empty now
        #expect(viewModel.hasSelectedCategories == false)
    }
    
    @MainActor @Test("Categories are sorted by name")
    func categoriesSortedByName() throws {
        let container = try makeTestContainer()
        let context = container.mainContext
        
        // Insert in random order
        let categoryC = LandmarkCategory(name: "Zoos")
        let categoryA = LandmarkCategory(name: "Cafes")
        let categoryB = LandmarkCategory(name: "Museums")
        context.insert(categoryC)
        context.insert(categoryA)
        context.insert(categoryB)
        try context.save()
        
        // Load and verify sorting
        let viewModel = CategoriesSelectFlowViewModel(modelContext: context)
        viewModel.loadCategories()
        
        #expect(viewModel.allCategories.count == 3)
        #expect(viewModel.allCategories[0].name == "Cafes")
        #expect(viewModel.allCategories[1].name == "Museums")
        #expect(viewModel.allCategories[2].name == "Zoos")
    }
}
