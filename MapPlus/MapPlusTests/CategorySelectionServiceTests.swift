//
//  CategorySelectionServiceTests.swift
//  MapPlusTests
//
//  Created by Patrick McGonigle on 5/31/26.
//

import Testing
import SwiftData
import CoreLocation
@testable import MapPlus

@Suite("Category Selection Service Tests")
struct CategorySelectionServiceTests {
    
    // MARK: - Helper Methods
    
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
    
    /// Creates test categories
    private func createTestCategories(in context: ModelContext) -> (LandmarkCategory, LandmarkCategory, LandmarkCategory) {
        let parks = LandmarkCategory(name: "Parks")
        let museums = LandmarkCategory(name: "Museums")
        let cafes = LandmarkCategory(name: "Cafes")
        
        context.insert(parks)
        context.insert(museums)
        context.insert(cafes)
        
        return (parks, museums, cafes)
    }
    
    /// Creates test landmarks
    private func createTestLandmarks(
        in context: ModelContext,
        parks: LandmarkCategory,
        museums: LandmarkCategory,
        cafes: LandmarkCategory
    ) -> (Landmark, Landmark, Landmark, Landmark) {
        let landmark1 = Landmark(
            name: "Golden Gate Park",
            location: CLLocationCoordinate2D(latitude: 37.7694, longitude: -122.4862),
            categories: [parks]
        )
        
        let landmark2 = Landmark(
            name: "SFMOMA",
            location: CLLocationCoordinate2D(latitude: 37.7857, longitude: -122.4011),
            categories: [museums]
        )
        
        let landmark3 = Landmark(
            name: "Blue Bottle Cafe",
            location: CLLocationCoordinate2D(latitude: 37.7955, longitude: -122.3937),
            categories: [cafes, museums] // Has both categories
        )
        
        let landmark4 = Landmark(
            name: "Park Museum Cafe",
            location: CLLocationCoordinate2D(latitude: 37.8044, longitude: -122.4058),
            categories: [parks, museums, cafes] // Has all three
        )
        
        context.insert(landmark1)
        context.insert(landmark2)
        context.insert(landmark3)
        context.insert(landmark4)
        
        return (landmark1, landmark2, landmark3, landmark4)
    }
    
    // MARK: - Initialization Tests
    
    @MainActor @Test("Service initializes with no selections")
    func initializesEmpty() throws {
        let container = try makeTestContainer()
        let context = container.mainContext
        
        let service = CategorySelectionService(modelContext: context)
        
        #expect(service.hasSelectedCategories == false)
        #expect(service.selectedCategories.isEmpty)
        #expect(service.filterMode == .matchAny)
        #expect(service.shouldShowFilterModePicker == false)
    }
    
    @MainActor @Test("Service loads existing selections")
    func loadsExistingSelections() throws {
        let container = try makeTestContainer()
        let context = container.mainContext
        
        let (parks, museums, _) = createTestCategories(in: context)
        
        // Create pre-existing selection
        let selection = SelectedCategories(categories: [parks, museums], filterMode: .matchAll)
        context.insert(selection)
        try context.save()
        
        // Create service - should load existing selection
        let service = CategorySelectionService(modelContext: context)
        
        #expect(service.hasSelectedCategories == true)
        #expect(service.selectedCategories.count == 2)
        #expect(service.filterMode == .matchAll)
        #expect(service.shouldShowFilterModePicker == true)
    }
    
    // MARK: - Selection Tests
    
    @MainActor @Test("Toggle adds category when not selected")
    func toggleAddsCategory() throws {
        let container = try makeTestContainer()
        let context = container.mainContext
        
        let (parks, _, _) = createTestCategories(in: context)
        let service = CategorySelectionService(modelContext: context)
        
        #expect(service.isSelected(parks) == false)
        
        service.toggle(parks)
        
        #expect(service.isSelected(parks) == true)
        #expect(service.hasSelectedCategories == true)
        #expect(service.selectedCategories.contains(parks))
    }
    
    @MainActor @Test("Toggle removes category when selected")
    func toggleRemovesCategory() throws {
        let container = try makeTestContainer()
        let context = container.mainContext
        
        let (parks, _, _) = createTestCategories(in: context)
        let service = CategorySelectionService(modelContext: context)
        
        // Add category
        service.toggle(parks)
        #expect(service.isSelected(parks) == true)
        
        // Remove category
        service.toggle(parks)
        #expect(service.isSelected(parks) == false)
        #expect(service.hasSelectedCategories == false)
    }
    
    @MainActor @Test("Clear all selections removes all categories")
    func clearAllSelections() throws {
        let container = try makeTestContainer()
        let context = container.mainContext
        
        let (parks, museums, cafes) = createTestCategories(in: context)
        let service = CategorySelectionService(modelContext: context)
        
        // Add multiple categories
        service.toggle(parks)
        service.toggle(museums)
        service.toggle(cafes)
        
        #expect(service.selectedCategories.count == 3)
        
        // Clear all
        service.clearAllSelections()
        
        #expect(service.selectedCategories.isEmpty)
        #expect(service.hasSelectedCategories == false)
    }
    
    // MARK: - Filter Mode Tests
    
    @MainActor @Test("Setting filter mode updates state")
    func setFilterMode() throws {
        let container = try makeTestContainer()
        let context = container.mainContext
        
        let service = CategorySelectionService(modelContext: context)
        
        #expect(service.filterMode == .matchAny)
        
        service.setFilterMode(.matchAll)
        
        #expect(service.filterMode == .matchAll)
    }
    
    @MainActor @Test("Filter mode persists across service instances")
    func filterModePersists() throws {
        let container = try makeTestContainer()
        let context = container.mainContext
        
        // Create first service and set filter mode
        let service1 = CategorySelectionService(modelContext: context)
        service1.setFilterMode(.matchAll)
        
        // Create second service - should load persisted mode
        let service2 = CategorySelectionService(modelContext: context)
        
        #expect(service2.filterMode == .matchAll)
    }
    
    @MainActor @Test("Should show filter mode picker with 2+ categories")
    func shouldShowFilterModePicker() throws {
        let container = try makeTestContainer()
        let context = container.mainContext
        
        let (parks, museums, _) = createTestCategories(in: context)
        let service = CategorySelectionService(modelContext: context)
        
        // 0 categories - don't show
        #expect(service.shouldShowFilterModePicker == false)
        
        // 1 category - don't show
        service.toggle(parks)
        #expect(service.shouldShowFilterModePicker == false)
        
        // 2 categories - show
        service.toggle(museums)
        #expect(service.shouldShowFilterModePicker == true)
    }
    
    // MARK: - Filtering Tests - Match Any
    
    @MainActor @Test("Filter landmarks with match any mode")
    func filterLandmarksMatchAny() throws {
        let container = try makeTestContainer()
        let context = container.mainContext
        
        let (parks, museums, cafes) = createTestCategories(in: context)
        let (landmark1, landmark2, landmark3, landmark4) = createTestLandmarks(
            in: context,
            parks: parks,
            museums: museums,
            cafes: cafes
        )
        
        let service = CategorySelectionService(modelContext: context)
        service.setFilterMode(.matchAny)
        
        // Select parks and museums
        service.toggle(parks)
        service.toggle(museums)
        
        let allLandmarks = [landmark1, landmark2, landmark3, landmark4]
        let filtered = service.filterLandmarks(allLandmarks)
        
        // Should include landmarks with parks OR museums
        // landmark1: parks ✓
        // landmark2: museums ✓
        // landmark3: cafes + museums ✓
        // landmark4: all three ✓
        #expect(filtered.count == 4)
        #expect(filtered.contains(landmark1))
        #expect(filtered.contains(landmark2))
        #expect(filtered.contains(landmark3))
        #expect(filtered.contains(landmark4))
    }
    
    @MainActor @Test("Filter landmarks with match any excludes non-matching")
    func filterLandmarksMatchAnyExcludesNonMatching() throws {
        let container = try makeTestContainer()
        let context = container.mainContext
        
        let (parks, museums, cafes) = createTestCategories(in: context)
        let (landmark1, landmark2, landmark3, landmark4) = createTestLandmarks(
            in: context,
            parks: parks,
            museums: museums,
            cafes: cafes
        )
        
        let service = CategorySelectionService(modelContext: context)
        service.setFilterMode(.matchAny)
        
        // Select only cafes
        service.toggle(cafes)
        
        let allLandmarks = [landmark1, landmark2, landmark3, landmark4]
        let filtered = service.filterLandmarks(allLandmarks)
        
        // Should only include landmarks with cafes
        // landmark1: parks only ✗
        // landmark2: museums only ✗
        // landmark3: cafes + museums ✓
        // landmark4: all three ✓
        #expect(filtered.count == 2)
        #expect(filtered.contains(landmark3))
        #expect(filtered.contains(landmark4))
    }
    
    // MARK: - Filtering Tests - Match All
    
    @MainActor @Test("Filter landmarks with match all mode")
    func filterLandmarksMatchAll() throws {
        let container = try makeTestContainer()
        let context = container.mainContext
        
        let (parks, museums, cafes) = createTestCategories(in: context)
        let (landmark1, landmark2, landmark3, landmark4) = createTestLandmarks(
            in: context,
            parks: parks,
            museums: museums,
            cafes: cafes
        )
        
        let service = CategorySelectionService(modelContext: context)
        service.setFilterMode(.matchAll)
        
        // Select cafes and museums
        service.toggle(cafes)
        service.toggle(museums)
        
        let allLandmarks = [landmark1, landmark2, landmark3, landmark4]
        let filtered = service.filterLandmarks(allLandmarks)
        
        // Should only include landmarks with BOTH cafes AND museums
        // landmark1: parks only ✗
        // landmark2: museums only ✗
        // landmark3: cafes + museums ✓
        // landmark4: all three ✓
        #expect(filtered.count == 2)
        #expect(filtered.contains(landmark3))
        #expect(filtered.contains(landmark4))
    }
    
    @MainActor @Test("Filter landmarks with match all requires all categories")
    func filterLandmarksMatchAllRequiresAll() throws {
        let container = try makeTestContainer()
        let context = container.mainContext
        
        let (parks, museums, cafes) = createTestCategories(in: context)
        let (landmark1, landmark2, landmark3, landmark4) = createTestLandmarks(
            in: context,
            parks: parks,
            museums: museums,
            cafes: cafes
        )
        
        let service = CategorySelectionService(modelContext: context)
        service.setFilterMode(.matchAll)
        
        // Select all three categories
        service.toggle(parks)
        service.toggle(cafes)
        service.toggle(museums)
        
        let allLandmarks = [landmark1, landmark2, landmark3, landmark4]
        let filtered = service.filterLandmarks(allLandmarks)
        
        // Should only include landmarks with ALL three
        // landmark1: parks only ✗
        // landmark2: museums only ✗
        // landmark3: cafes + museums ✗ (missing parks)
        // landmark4: all three ✓
        #expect(filtered.count == 1)
        #expect(filtered.contains(landmark4))
    }
    
    @MainActor @Test("Filter with no selections returns all landmarks")
    func filterWithNoSelectionsReturnsAll() throws {
        let container = try makeTestContainer()
        let context = container.mainContext
        
        let (parks, museums, cafes) = createTestCategories(in: context)
        let (landmark1, landmark2, landmark3, landmark4) = createTestLandmarks(
            in: context,
            parks: parks,
            museums: museums,
            cafes: cafes
        )
        
        let service = CategorySelectionService(modelContext: context)
        
        let allLandmarks = [landmark1, landmark2, landmark3, landmark4]
        let filtered = service.filterLandmarks(allLandmarks)
        
        #expect(filtered.count == 4)
    }
    
}
