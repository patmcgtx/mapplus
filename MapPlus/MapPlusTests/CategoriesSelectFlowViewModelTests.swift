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
        
    @MainActor @Test("Initially has no selected categories")
    func initiallyNoSelections() throws {
        let container = try makeTestContainer()
        let context = container.mainContext
        
        let service = CategorySelectionService(modelContext: context)
        let viewModel = CategoriesSelectFlowViewModel(service: service)
        
        #expect(viewModel.hasSelectedCategories == false)

        let descriptor = FetchDescriptor<SelectedCategories>()
        let selections = try context.fetch(descriptor)
         
        // Service lazily creates a SelectedCategories model on first access
        #expect(selections.count == 1)
        #expect(!selections.isEmpty)
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
        
        // Create service and view model
        let service = CategorySelectionService(modelContext: context)
        let viewModel = CategoriesSelectFlowViewModel(service: service)
        
        // Initially should have selections
        #expect(viewModel.hasSelectedCategories == true)
        
        // Clear all
        viewModel.clearAllSelections()
        
        // Should be empty now
        #expect(viewModel.hasSelectedCategories == false)
    }

    @MainActor @Test("Filter mode state comes from the service")
    func filterModeState() throws {
        let container = try makeTestContainer()
        let context = container.mainContext

        let category1 = LandmarkCategory(name: "Cafes")
        let category2 = LandmarkCategory(name: "Museums")
        let selection = SelectedCategories(categories: [category1, category2], filterMode: .matchAny)
        context.insert(category1)
        context.insert(category2)
        context.insert(selection)
        try context.save()

        let service = CategorySelectionService(modelContext: context)
        let viewModel = CategoriesSelectFlowViewModel(service: service)

        #expect(viewModel.shouldShowFilterModePicker)
        #expect(viewModel.filterMode == .matchAny)
        #expect(viewModel.filterModeExplanationKey == "match-any-explanation")

        viewModel.setFilterMode(.matchAll)

        #expect(viewModel.filterMode == .matchAll)
        #expect(viewModel.filterModeExplanationKey == "match-all-explanation")
    }
    
}
