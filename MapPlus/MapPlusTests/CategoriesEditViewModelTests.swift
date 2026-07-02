//
//  CategoriesEditViewModelTests.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 4/25/26.
//

import Testing
import SwiftData
@testable import MapPlus
import Foundation

@Suite("CategoriesEditViewModel Tests")
@MainActor
struct CategoriesEditViewModelTests {
    
    // MARK: - Helper Methods
    
    /// Creates an in-memory model container for testing
    private func makeTestContainer() throws -> ModelContainer {
        let schema = Schema([
            LandmarkCategory.self,
            Landmark.self
        ])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [config])
    }
    
    /// Creates a view model with a fresh test container
    private func makeViewModel() throws -> (CategoriesEditViewModel, ModelContext) {
        let container = try makeTestContainer()
        let context = ModelContext(container)
        let viewModel = CategoriesEditViewModel(modelContext: context)
        return (viewModel, context)
    }
    
    /// Fetches all categories from the context
    private func fetchAllCategories(from context: ModelContext) throws -> [LandmarkCategory] {
        let descriptor = FetchDescriptor<LandmarkCategory>(sortBy: [SortDescriptor(\LandmarkCategory.name)])
        return try context.fetch(descriptor)
    }
    
    // MARK: - Initialization Tests
    
    @Test("ViewModel initializes with empty state")
    func testInitialization() throws {
        let (viewModel, _) = try makeViewModel()
        
        #expect(viewModel.newCategoryName == "")
        #expect(viewModel.editingCategory == nil)
        #expect(viewModel.editedName == "")
        #expect(viewModel.showingDeleteAlert == nil)
    }
    
    // MARK: - Add Category Tests
    
    @Test("Add category successfully")
    func testAddCategorySuccess() throws {
        let (viewModel, context) = try makeViewModel()
        
        viewModel.newCategoryName = "Restaurants"
        let result = viewModel.addCategory(allCategories: [])
        
        #expect(result == true)
        #expect(viewModel.newCategoryName == "") // Should clear after adding
        
        let categories = try fetchAllCategories(from: context)
        #expect(categories.count == 1)
        #expect(categories.first?.name == "Restaurants")
    }
    
    @Test("Add category with trimmed whitespace")
    func testAddCategoryTrimsWhitespace() throws {
        let (viewModel, context) = try makeViewModel()
        
        viewModel.newCategoryName = "  Cafes  "
        let result = viewModel.addCategory(allCategories: [])
        
        #expect(result == true)
        
        let categories = try fetchAllCategories(from: context)
        #expect(categories.count == 1)
        #expect(categories.first?.name == "Cafes") // Trimmed
    }
    
    @Test("Add category fails with empty or whitespace-only name", arguments: ["", " ", "   "])
    func testAddCategoryFailsWithInvalidName(invalidName: String) throws {
        let (viewModel, context) = try makeViewModel()

        viewModel.newCategoryName = invalidName
        let result = viewModel.addCategory(allCategories: [])

        #expect(result == false)

        let categories = try fetchAllCategories(from: context)
        #expect(categories.isEmpty)
    }
    
    @Test("Add category fails with duplicate name")
    func testAddCategoryFailsWithDuplicate() throws {
        let (viewModel, context) = try makeViewModel()
        
        // Add first category
        let existing = LandmarkCategory(name: "Hotels")
        context.insert(existing)
        try context.save()
        
        // Try to add duplicate
        viewModel.newCategoryName = "Hotels"
        let result = viewModel.addCategory(allCategories: [existing])
        
        #expect(result == false)
        
        let categories = try fetchAllCategories(from: context)
        #expect(categories.count == 1) // Still only one
    }
    
    @Test("Add category fails with duplicate name (case insensitive)")
    func testAddCategoryFailsWithDuplicateCaseInsensitive() throws {
        let (viewModel, context) = try makeViewModel()
        
        let existing = LandmarkCategory(name: "Museums")
        context.insert(existing)
        try context.save()
        
        // Try to add with different case
        viewModel.newCategoryName = "MUSEUMS"
        let result = viewModel.addCategory(allCategories: [existing])
        
        #expect(result == false)
        
        let categories = try fetchAllCategories(from: context)
        #expect(categories.count == 1)
    }
    
    @Test("Add multiple categories")
    func testAddMultipleCategories() throws {
        let (viewModel, context) = try makeViewModel()
        
        // Add first category
        viewModel.newCategoryName = "Parks"
        var result = viewModel.addCategory(allCategories: [])
        #expect(result == true)
        
        var categories = try fetchAllCategories(from: context)
        
        // Add second category
        viewModel.newCategoryName = "Beaches"
        result = viewModel.addCategory(allCategories: categories)
        #expect(result == true)
        
        categories = try fetchAllCategories(from: context)
        #expect(categories.count == 2)
        #expect(categories.map(\.name).sorted() == ["Beaches", "Parks"])
    }
    
    // MARK: - Edit Category Tests
    
    @Test("Start editing a category")
    func testStartEditing() throws {
        let (viewModel, _) = try makeViewModel()
        
        let category = LandmarkCategory(name: "Shopping")
        viewModel.startEditing(category)
        
        #expect(viewModel.editingCategory?.id == category.id)
        #expect(viewModel.editedName == "Shopping")
    }
    
    @Test("Save edit successfully")
    func testSaveEditSuccess() throws {
        let (viewModel, context) = try makeViewModel()
        
        let category = LandmarkCategory(name: "Theaters")
        context.insert(category)
        try context.save()
        
        viewModel.startEditing(category)
        viewModel.editedName = "Movie Theaters"
        
        let result = viewModel.saveEdit(for: category, allCategories: [category])
        
        #expect(result == true)
        #expect(category.name == "Movie Theaters")
        #expect(viewModel.editingCategory == nil) // Should clear editing state
        #expect(viewModel.editedName == "")
    }
    
    @Test("Save edit trims whitespace")
    func testSaveEditTrimsWhitespace() throws {
        let (viewModel, context) = try makeViewModel()
        
        let category = LandmarkCategory(name: "Gyms")
        context.insert(category)
        try context.save()
        
        viewModel.startEditing(category)
        viewModel.editedName = "  Fitness Centers  "
        
        let result = viewModel.saveEdit(for: category, allCategories: [category])
        
        #expect(result == true)
        #expect(category.name == "Fitness Centers")
    }
    
    @Test("Save edit fails with empty name")
    func testSaveEditFailsWithEmptyName() throws {
        let (viewModel, context) = try makeViewModel()
        
        let category = LandmarkCategory(name: "Libraries")
        context.insert(category)
        try context.save()
        
        viewModel.startEditing(category)
        viewModel.editedName = ""
        
        let result = viewModel.saveEdit(for: category, allCategories: [category])
        
        #expect(result == false)
        #expect(category.name == "Libraries") // Name unchanged
    }
    
    @Test("Save edit fails with duplicate name")
    func testSaveEditFailsWithDuplicateName() throws {
        let (viewModel, context) = try makeViewModel()
        
        let category1 = LandmarkCategory(name: "Coffee Shops")
        let category2 = LandmarkCategory(name: "Bakeries")
        context.insert(category1)
        context.insert(category2)
        try context.save()
        
        viewModel.startEditing(category1)
        viewModel.editedName = "Bakeries" // Try to use existing name
        
        let result = viewModel.saveEdit(for: category1, allCategories: [category1, category2])
        
        #expect(result == false)
        #expect(category1.name == "Coffee Shops") // Name unchanged
    }
    
    @Test("Save edit allows same name (case sensitive)")
    func testSaveEditAllowsSameName() throws {
        let (viewModel, context) = try makeViewModel()
        
        let category = LandmarkCategory(name: "Galleries")
        context.insert(category)
        try context.save()
        
        viewModel.startEditing(category)
        viewModel.editedName = "Galleries" // Same name
        
        let result = viewModel.saveEdit(for: category, allCategories: [category])
        
        #expect(result == true)
        #expect(category.name == "Galleries")
    }
    
    @Test("Cancel edit clears state")
    func testCancelEdit() throws {
        let (viewModel, _) = try makeViewModel()
        
        let category = LandmarkCategory(name: "Bookstores")
        viewModel.startEditing(category)
        viewModel.editedName = "Book Shops"
        
        viewModel.cancelEdit()
        
        #expect(viewModel.editingCategory == nil)
        #expect(viewModel.editedName == "")
        #expect(category.name == "Bookstores") // Original name unchanged
    }
    
    // MARK: - Delete Category Tests
    
    @Test("Delete category successfully")
    func testDeleteCategorySuccess() throws {
        let (viewModel, context) = try makeViewModel()
        
        let category = LandmarkCategory(name: "Playgrounds")
        context.insert(category)
        try context.save()
        
        let result = viewModel.deleteCategory(category)
        
        #expect(result == true)
        
        let categories = try fetchAllCategories(from: context)
        #expect(categories.isEmpty)
    }
    
    @Test("Delete one of multiple categories")
    func testDeleteOneOfMultipleCategories() throws {
        let (viewModel, context) = try makeViewModel()
        
        let category1 = LandmarkCategory(name: "Sports")
        let category2 = LandmarkCategory(name: "Music")
        let category3 = LandmarkCategory(name: "Art")
        context.insert(category1)
        context.insert(category2)
        context.insert(category3)
        try context.save()
        
        let result = viewModel.deleteCategory(category2)
        
        #expect(result == true)
        
        let categories = try fetchAllCategories(from: context)
        #expect(categories.count == 2)
        #expect(categories.map(\.name).sorted() == ["Art", "Sports"])
    }
    
    @Test("Show delete alert sets category")
    func testShowDeleteAlert() throws {
        let (viewModel, _) = try makeViewModel()
        
        let category = LandmarkCategory(name: "Events")
        viewModel.showingDeleteAlert = category
        
        #expect(viewModel.showingDeleteAlert?.id == category.id)
    }
    
    @Test("Clear delete alert")
    func testClearDeleteAlert() throws {
        let (viewModel, _) = try makeViewModel()
        
        let category = LandmarkCategory(name: "Food Trucks")
        viewModel.showingDeleteAlert = category
        
        viewModel.showingDeleteAlert = nil
        
        #expect(viewModel.showingDeleteAlert == nil)
    }
    
    // MARK: - Integration Tests
    
    @Test("Complete workflow: add, edit, delete")
    func testCompleteWorkflow() throws {
        let (viewModel, context) = try makeViewModel()
        
        // Add a category
        viewModel.newCategoryName = "Hiking Trails"
        var result = viewModel.addCategory(allCategories: [])
        #expect(result == true)
        
        var categories = try fetchAllCategories(from: context)
        #expect(categories.count == 1)
        
        let category = try #require(categories.first)
        
        // Edit the category
        viewModel.startEditing(category)
        viewModel.editedName = "Nature Trails"
        result = viewModel.saveEdit(for: category, allCategories: categories)
        #expect(result == true)
        #expect(category.name == "Nature Trails")
        
        // Delete the category
        result = viewModel.deleteCategory(category)
        #expect(result == true)
        
        categories = try fetchAllCategories(from: context)
        #expect(categories.isEmpty)
    }
    
    @Test("Multiple edits on same category")
    func testMultipleEditsOnSameCategory() throws {
        let (viewModel, context) = try makeViewModel()
        
        let category = LandmarkCategory(name: "Original")
        context.insert(category)
        try context.save()
        
        // First edit
        viewModel.startEditing(category)
        viewModel.editedName = "First Edit"
        var result = viewModel.saveEdit(for: category, allCategories: [category])
        #expect(result == true)
        #expect(category.name == "First Edit")
        
        // Second edit
        viewModel.startEditing(category)
        viewModel.editedName = "Second Edit"
        result = viewModel.saveEdit(for: category, allCategories: [category])
        #expect(result == true)
        #expect(category.name == "Second Edit")
    }
}
