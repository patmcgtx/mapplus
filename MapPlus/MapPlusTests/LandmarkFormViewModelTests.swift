//
//  LandmarkFormViewModelTests.swift
//  MapPlusTests
//

import Testing
import MapKit
import SwiftData
@testable import MapPlus

@MainActor
struct LandmarkFormViewModelTests {

    // MARK: - Initial state

    @Test func testInitialAddressSearchState() {
        let viewModel = LandmarkFormViewModel(
            mode: .create,
            suggestionsService: BasicMapItemSuggestionService()
        )
        if case .searchInitial = viewModel.addressSearchState {
            // Expected
        } else {
            Issue.record("Expected .searchInitial, got \(viewModel.addressSearchState)")
        }
    }

    @Test func testInitialSaveState() {
        let viewModel = LandmarkFormViewModel(
            mode: .create,
            suggestionsService: BasicMapItemSuggestionService()
        )
        #expect(viewModel.saveState == .saveInitial)
    }

    @Test func testInitialLocationSearchInput() {
        let viewModel = LandmarkFormViewModel(
            mode: .create,
            suggestionsService: BasicMapItemSuggestionService()
        )
        #expect(viewModel.locationSearchInput == "")
    }

    @Test func testInitialFormFieldsAreEmptyForCreate() {
        let viewModel = LandmarkFormViewModel(
            mode: .create,
            suggestionsService: BasicMapItemSuggestionService()
        )
        #expect(viewModel.name == "")
        #expect(viewModel.symbol == "📍")
        #expect(viewModel.notes == "")
        #expect(viewModel.categories.isEmpty)
    }

    @Test func testInitialFormFieldsArePopulatedForEdit() {
        let category = LandmarkCategory(name: "Museums")
        let landmark = Landmark(
            name: "Statue of Liberty",
            notes: "A gift from France",
            formattedAddress: "New York, NY",
            symbol: "🗽",
            categories: [category]
        )
        let viewModel = LandmarkFormViewModel(
            mode: .edit(landmark),
            suggestionsService: BasicMapItemSuggestionService()
        )
        #expect(viewModel.name == "Statue of Liberty")
        #expect(viewModel.symbol == "🗽")
        #expect(viewModel.notes == "A gift from France")
        #expect(viewModel.categories.count == 1)
        #expect(viewModel.categories.first?.name == "Museums")
    }

    // MARK: - formTitle

    @Test func testFormTitleCreate() {
        let viewModel = LandmarkFormViewModel(
            mode: .create,
            suggestionsService: BasicMapItemSuggestionService()
        )
        #expect(viewModel.formTitle == "new-landmark".localized)
    }

    @Test func testFormTitleEdit() {
        let landmark = Landmark(name: "Golden Gate Bridge")
        let viewModel = LandmarkFormViewModel(
            mode: .edit(landmark),
            suggestionsService: BasicMapItemSuggestionService()
        )
        #expect(viewModel.formTitle == "Golden Gate Bridge")
    }

    // MARK: - isSaveEnabled

    @Test func testIsSaveEnabledInitially() {
        let viewModel = LandmarkFormViewModel(
            mode: .create,
            suggestionsService: BasicMapItemSuggestionService()
        )
        #expect(!viewModel.isSaveEnabled)
    }

    @Test func testIsSaveEnabledWhileSearching() {
        let viewModel = LandmarkFormViewModel(
            mode: .create,
            suggestionsService: BasicMapItemSuggestionService()
        )
        viewModel.addressSearchState = .searching
        #expect(!viewModel.isSaveEnabled)
    }

    @Test func testIsSaveEnabledAfterSearchFailed() {
        let viewModel = LandmarkFormViewModel(
            mode: .create,
            suggestionsService: BasicMapItemSuggestionService()
        )
        viewModel.addressSearchState = .searchFailed(MapPlusError.noAddressFound)
        #expect(!viewModel.isSaveEnabled)
    }

    @Test func testIsSaveEnabledAfterResolvedWithPopulatedName() {
        let viewModel = LandmarkFormViewModel(
            mode: .create,
            suggestionsService: BasicMapItemSuggestionService()
        )
        viewModel.name = "My Place"
        viewModel.addressSearchState = .searchResolved(LocationInfo(briefDescription: "", fullDescription: "", latitude: 0.0, longitude: 0.0))
        #expect(viewModel.isSaveEnabled)
    }

    @Test func testIsSaveEnabledAfterResolvedWithEmptyName() {
        let viewModel = LandmarkFormViewModel(
            mode: .create,
            suggestionsService: BasicMapItemSuggestionService()
        )
        viewModel.name = ""
        viewModel.addressSearchState = .searchResolved(LocationInfo(briefDescription: "", fullDescription: "", latitude: 0.0, longitude: 0.0))
        #expect(!viewModel.isSaveEnabled)
    }

    @Test func testIsSaveEnabledAfterResolvedWithWhitespaceOnlyName() {
        let viewModel = LandmarkFormViewModel(
            mode: .create,
            suggestionsService: BasicMapItemSuggestionService()
        )
        viewModel.name = "   "
        viewModel.addressSearchState = .searchResolved(LocationInfo(briefDescription: "", fullDescription: "", latitude: 0.0, longitude: 0.0))
        #expect(!viewModel.isSaveEnabled)
    }

    // MARK: - initializeLocation

    @Test func testInitializeLocationCreateSuccess() async {
        let viewModel = LandmarkFormViewModel(
            mode: .create,
            suggestionsService: BasicMapItemSuggestionService()
        )
        let mockService = MockLocationService()

        await viewModel.initializeLocation(using: mockService)

        if case .searchResolved(let info) = viewModel.addressSearchState {
            #expect(info.briefDescription == "Mock SF")
            #expect(info.fullDescription == "(Mock) San Francisco, CA, United States")
        } else {
            Issue.record("Expected .searchResolved, got \(viewModel.addressSearchState)")
        }
    }

    @Test func testInitializeLocationCreateSuccessDoesNotUpdateLocationSearchInput() async {
        let viewModel = LandmarkFormViewModel(
            mode: .create,
            suggestionsService: BasicMapItemSuggestionService()
        )
        let mockService = MockLocationService()

        await viewModel.initializeLocation(using: mockService)

        #expect(viewModel.locationSearchInput == "")
    }

    @Test func testInitializeLocationCreateSuccessUpdatesCoordinates() async {
        let viewModel = LandmarkFormViewModel(
            mode: .create,
            suggestionsService: BasicMapItemSuggestionService()
        )
        let mockService = MockLocationService()

        await viewModel.initializeLocation(using: mockService)

        // Coordinates are stored internally, but we can verify via the resolved state
        if case .searchResolved(let info) = viewModel.addressSearchState {
            #expect(info.briefDescription == "Mock SF")
            #expect(info.coordinates.latitude == 37.7749)
            #expect(info.coordinates.longitude == -122.4194)
        } else {
            Issue.record("Expected .searchResolved")
        }
    }

    @Test func testInitializeLocationCreateFailureStaysAtInitial() async {
        let viewModel = LandmarkFormViewModel(
            mode: .create,
            suggestionsService: BasicMapItemSuggestionService()
        )
        let mockService = MockLocationService()
        mockService.shouldSucceed = false

        await viewModel.initializeLocation(using: mockService)

        // Location failure on create is silent; state stays at searchInitial
        if case .searchInitial = viewModel.addressSearchState {
            // Expected
        } else {
            Issue.record("Expected .searchInitial, got \(viewModel.addressSearchState)")
        }
    }

    @Test func testInitializeLocationEditPrePopulatesExistingAddress() async {
        let landmark = Landmark(
            name: "Test",
            formattedAddress: "123 Main St",
            location: .init(latitude: 37.77, longitude: -122.41)
        )
        let viewModel = LandmarkFormViewModel(
            mode: .edit(landmark),
            suggestionsService: BasicMapItemSuggestionService()
        )
        let mockService = MockLocationService()

        await viewModel.initializeLocation(using: mockService)

        if case .searchResolved(let info) = viewModel.addressSearchState {
            #expect(info.fullDescription == "123 Main St")
            #expect(info.coordinates.latitude == 37.77)
            #expect(info.coordinates.longitude == -122.41)
        } else {
            Issue.record("Expected .searchResolved, got \(viewModel.addressSearchState)")
        }
    }

    // MARK: - searchByText

    // TODO patmcg re-enable and fix this test
    @Test func testSearchByTextSuccess() async {
        let viewModel = LandmarkFormViewModel(
            mode: .create,
            suggestionsService: BasicMapItemSuggestionService()
        )
        viewModel.locationSearchInput = "San Francisco"
        let mockService = MockAddressLookupService()

        await viewModel.searchByText(using: mockService)

        if case .searchResolved(let info) = viewModel.addressSearchState {
            #expect(info.briefDescription == "San Francisco")
            #expect(viewModel.locationSearchInput == "San Francisco")
            // TODO patmcg fix the check below
//            #expect(info.fullDescription == "San Francisco, CA, United States")
        } else {
            Issue.record("Expected .searchResolved, got \(viewModel.addressSearchState)")
        }
    }

    @Test func testSearchByTextSuccessUpdatesCoordinates() async {
        let viewModel = LandmarkFormViewModel(
            mode: .create,
            suggestionsService: BasicMapItemSuggestionService()
        )
        viewModel.locationSearchInput = "San Francisco"
        let mockService = MockAddressLookupService()

        await viewModel.searchByText(using: mockService)

        if case .searchResolved(let info) = viewModel.addressSearchState {
            #expect(info.briefDescription == "San Francisco")
            #expect(info.coordinates.latitude == 37.7749)
            #expect(info.coordinates.longitude == -122.4194)
        } else {
            Issue.record("Expected .searchResolved")
        }
    }

    @Test func testSearchByTextFailure() async {
        let viewModel = LandmarkFormViewModel(
            mode: .create,
            suggestionsService: BasicMapItemSuggestionService()
        )
        viewModel.locationSearchInput = "Nowhere"
        let mockService = MockAddressLookupService(shouldSucceed: false)

        await viewModel.searchByText(using: mockService)

        if case .searchFailed = viewModel.addressSearchState {
            // Expected
        } else {
            Issue.record("Expected .searchFailed, got \(viewModel.addressSearchState)")
        }
    }

    // MARK: - save

    @Test func testSaveSuccessSetsSaveStateToSaved() throws {
        let container = try ModelContainer(
            for: Landmark.self, LandmarkCategory.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let viewModel = LandmarkFormViewModel(
            mode: .create,
            suggestionsService: BasicMapItemSuggestionService()
        )
        viewModel.name = "New Place"
        viewModel.symbol = "📍"
        viewModel.notes = "A great spot"

        viewModel.save(using: LandmarkStore(modelContext: container.mainContext))

        #expect(viewModel.saveState == .saved)
    }

    @Test func testSaveSuccessInsertsLandmarkInContext() throws {
        let container = try ModelContainer(
            for: Landmark.self, LandmarkCategory.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let viewModel = LandmarkFormViewModel(
            mode: .create,
            suggestionsService: BasicMapItemSuggestionService()
        )
        viewModel.name = "Persisted Place"
        viewModel.symbol = "🏛️"
        viewModel.notes = "Historical site"
        // Simulate location being resolved
        viewModel.addressSearchState = .searchResolved(
            LocationInfo(
                briefDescription: "",
                fullDescription: "New York, NY",
                latitude: 40.71,
                longitude: -74.00
            )
        )

        viewModel.save(using: LandmarkStore(modelContext: container.mainContext))

        let stored = try container.mainContext.fetch(FetchDescriptor<Landmark>())
        #expect(stored.count == 1)
        #expect(stored.first?.name == "Persisted Place")
        #expect(stored.first?.symbol == "🏛️")
        #expect(stored.first?.notes == "Historical site")
    }

    @Test func testSaveInEditModeUpdatesSaveState() throws {
        let container = try ModelContainer(
            for: Landmark.self, LandmarkCategory.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let landmark = Landmark(name: "Old Name", location: .init(latitude: 51.50, longitude: -0.12))
        container.mainContext.insert(landmark)
        try container.mainContext.save()

        let viewModel = LandmarkFormViewModel(
            mode: .edit(landmark),
            suggestionsService: BasicMapItemSuggestionService()
        )
        viewModel.name = "New Name"
        viewModel.symbol = "🏰"

        viewModel.save(using: LandmarkStore(modelContext: container.mainContext))

        #expect(viewModel.saveState == .saved)
        let stored = try container.mainContext.fetch(FetchDescriptor<Landmark>())
        #expect(stored.first?.name == "New Name")
        #expect(stored.first?.symbol == "🏰")
    }

    @Test func testSaveFailureSetsStateToSaveFailed() {
        let viewModel = LandmarkFormViewModel(
            mode: .create,
            suggestionsService: BasicMapItemSuggestionService()
        )
        viewModel.name = "Test"
        viewModel.save(using: FailingLandmarkStore())
        if case .saveFailed = viewModel.saveState {
            // Expected
        } else {
            Issue.record("Expected .saveFailed, got \(viewModel.saveState)")
        }
    }
    
    @Test func testSaveAppliesFormFieldsToModel() throws {
        let container = try ModelContainer(
            for: Landmark.self, LandmarkCategory.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let category1 = LandmarkCategory(name: "Parks")
        let category2 = LandmarkCategory(name: "Museums")
        container.mainContext.insert(category1)
        container.mainContext.insert(category2)
        
        let viewModel = LandmarkFormViewModel(
            mode: .create,
            suggestionsService: BasicMapItemSuggestionService()
        )
        viewModel.name = "Central Park"
        viewModel.symbol = "🌳"
        viewModel.notes = "Beautiful green space"
        viewModel.categories = [category1, category2]
        viewModel.addressSearchState = .searchResolved(
            LocationInfo(
                briefDescription: "",
                fullDescription: "New York, NY",
                latitude: 40.78,
                longitude: -73.96
            )
        )

        viewModel.save(using: LandmarkStore(modelContext: container.mainContext))

        let stored = try container.mainContext.fetch(FetchDescriptor<Landmark>())
        #expect(stored.count == 1)
        let savedLandmark = try #require(stored.first)
        #expect(savedLandmark.name == "Central Park")
        #expect(savedLandmark.symbol == "🌳")
        #expect(savedLandmark.notes == "Beautiful green space")
        #expect(savedLandmark.categories.count == 2)
    }

    // MARK: - loadCategories
    
    @Test func testLoadCategoriesPopulatesAllCategories() throws {
        let container = try ModelContainer(
            for: Landmark.self, LandmarkCategory.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let category1 = LandmarkCategory(name: "Restaurants")
        let category2 = LandmarkCategory(name: "Museums")
        let category3 = LandmarkCategory(name: "Parks")
        container.mainContext.insert(category1)
        container.mainContext.insert(category2)
        container.mainContext.insert(category3)
        try container.mainContext.save()
        
        let viewModel = LandmarkFormViewModel(
            mode: .create,
            suggestionsService: BasicMapItemSuggestionService()
        )
        viewModel.loadCategories(from: container.mainContext)
        
        #expect(viewModel.allCategories.count == 3)
        #expect(viewModel.allCategories.map { $0.name }.sorted() == ["Museums", "Parks", "Restaurants"])
    }
    
    @Test func testLoadCategoriesHandlesEmptyDatabase() throws {
        let container = try ModelContainer(
            for: Landmark.self, LandmarkCategory.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        
        let viewModel = LandmarkFormViewModel(
            mode: .create,
            suggestionsService: BasicMapItemSuggestionService()
        )
        viewModel.loadCategories(from: container.mainContext)
        
        #expect(viewModel.allCategories.isEmpty)
    }
    
    // MARK: - addCategory / removeCategory
    
    @Test func testAddCategoryAddsToCategories() {
        let viewModel = LandmarkFormViewModel(
            mode: .create,
            suggestionsService: BasicMapItemSuggestionService()
        )
        let category = LandmarkCategory(name: "Favorites")
        
        viewModel.addCategory(category)
        
        #expect(viewModel.categories.count == 1)
        #expect(viewModel.categories.first?.name == "Favorites")
    }
    
    @Test func testRemoveCategoryRemovesFromCategories() {
        let category1 = LandmarkCategory(name: "Favorites")
        let category2 = LandmarkCategory(name: "Visited")
        let viewModel = LandmarkFormViewModel(
            mode: .create,
            suggestionsService: BasicMapItemSuggestionService()
        )
        viewModel.categories = [category1, category2]
        
        viewModel.removeCategory(category1)
        
        #expect(viewModel.categories.count == 1)
        #expect(viewModel.categories.first?.name == "Visited")
    }
    
    // MARK: - unassignedCategories
    
    @Test func testUnassignedCategoriesReturnsOnlyUnassigned() {
        let category1 = LandmarkCategory(name: "Restaurants")
        let category2 = LandmarkCategory(name: "Museums")
        let category3 = LandmarkCategory(name: "Parks")
        
        let viewModel = LandmarkFormViewModel(
            mode: .create,
            suggestionsService: BasicMapItemSuggestionService()
        )
        viewModel.allCategories = [category1, category2, category3]
        viewModel.categories = [category1]
        
        let unassigned = viewModel.unassignedCategories
        
        #expect(unassigned.count == 2)
        #expect(unassigned.contains(category2))
        #expect(unassigned.contains(category3))
        #expect(!unassigned.contains(category1))
    }
    
    @Test func testUnassignedCategoriesWhenAllAssigned() {
        let category1 = LandmarkCategory(name: "Restaurants")
        let category2 = LandmarkCategory(name: "Museums")
        
        let viewModel = LandmarkFormViewModel(
            mode: .create,
            suggestionsService: BasicMapItemSuggestionService()
        )
        viewModel.allCategories = [category1, category2]
        viewModel.categories = [category1, category2]
        
        #expect(viewModel.unassignedCategories.isEmpty)
    }
    
    @Test func testUnassignedCategoriesWhenNoneAssigned() {
        let category1 = LandmarkCategory(name: "Restaurants")
        let category2 = LandmarkCategory(name: "Museums")
        
        let viewModel = LandmarkFormViewModel(
            mode: .create,
            suggestionsService: BasicMapItemSuggestionService()
        )
        viewModel.allCategories = [category1, category2]
        viewModel.categories = []
        
        #expect(viewModel.unassignedCategories.count == 2)
    }

}

// MARK: - Test helpers

private struct FailingLandmarkStore: LandmarkStoring {
    struct SaveError: Error {}
    func commit(landmark: Landmark) throws {
        throw SaveError()
    }
}

